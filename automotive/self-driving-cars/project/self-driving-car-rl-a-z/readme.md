# Self-driving car - based on reinforcement learning
## Overview


![alt text](https://github.com/afondiel/my-lab/blob/master/automotive/self-driving-cars/project/self-driving-car-rl-a-z/tools/doc/first-render-of-the-map.png?raw=true )

Building a self-driving car based reinforcement learning and deep learning

The strategy applied in this project allows to avoid objects in the road (this can be: when the car goes out of road and overtake the lane, or even others cars ...)
This doesn't classify which type of objects are in front of the car. It only avoids them.

- If it succeeds => positive reward(+1), negative reward otherwise. And we repeat the action  until the agent learn by itself how to avoid these objects (RL magic !) 
- Some applications of this project
    - Autonomous shuttles
    - Delivery robots(in factory, production lines )
    - Autonomous racing cars ...

## Requirements
<!-- conda install pytorch==0.3.1 -c pytorch -->

Get conda here => [conda](https://github.com/conda/conda) based on your OS, then you can install the requirements pkg
```
Kivy=2.1.0
matplotlib=3.6.2
numpy=1.23.3
torch=1.13.0
``` 
### Linux 

```python
conda install -r requirements.txt
```
### Windows

```python
conda install -r requirements.txt
```

Files/modules : 
- ai.py : the brain module. It provides 3 Classes
    - Network() : Feed Forward Neural Network architecture definition
    - ReplayMemory() : provides the definition of ReplayMemory
    - Dqn() : Deep Q-Network classifier and learning strategy

- map.py : provides the environment interface
- car.kv : configuration file for the GUI of the car 

## Usage

```python 
python main.py
```

## Contribution and pull requests

Below some few features/tasks to add up. So feel free to pull request

    @TODO :
    - classify objects in the road 
      - On kivy UI env we can add/draw new objects, then classify them 
        - passenger crossing the road
        - another car parked in the road
        - other objects
        - signals (too ambitious but why not ? )
    - add log file for reinforment learning visualization and debugging


# References

- [kivy](https://kivy.org/)
- [gym - openai](https://www.gymlibrary.dev/)
