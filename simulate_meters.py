#!/usr/bin/env python3
"""Simulate AquaSense meters publishing to AWS IoT Core and Kinesis.

Publishes 20 unique meters across five Sri Lankan cities for 120 seconds,
every 3 seconds, with optional single-channel or dual-channel mode.
"""
# pyright: reportMissingImports=false

import argparse
import json
import random
import time
from collections import defaultdict
from datetime import datetime, timezone

import boto3

REGION = "ap-south-1"
TOPIC_TEMPLATE = "meters/{meter_id}/telemetry"
KINESIS_STREAM_NAME = "asu-dev-meter-stream"
TOTAL_SECONDS = 120
PUBLISH_INTERVAL_SECONDS = 3
SUMMARY_INTERVAL_SECONDS = 30

CITY_METER_MAP = {
    "Colombo": [f"meter_{i:03d}" for i in range(1, 5)],
    "Kandy": [f"meter_{i:03d}" for i in range(5, 9)],
    "Galle": [f"meter_{i:03d}" for i in range(9, 13)],
    "Jaffna": [f"meter_{i:03d}" for i in range(13, 17)],
    "Negombo": [f"meter_{i:03d}" for i in range(17, 21)],
}


def parse_args():
    parser = argparse.ArgumentParser(description="Simulate AquaSense meter telemetry")
    parser.add_argument(
        "--mode",
        choices=("iot", "kinesis", "both"),
        default="both",
        help="Publish to AWS IoT Core only, Kinesis only, or both (default: both)",
    )
    return parser.parse_args()


def make_iot_data_client():
    iot_client = boto3.client("iot", region_name=REGION)
    endpoint = iot_client.describe_endpoint(endpointType="iot:Data-ATS")["endpointAddress"]
    return boto3.client("iot-data", region_name=REGION, endpoint_url=f"https://{endpoint}")


def make_kinesis_client():
    return boto3.client("kinesis", region_name=REGION)


def random_reading():
    return {
        "water_usage": round(random.uniform(0, 1000), 2),
        "pressure": round(random.uniform(0.5, 8.5), 2),
        "energy_kwh": round(random.uniform(0, 50), 2),
        "leak_detected": random.random() < 0.05,
    }


def build_meters():
    meters = []
    for city, meter_ids in CITY_METER_MAP.items():
        for meter_id in meter_ids:
            meters.append({"meter_id": meter_id, "city": city})
    return meters


def print_summary(meter_counts, meter_bytes, total_bytes, elapsed_seconds):
    print(f"\nSummary at {elapsed_seconds:>3}s")
    print(f"{'Meter':<12} {'Messages':>8} {'Bytes':>12}")
    print("-" * 34)
    for meter_id in sorted(meter_counts):
        print(f"{meter_id:<12} {meter_counts[meter_id]:>8} {meter_bytes[meter_id]:>12}")
    print("-" * 34)
    print(f"{'TOTAL':<12} {sum(meter_counts.values()):>8} {total_bytes:>12}")


def publish_iot(client, topic, payload_json):
    client.publish(topic=topic, qos=0, payload=payload_json)


def publish_kinesis(client, meter_id, payload_json):
    client.put_record(
        StreamName=KINESIS_STREAM_NAME,
        PartitionKey=meter_id,
        Data=payload_json.encode("utf-8"),
    )


def main():
    args = parse_args()
    meters = build_meters()

    iot_client = make_iot_data_client() if args.mode in ("iot", "both") else None
    kinesis_client = make_kinesis_client() if args.mode in ("kinesis", "both") else None

    meter_counts = defaultdict(int)
    meter_bytes = defaultdict(int)
    total_bytes = 0

    rounds = TOTAL_SECONDS // PUBLISH_INTERVAL_SECONDS
    summary_every_rounds = SUMMARY_INTERVAL_SECONDS // PUBLISH_INTERVAL_SECONDS

    print(
        f"Starting simulation: {len(meters)} meters, mode={args.mode}, "
        f"{rounds} rounds, {PUBLISH_INTERVAL_SECONDS}s interval"
    )

    start_time = time.monotonic()
    next_summary_round = summary_every_rounds

    for round_index in range(1, rounds + 1):
        for meter in meters:
            meter_id = meter["meter_id"]
            payload = {
                "meter_id": meter_id,
                "city": meter["city"],
                "timestamp": datetime.now(timezone.utc).isoformat(),
                **random_reading(),
            }
            payload_json = json.dumps(payload, separators=(",", ":"))
            payload_bytes = len(payload_json.encode("utf-8"))
            topic = TOPIC_TEMPLATE.format(meter_id=meter_id)

            try:
                if args.mode in ("iot", "both"):
                    publish_iot(iot_client, topic, payload_json)
                    meter_counts[meter_id] += 1
                    meter_bytes[meter_id] += payload_bytes
                    total_bytes += payload_bytes

                if args.mode in ("kinesis", "both"):
                    publish_kinesis(kinesis_client, meter_id, payload_json)
                    meter_counts[meter_id] += 1
                    meter_bytes[meter_id] += payload_bytes
                    total_bytes += payload_bytes

                print(
                    f"Published {meter_id} ({meter['city']}) to {args.mode.upper()} "
                    f"at {topic}"
                )
            except Exception as exc:
                print(f"Error publishing for {meter_id}: {exc}")

        if round_index % summary_every_rounds == 0 or round_index == rounds:
            elapsed_seconds = round_index * PUBLISH_INTERVAL_SECONDS
            print_summary(meter_counts, meter_bytes, total_bytes, elapsed_seconds)

        if round_index < rounds:
            target_elapsed = round_index * PUBLISH_INTERVAL_SECONDS
            sleep_for = start_time + target_elapsed - time.monotonic()
            if sleep_for > 0:
                time.sleep(sleep_for)

    print("Simulation complete")


if __name__ == "__main__":
    main()
