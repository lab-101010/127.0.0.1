# Self-driving car - based on reinforcement learning
## Overview

Building a self-driving car based reinforcement learning and deep learning

The strategy applied in this project allows to avoid objects in the road (this can be: when the car goes out of road and overtake the lane, or even others cars ...)
This doesn't classify which type of objects are in front of the car. It only avoids them.

- If it succeeds => positive reward(+1), negative reward otherwise. And we repeat the action  until the agent learn by itself how to avoid these objects (RL magic !) 
- Some applications of this project
    - Autonomous shuttles
    - Delivery robots(in factory, production lines )
    - Autonomous racing cars ...

## Requirements
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

- map.py : provides the environment interface
- car.kv : configuration file for the GUI of the car 

## Usage

- Linux: @todo
- Windows: @todo

## Contribution and pull requests

feel free to pull request

    @TODO :
    - classify objects in the road
    - add log file for reinforment learning visualization 


# References

- [kivy](https://kivy.org/)
- [gym - openai](https://www.gymlibrary.dev/)
