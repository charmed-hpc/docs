#!/usr/bin/env python3
"""Plot the most popular Ubuntu LTS mascot."""
      
import argparse
import os
      
import pandas as pd
import plotext as plt
      
def main(dataset: str | os.PathLike, file: str | os.PathLike) -> None:
    df = pd.read_csv(dataset)
    mascots = df["favorite_lts_mascot"].value_counts().sort_index()
      
    plt.simple_bar(
        mascots.index,
        mascots.values,
        title="Favorite LTS mascot",
        color="orange",
        width=150,
    )
      
    if file:
        plt.save_fig(
            file if os.path.isabs(file) else f"{os.getcwd()}/{file}",
            keep_colors=True
        )
    else:
        plt.show()
      
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dataset", type=str, help="Path to CSV dataset to plot")
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        default="",
        help="Output file to save plotted graph",
    )
    args = parser.parse_args()
      
    main(args.dataset, args.output)
