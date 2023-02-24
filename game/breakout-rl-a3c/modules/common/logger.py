import logging
from logging.handlers import RotatingFileHandler

__formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')

def setup_logger(name, log_file, level=logging.INFO):
    # handler = logging.FileHandler(log_file, mode="w")
    handler = RotatingFileHandler(log_file, mode='w', maxBytes=10000000,
              backupCount=1, encoding=None, delay=0)
    handler.setFormatter(__formatter)

    logger = logging.getLogger(name)
    logger.setLevel(level)
    logger.addHandler(handler)

    return logger
