# ProteinNet

## Description

This tool can extract gene lists from PanelApp gene panels and perform network analysis on them with the aim of identifying candidates for expansion.

## Screenshot of the homepage

![Alt text](ProteinNet_Homepage.png?raw=true "Workflow")

## Installation

First, clone this repository

<pre>
git clone https://github.com/Callum-Rakhit/ProteinNet
</pre>

## Dependencies 

Install the following within your local environment (e.g. for Ubuntu 16+):

- <b>R</b>   sudo apt-get install r-base
- <b>Java 11</b>   sudo apt-get install openjdk-11-jdk
- <b>CytoScape</b>   wget https://github.com/cytoscape/cytoscape/releases/download/3.8.0/Cytoscape_3_8_0_unix.sh && sh Cytoscape_3_8_0_unix.sh

CytoScape needs to be open in the background locally for the website to connect to the API

## Run the website

runApp('/ProteinNet')

## Analysis output

Results and the final report can be found in the ProteinNet/Project_temp_webGestalt

The analysis takes a while, please wait ~5 minutes after pressing "Run Analysis" for the results

## Example Output

#### 

![Alt text](example_goslim_summary_temp_webGestalt.png?raw=true "webGestalt top hits for the gene network of interest")
