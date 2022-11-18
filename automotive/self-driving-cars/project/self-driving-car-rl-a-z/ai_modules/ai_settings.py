# File : ai_settings.py 
# Description : tuning parameters and thresholders values

# Model parameters
MODEL_INPUT_SIZE        = 5
MODEL_HIDDEN_SIZE       = 30
MODEL_OUTPUT_SIZE       = 3

AI_MODEL_PATH ='data\model\ai_model_.pkl'

# DQN parameters
REPLAY_MEMORY_CAPACITY  = 100000
DISCOUNT_FACTOR_GAMMA   = 0.9
TEMPERATURE_PARAM       = 100

# Env parameters
ENV_EDGE_MAP            = 10
ENV_DISTANCE_MIN        = 0
ENV_DISTANCE_MAX        = 100
ENV_KIVY_CFG_FILE_PATH  = 'data\car.kv'

# Car parameters
CAR_SENSOR_DISTANCE     = 30
CAR_VELOCITY_MIN        = 1
CAR_VELOCITY_MAX        = 6


