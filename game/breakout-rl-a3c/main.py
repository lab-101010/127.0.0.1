# File : main.py 
# Description : Main code

from __future__ import print_function
import os
import torch
import torch.multiprocessing as mp
from modules.environment.envs import create_atari_env
from modules.brain.model import ActorCritic
from modules.brain.train import train
from modules.brain.my_optim import SharedAdam
from test import test

# Gathering all the parameters (that we can modify to explore)
class Params():
    def __init__(self):
        self.lr = 0.0001
        self.gamma = 0.99
        self.tau = 1.
        self.seed = 1
        self.num_processes = 16
        self.num_steps = 20
        self.max_episode_length = 10000
        self.env_name = 'Breakout-v0'

# Main run
if __name__ == '__main__':
    os.environ['OMP_NUM_THREADS'] = '1'
    # init model params
    params = Params()
    torch.manual_seed(params.seed)
    #  start env
    env = create_atari_env(params.env_name)
    # model object
    shared_model = ActorCritic(env.observation_space.shape[0], env.action_space)
    shared_model.share_memory()
    #  computer gradient descent
    optimizer = SharedAdam(shared_model.parameters(), lr=params.lr)
    optimizer.share_memory()
    #  create a list of process for agent thread
    processes = []
    p = mp.Process(target=test, args=(params.num_processes, params, shared_model))
    p.start()
    processes.append(p)

    for rank in range(0, params.num_processes):
        p = mp.Process(target=train, args=(rank, params, shared_model, optimizer))
        p.start()
        processes.append(p)
    for p in processes:
        p.join()
