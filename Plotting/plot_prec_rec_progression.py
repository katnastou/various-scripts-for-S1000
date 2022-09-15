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
from matplotlib.cm import Dark2
from matplotlib.lines import Line2D


def load_data(file):
    # Importing the dataset
    dataset = pd.read_csv(file, sep="\t")
    return dataset

def make_lists_for_contours():
    prec=range(0,100,1)
    #prec=[0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]
    f=[70,75,80,85,90,95]
    #rec_prec={j:[[i,(j*i)/((2*i)-j)] for i in prec if ((2*i)!=j)] for j in f }
    x=[i for i in prec for j in f if ((2*i)!=j)]
    y=[(j*i)/((2*i)-j) for i in prec for j in f if ((2*i)!=j)]
    #print(rec_prec)
    return x,y

def plot_data(options):
    num_categories = 6
    c = [Dark2(float(i)/num_categories) for i in range(num_categories)]

    #make font size larger
    sns.set(font_scale=1.2)
    sns.set_style("whitegrid")
    sns.color_palette(c, num_categories)
    df = load_data(options.input_file)
    g = sns.relplot(
        data=df,
        x="Precision", y="Recall", 
        # hue="Step", 
        # palette=c, 
        linewidth=2,
        color="black",
        # s=100,
        markers=True,
        dashes=False,
        sort=False, 
        kind="line"
    ).set(title=options.task)
    
    g.figure.set_size_inches(12,9)
    g.ax.margins(.15)
    g.ax.xaxis.grid(True, "major", linewidth=.25)
    # g.ax.xaxis.grid(True, "minor", linewidth=.05)
    g.ax.yaxis.grid(True, "major", linewidth=.25)
    
    plt.yticks([65,70,75,80,85,90,95,100],[65,70,75,80,85,90,95,100])
    plt.xticks([65,70,75,80,85,90,95,100],[65,70,75,80,85,90,95,100])
    g.ax.set_ylim([63, 102])
    g.ax.set_xlim([63, 102])


    g.ax.set(xlabel='Precision (%)', ylabel='Recall (%)')

    # #plot points from file to see what has been checked.
    
    sns.scatterplot(data=df,x='Precision',y='Recall',palette=c,hue="Step",s=100)
    # for i in range(df.shape[0]-2):
    #     plt.text(x=df.Precision[i]-1.4,y=df.Recall[i]-1.4,s=df.Step[i], 
    #             fontdict=dict(color='black',size=10),
    #             bbox=dict(facecolor=c[i],alpha=0.5))
#     plt.text(x=df.Precision[0]-1.4,y=df.Recall[0]-1.4,s=str(df.Step[0])+" ("+str(df.Precision[0])+"%, "+str(df.Recall[0])+"%)", 
#             fontdict=dict(color='black',size=10),
#             bbox=dict(facecolor=c[0],alpha=0.5))
#     plt.text(x=df.Precision[1]-1.4,y=df.Recall[1]-1.4,s=str(df.Step[1])+" ("+str(df.Precision[1])+"%, "+str(df.Recall[1])+"%)", 
#             fontdict=dict(color='black',size=10),
#             bbox=dict(facecolor=c[1],alpha=0.5))
#     plt.text(x=df.Precision[2]-0.2,y=df.Recall[2]-1.4,s=str(df.Step[2])+" ("+str(df.Precision[2])+"%, "+str(df.Recall[2])+"%)", 
#             fontdict=dict(color='black',size=10),
#             bbox=dict(facecolor=c[2],alpha=0.5))
#     plt.text(x=df.Precision[3]-7.3,y=df.Recall[3]+0.5,s=str(df.Step[3])+" ("+str(df.Precision[3])+"%, "+str(df.Recall[3])+"%)", 
#             fontdict=dict(color='black',size=10),
#             bbox=dict(facecolor=c[3],alpha=0.5))
#     plt.text(x=df.Precision[4]+0.5,y=df.Recall[4]+0.5,s=str(df.Step[4])+" ("+str(df.Precision[4])+"%, "+str(df.Recall[4])+"%)", 
#             fontdict=dict(color='black',size=10),
#             bbox=dict(facecolor=c[4],alpha=0.5))
#     plt.text(x=df.Precision[5]-1,y=df.Recall[5]-1.4,s=str(df.Step[5])+" ("+str(df.Precision[5])+"%, "+str(df.Recall[5])+"%)", 
#             fontdict=dict(color='black',size=10),
#             bbox=dict(facecolor=c[5],alpha=0.5))
    plt.text(x=df.Precision[0]-1.4,y=df.Recall[0]-1.4,s=str(df.Step[0])+" ("+str(df.F[0])+"%)", 
            fontdict=dict(color='black',size=10),
            bbox=dict(facecolor=c[0],alpha=0.5))
    plt.text(x=df.Precision[1]-1.4,y=df.Recall[1]-1.4,s=str(df.Step[1])+" ("+str(df.F[1])+"%)", 
            fontdict=dict(color='black',size=10),
            bbox=dict(facecolor=c[1],alpha=0.5))
    plt.text(x=df.Precision[2]-0.2,y=df.Recall[2]-1.4,s=str(df.Step[2])+" ("+str(df.F[2])+"%)", 
            fontdict=dict(color='black',size=10),
            bbox=dict(facecolor=c[2],alpha=0.5))
    plt.text(x=df.Precision[3]-7.3,y=df.Recall[3]+0.5,s=str(df.Step[3])+" ("+str(df.F[3])+"%)", 
            fontdict=dict(color='black',size=10),
            bbox=dict(facecolor=c[3],alpha=0.5))
    plt.text(x=df.Precision[4]+0.5,y=df.Recall[4]+0.5,s=str(df.Step[4])+" ("+str(df.F[4])+"%)", 
            fontdict=dict(color='black',size=10),
            bbox=dict(facecolor=c[4],alpha=0.5))
    plt.text(x=df.Precision[5]-1,y=df.Recall[5]-1.4,s=str(df.Step[5])+" ("+str(df.F[5])+"%)", 
            fontdict=dict(color='black',size=10),
            bbox=dict(facecolor=c[5],alpha=0.5))
    # plt.scatter(df.Precision, df.Recall, s=100,  marker='o', c=c)

    # legend_elements = [ Line2D([0], [0], marker='o', color='white', label='Jensenlab tagger',
    #                         markerfacecolor='black', markersize=10),
    #                 Line2D([0], [0], marker='^', color='white', label='ML-based method',
    #                         markerfacecolor='black', markersize=10)
    #                 ]
    #plot the contours
    x_c,y_c=make_lists_for_contours()
    plt.scatter(x_c, y_c, s=1,  marker='o', c='grey')
    # Create the figure
    # plt.legend(handles=legend_elements, loc='center', bbox_to_anchor=(1.1, 0.2), frameon=False)
    plt.savefig(options.output_file) 
    plt.show()
    

if __name__ == "__main__":
    '''Example call: python3 plot_prec_rec_progression.py --input_file=progression_precision_recall.tsv --task="Precision-Recall Plot for Progression" --output_file=progression_plot.pdf'''
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_file", required=True, type=str)
    parser.add_argument("--task", required=True, type=str)
    parser.add_argument("--output_file", required=True, type=str)
    args = parser.parse_args()
    current_file_path = dir_path = os.path.dirname(os.path.realpath(__file__))
    sys.path.append("/".join(current_file_path.split("/")[:-1]))
    sys.path.append("/".join(current_file_path.split("/")[:-2]))
    plot_data(args)
