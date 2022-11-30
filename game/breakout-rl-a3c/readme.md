# Breakout game - A3C
## Overview

This project aims to teach an AI to play the game Breakout. 

![alt text](https://upload.wikimedia.org/wikipedia/en/c/cd/Breakout_game_screenshot.png)

<!--https://media.moddb.com/images/downloads/1/200/199908/Screenshot_Doom_20200831_001304.png-->

## A brief story of the game

[Breakout](https://en.wikipedia.org/wiki/Breakout_(video_game)) is an arcade video game developed and published by [Atari](https://en.wikipedia.org/wiki/Atari,_Inc) and released on May 13, 1976

The objective of the game is to clear all of the bricks on the screen by hitting them with a ball

    Breakout game - rules

    1. The game is played with a paddle and a ball

    2. The objective of the game is to break all the bricks on the screen by bouncing the ball off the paddle

    3. The game is over when all the bricks are broken or when the ball goes off the screen

    4. The player gets one point for each brick broken

## The AI
The AI uses Deep Convolutional Neural Network and reinforcement learning algorithm on game environment from gym OpenAI

- If it succeeds => positive reward(+1), negative reward otherwise. And we repeat the action  until the agent learn by itself how to avoid these objects (RL magic !) 
- Some applications of this project
    - computer vision & image processing
    - self-driving perception
    - robotics

## Requirements
```
pip install -r requirements.txt
```
or

```
conda install -c pytorch pytorch
conda install -c akode gym
conda install -c menpo ffmpeg
conda install -c conda-forge opencv
```
also make sure to accept the gym license 

```
pip install gym[accept-rom-license]
```

## Usage

```
python main.py
```

## Contribution and pull requests

feel free to pull request if you some great ideas to share

    `@TODO task & features`
    - add a logger for debugging and logging results
    - run the game in notebook ? (jupyter/Colab...)
  

# References

- [gym - OpenAi](https://www.gymlibrary.dev/)
- [gym - Universe](https://openai.com/blog/universe/)
- [OpenAI Baselines: ACKTR & A2C](https://openai.com/blog/baselines-acktr-a2c/)
- [python A3C - by Ilya Kostrikov ](https://github.com/ikostrikov/pytorch-a3c)
- [A2C - A3C paper](https://github.com/afondiel/research-notes/blob/master/ai/research-papers/asynchronous-methods-for-deep-reinforcement-learning-paper-2016-A3C-google-MILA.pdf)


