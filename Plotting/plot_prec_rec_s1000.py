#!/usr/bin/python

from distutils.archive_util import make_archive
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import pandas as pd
import os
import sys
import argparse
import seaborn as sns
from matplotlib.cm import tab10
from matplotlib.lines import Line2D


def load_data(file):
    # Importing the dataset
    dataset = pd.read_csv(file, sep="\t")
    return dataset

def make_lists_for_contours():
    prec=range(0,100,1)
    #prec=[0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]
    f=[60,65,70,75,80,85,90,95]
    #rec_prec={j:[[i,(j*i)/((2*i)-j)] for i in prec if ((2*i)!=j)] for j in f }
    x=[i for i in prec for j in f if ((2*i)!=j)]
    y=[(j*i)/((2*i)-j) for i in prec for j in f if ((2*i)!=j)]
    #print(rec_prec)
    return x,y

def plot_data(options):
    num_categories = 7
    c = [tab10(float(i)/num_categories) for i in range(num_categories)]
    #make font size larger
    sns.set(font_scale=1.2)
    sns.set_style("whitegrid")
    sns.color_palette(c, 7)

    g = sns.relplot(
        data=load_data(options.jensenlab_method_file),
        x="prec", y="rec", 
        hue="Category", 
        palette=c, 
        linewidth=0.1,
        s=100,
    ).set(title=options.task)
    
    g.figure.set_size_inches(12,9)
    g.ax.margins(.15)
    g.ax.xaxis.grid(True, "major", linewidth=.25)
    # g.ax.xaxis.grid(True, "minor", linewidth=.05)
    g.ax.yaxis.grid(True, "major", linewidth=.25)

    plt.yticks([60,65,70,75,80,85,90,95,100],[60,65,70,75,80,85,90,95,100])
    plt.xticks([60,65,70,75,80,85,90,95,100],[60,65,70,75,80,85,90,95,100])
    g.ax.set_ylim([58, 102])
    g.ax.set_xlim([58, 102])

    g.ax.set(xlabel='Precision (%)', ylabel='Recall (%)')

    #plot points from file to see what has been checked.
    df = load_data(options.ml_method_file)

    plt.scatter(df.prec, df.rec, s=100,  marker='^', c=c)

    legend_elements = [ Line2D([0], [0], marker='o', color='white', label='Jensenlab tagger',
                            markerfacecolor='black', markersize=10),
                    Line2D([0], [0], marker='^', color='white', label='ML-based method',
                            markerfacecolor='black', markersize=10)
                    ]
    #plot the contours
    x_c,y_c=make_lists_for_contours()
    plt.scatter(x_c, y_c, s=1,  marker='o', c='grey')
    # Create the figure
    plt.legend(handles=legend_elements, loc='center', bbox_to_anchor=(1.1, 0.2), frameon=False)
    plt.savefig(options.output_file) 
    plt.show()
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-h','--help', action="help", help='Example call: python3 plot_prec_rec_s1000.py --ml_method_file=Jouni-species-test-S1000-pr-rec-f1.tsv --jensenlab_method_file=Jensenlab-species-test-S1000-pr-rec-f1.tsv --task="Precision-Recall Plot for S1000" --output_file=S1000_plot.pdf')
    parser.add_argument("--ml_method_file", required=True, type=str)
    parser.add_argument("--jensenlab_method_file", required=True, type=str)
    parser.add_argument("--task", required=True, type=str)
    parser.add_argument("--output_file", required=True, type=str)
    args = parser.parse_args()
    current_file_path = dir_path = os.path.dirname(os.path.realpath(__file__))
    sys.path.append("/".join(current_file_path.split("/")[:-1]))
    sys.path.append("/".join(current_file_path.split("/")[:-2]))
    plot_data(args)
