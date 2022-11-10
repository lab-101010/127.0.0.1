## Overview

Building a self-driving car based reinforcement learning and deep learning

## requirements
Linux : 
<-- conda install pytorch==0.3.1 -c pytorch -->
- conda install -c pytorch pytorch 
- conda install -c conda-forge kivy

Windows : 
<-- conda install -c peterjc123 pytorch-cpu -->
- conda install -c pytorch pytorch 
- conda install -c conda-forge kivy

Files/modules : 
- ai.py : the brain module. It provides 3 Classes
    - Network() : Feed Forward Neural Network architecture definition
    - ReplayMemory() : provides the definition of ReplayMemory
    - Dqn() : Deep Q-Network classifier and learning strategy

- map.py : provides the environement interface
- car.kv : configuration file for the GUI of the car 

## Usage

- Linux: @todo
- Windows: @todo

## Contribution and pull requests

feel free to pull request


# References
