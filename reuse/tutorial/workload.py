#!/usr/bin/env python3

"""Plot the most popular Ubuntu LTS mascot."""

import argparse
from os import PathLike

import pandas as pd


def main(dataset: str | PathLike, file: str | PathLike) -> None:
    df = pd.read_csv(dataset)
    mascots = df["favorite_lts_mascot"].value_counts().sort_index()

    axes = mascots.plot(
        kind="barh",
        title="Favorite LTS mascot",
        ylabel="Mascot",
        xlabel="Votes",
        color="orange",
    )
    figure = axes.get_figure()
    figure.set_figheight(4)
    figure.set_figwidth(12)
    figure.savefig(file or "graph.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dataset", type=str, help="Path to CSV dataset to plot")
    parser.add_argument("-o", "--output", type=str, help="Output file to save plotted graph")
    args = parser.parse_args()

    main(args.dataset, args.output)
