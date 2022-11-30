import sys

if 'modules' not in sys.path:
    import os
    module_path = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(module_path)
    sys.path.append(module_path + "\brain") # '\' : for windows env
    sys.path.append(module_path + "\environment")
