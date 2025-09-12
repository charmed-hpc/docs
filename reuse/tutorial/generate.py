#!/usr/bin/env python3

"""Generate example dataset for workload."""

import argparse

from faker import Faker
from faker.providers import DynamicProvider
from pandas import DataFrame


faker = Faker()
favorite_lts_mascot = DynamicProvider(
    provider_name="favorite_lts_mascot",
    elements=[
        "Dapper Drake",
        "Hardy Heron",
        "Lucid Lynx",
        "Precise Pangolin",
        "Trusty Tahr",
        "Xenial Xerus",
        "Bionic Beaver",
        "Focal Fossa",
        "Jammy Jellyfish",
        "Noble Numbat",
    ],
)
faker.add_provider(favorite_lts_mascot)


def main(rows: int) -> None:
    df = DataFrame(
        [
            [faker.email(), faker.country(), faker.favorite_lts_mascot()]
            for _ in range(rows)
        ],
        columns=["email", "country", "favorite_lts_mascot"],
    )
    df.to_csv("favorite_lts_mascot.csv")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--rows", type=int, default=1, help="Rows of fake data to generate"
    )
    args = parser.parse_args()

    main(rows=args.rows)
