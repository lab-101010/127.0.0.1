# File : ai_settings.py 
# Description : tuning parameters and thresholders values for the app

# A3C Model Architecture (use dict() for cnn parameters?? )
MODEL_INPUT_SIZE        = 5
MODEL_HIDDEN_SIZE       = 40
MODEL_OUTPUT_SIZE       = 3
AI_MODEL_PATH ='data\\model\\a3c_brain.pth'

# Hyperparameters
MODEL_LR                = 0.001
MODEL_EPOCHS            = 100
MODEL_BATCH             = 20
MODEL_BATCH             = 20
INIT_STD_ACTOR          = 0.01
INIT_STD_CRITIC         = 1.0

# AI & RL algorithm parameters
REPLAY_MEMORY_CAPACITY  = 10000
REPLAY_MEMORY_NB_STEPS  = 200
REPLAY_MEMORY_BATCH_SIZE= 128 #1/2 byte
DISCOUNT_FACTOR_GAMMA   = 0.99
# ai activate
TEMPERATURE_PARAM       = 100
# ai dactivate
# TEMPERATURE_PARAM       = 0

ELIGIBILITY_TRACE_N_STEPS  = 10
MOVING_AVG_SIZE            = 100

# App Env parameters
WINDOW_WIDTH          = 280
WINDOW_HIGHT          = 280

VIDEO_FILE_PATH  = 'tools\\videos'

# App parameters



