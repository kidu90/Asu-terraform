#!/usr/bin/env python3
"""Simulate 10 smart meters publishing telemetry to AWS IoT Core.

Publishes JSON messages to topic `meters/{meter_id}/telemetry` every 5 seconds
for a total duration of 60 seconds.
"""
import json
import random
import time
from datetime import datetime, timezone

import boto3

REGION = "ap-south-1"
TOPIC_TEMPLATE = "meters/{meter_id}/telemetry"
LOCATIONS = ["Colombo", "Negombo", "Kandy", "Galle", "Jaffna"]


def make_client():
    return boto3.client("iot-data", region_name=REGION)


def random_reading():
    return {
        "water_usage": round(random.uniform(0, 1000), 2),
        "pressure": round(random.uniform(0.5, 8.5), 2),
        "energy_kwh": round(random.uniform(0, 50), 2),
        "leak_detected": random.random() < 0.05,
    }


def main():
    client = make_client()

    # create 10 meter ids
    meters = [f"meter-{i+1:03d}" for i in range(10)]
    interval = 5
    total_seconds = 60
    rounds = max(1, total_seconds // interval)

    print(f"Starting simulation: {len(meters)} meters, {rounds} rounds, {interval}s interval")

    for r in range(rounds):
        for meter_id in meters:
            payload = {
                "meter_id": meter_id,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "location": random.choice(LOCATIONS),
            }
            payload.update(random_reading())

            topic = TOPIC_TEMPLATE.format(meter_id=meter_id)
            try:
                client.publish(topic=topic, qos=0, payload=json.dumps(payload))
                summary = (
                    f"water={payload['water_usage']}L energy={payload['energy_kwh']}kWh "
                    f"pressure={payload['pressure']}bar leak={payload['leak_detected']}"
                )
                print(f"Published to {topic}: {meter_id} -> {summary}")
            except Exception as e:
                print(f"Error publishing for {meter_id} to {topic}: {e}")

        if r < rounds - 1:
            time.sleep(interval)

    print("Simulation complete")


if __name__ == "__main__":
    main()
