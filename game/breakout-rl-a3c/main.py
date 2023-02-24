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

# import local librairies
# import modules.ai_test
# from modules.ai_test import agent_test
from ai_test import agent_test
import modules.ai_settings
from modules.common.Logger import setup_logger


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

logger = setup_logger(name='main', log_file='main.log', level=logging.DEBUG)

# Main run
if __name__ == '__main__':
    # starting the app
    print("Start the App ... ")
    # logging 
    logger.info("Start the App ... ")

    os.environ['OMP_NUM_THREADS'] = '1'
    # create params object
    params = Params()
    torch.manual_seed(params.seed)
    # start env
    env = create_atari_env(params.env_name)
    # model object
    shared_model = ActorCritic(env.observation_space.shape[0], env.action_space)
    shared_model.share_memory()
    #  computer gradient descent
    optimizer = SharedAdam(shared_model.parameters(), lr=params.lr)
    optimizer.share_memory()
    #  create a list of process for agent thread
    processes = []
    # create multiprocessing object for agent experiences or tests 
    p = mp.Process(target=agent_test, args=(params.num_processes, params, shared_model))
    # start test
    p.start()
    processes.append(p)

    # create multiprocessing object to train the agent based on numbers of rank/experiences created by in the test process[]
    for rank in range(0, params.num_processes):
        p = mp.Process(target=train, args=(rank, params, shared_model, optimizer))
        # start train
        p.start()
        processes.append(p)
    for p in processes:
        # run one process by one 
        p.join()

