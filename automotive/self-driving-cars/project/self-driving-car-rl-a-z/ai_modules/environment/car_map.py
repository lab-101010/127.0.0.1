# map.py : provides the environment interface of the car
# Description : # Self Driving Car environment
#
# Libraries requirements : 
#   <os> : standard library
#		- Provides a portable way of using operating system dependent functionality.
#   <sys> : standard library
#		- provides access to some variables used or maintained by the interpreter and 
#         to functions that interact strongly with the interpreter.
#   <random> : standard library
#		- Random variables generators
#   <numpy> : standard library
#		- Provides multidimensional arrays and linear algebra tools, optimized for speed
#   <torch> : Deep learning library
#		- Provides data structures for multi-dimensional tensors and defines mathematical operations over these tensors
#       - provides also many utilities for efficient serializing of Tensors and arbitrary types, and other useful utilities.
#       - It has a CUDA counterpart, that enables you to run your tensor computations on an NVIDIA GPU with compute capability >= 3.0.


# File history :
# Afondiel  |  11.11.2022 | creation 
# Afondiel  |  18.11.2022 | Last modification 

# Importing the libraries
import numpy as np
from random import random, randint
import matplotlib.pyplot as plt
import time

# Importing the Kivy packages
from kivy.app import App
from kivy.uix.widget import Widget
from kivy.uix.button import Button
from kivy.graphics import Color, Ellipse, Line
from kivy.config import Config
from kivy.properties import NumericProperty, ReferenceListProperty, ObjectProperty
from kivy.vector import Vector
from kivy.clock import Clock
from kivy.lang import Builder

# Importing the Dqn object from our AI in ai_dqn_classifier.py
import ai_settings
# import data
from brain.ai_dqn_classifier import Dqn

# Adding this line if we don't want the right click to put a red point
Config.set('input', 'mouse', 'mouse,multitouch_on_demand')

# Introducing last_x and last_y, used to keep the last point in memory when we draw the sand on the map
last_x = 0
last_y = 0
n_points = 0
length = 0

# Getting our AI, which we call "brain", and that contains our neural network that represents our Q-function
# brain_obj = Dqn(ai_settings.MODEL_INPUT_SIZE, ai_settings.MODEL_HIDDEN_SIZE, ai_settings.MODEL_OUTPUT_SIZE, ai_settings.DISCOUNT_FACTOR_GAMMA)
brain_obj = Dqn(ai_settings.MODEL_INPUT_SIZE, ai_settings.MODEL_OUTPUT_SIZE, ai_settings.DISCOUNT_FACTOR_GAMMA)
# rotation vector(°) : [straight(no rotation ), right, left]
action2rotation = [0, 20, -20]
# reward variable at t time(good reward if the car stays btw the lines bad otherwise)
# best reward = +1 (success)
# worse reward = -1 (penality)
last_reward = 0
# vector that contains the reward
scores = []

# Initializing the map
first_update = True

def init():
    """ Creates and sets all global variables and map coordinates
        - sand : density of sand /obstacle in the road (0 - no sand, 1 - full of sand)
        - goal_x : x coordinate in the map the car has to reach
        - goal_y : y coordinate in the map the car has to reach
        - first_update : update the screen/map ?
    """
    global sand
    global goal_x
    global goal_y
    global first_update
    sand = np.zeros((longueur,largeur))
    goal_x = 20
    goal_y = largeur - 20
    first_update = False

# Initializing the last distance
last_distance = 0

# Creating the car class

class Car(Widget):
    """handles the movement of the vehicle
    - angle : angle between x axis and the direction of the car 
    - rotation : rotation vector/command in degree
    - velocity : speed (x + y) 
    - sensor1 :  obstacle detector in front side of the car   
    - sensor2 : obstacle detector left side of the car  
    - sensor3 : obstacle detector in right front of the car 
    - signal1 : signal received by sensor 1 (density of obstacle/sand)
    - signal2 : signal received by sensor 2
    - signal3 : signal received by sensor 3    
    """
    angle = NumericProperty(0)
    rotation = NumericProperty(0)
    velocity_x = NumericProperty(0)
    velocity_y = NumericProperty(0)
    velocity = ReferenceListProperty(velocity_x, velocity_y)
    sensor1_x = NumericProperty(0)
    sensor1_y = NumericProperty(0)
    sensor1 = ReferenceListProperty(sensor1_x, sensor1_y)
    sensor2_x = NumericProperty(0)
    sensor2_y = NumericProperty(0)
    sensor2 = ReferenceListProperty(sensor2_x, sensor2_y)
    sensor3_x = NumericProperty(0)
    sensor3_y = NumericProperty(0)
    sensor3 = ReferenceListProperty(sensor3_x, sensor3_y)
    signal1 = NumericProperty(0)
    signal2 = NumericProperty(0)
    signal3 = NumericProperty(0)

    def move(self, rotation):
        """ controls the movement of the car 
        - self : this object
        - rotation : the rotation vector
        """
        self.pos = Vector(*self.velocity) + self.pos
        self.rotation = rotation
        self.angle = self.angle + self.rotation
        self.sensor1 = Vector(ai_settings.CAR_SENSOR_DISTANCE, 0).rotate(self.angle) + self.pos
        self.sensor2 = Vector(ai_settings.CAR_SENSOR_DISTANCE, 0).rotate((self.angle+30)%360) + self.pos
        self.sensor3 = Vector(ai_settings.CAR_SENSOR_DISTANCE, 0).rotate((self.angle-30)%360) + self.pos
        # -10 / +10 to avoid touching the Wall of the map/window
        self.signal1 = int(np.sum(sand[int(self.sensor1_x)-10:int(self.sensor1_x)+10, int(self.sensor1_y)-10:int(self.sensor1_y)+10]))/400.
        self.signal2 = int(np.sum(sand[int(self.sensor2_x)-10:int(self.sensor2_x)+10, int(self.sensor2_y)-10:int(self.sensor2_y)+10]))/400.
        self.signal3 = int(np.sum(sand[int(self.sensor3_x)-10:int(self.sensor3_x)+10, int(self.sensor3_y)-10:int(self.sensor3_y)+10]))/400.
        # sand detection/full density of sensor 1
        if self.sensor1_x > longueur-ai_settings.ENV_EDGE_MAP or self.sensor1_x < ai_settings.ENV_EDGE_MAP or self.sensor1_y > largeur-10 or self.sensor1_y < ai_settings.ENV_EDGE_MAP:
            self.signal1 = 1.
        # sand detection/full density of sensor 2
        if self.sensor2_x > longueur-ai_settings.ENV_EDGE_MAP or self.sensor2_x < ai_settings.ENV_EDGE_MAP or self.sensor2_y > largeur-10 or self.sensor2_y < ai_settings.ENV_EDGE_MAP:
            self.signal2 = 1.
        # sand detection/full density of sensor 3
        if self.sensor3_x > longueur-ai_settings.ENV_EDGE_MAP or self.sensor3_x < ai_settings.ENV_EDGE_MAP or self.sensor3_y > largeur-10 or self.sensor3_y < ai_settings.ENV_EDGE_MAP:
            self.signal3 = 1.

class Ball1(Widget):
    """ Sensor 1 """
    pass
class Ball2(Widget):
    """ Sensor 2 """
    pass
class Ball3(Widget):
    """ Sensor 3 """
    pass

# Creating the game class

class Game(Widget):
    """ Game Class 
    - car : car object
    - ball1 : ball1 object
    - ball2 : ball2 object 
    - ball3 : ball3 object
    """
    car = ObjectProperty(None)
    ball1 = ObjectProperty(None)
    ball2 = ObjectProperty(None)
    ball3 = ObjectProperty(None)

    def serve_car(self):
        self.car.center = self.center
        self.car.velocity = Vector(6, 0)

    def update(self, dt):
        """ update the actions made by the agent(car) and other parameters every t time
        - self this object
        - dt every t iteration time
        """
        global brain_obj
        global last_reward
        global scores
        global last_distance
        global goal_x
        global goal_y
        global longueur
        global largeur

        longueur = self.width
        largeur = self.height
        if first_update:
            init()

        xx = goal_x - self.car.x
        yy = goal_y - self.car.y
        orientation = Vector(*self.car.velocity).angle((xx,yy))/180.
        # Encoded vector sent to the Neural Network
        last_signal = [self.car.signal1, self.car.signal2, self.car.signal3, orientation, -orientation]
        # action to play each time
        action = brain_obj.update(last_reward, last_signal)
        # compute new score based on new action value
        scores.append(brain_obj.score())
        # compute new rotation based on new action value
        rotation = action2rotation[action]
        self.car.move(rotation)
        distance = np.sqrt((self.car.x - goal_x)**2 + (self.car.y - goal_y)**2)
        self.ball1.pos = self.car.sensor1
        self.ball2.pos = self.car.sensor2
        self.ball3.pos = self.car.sensor3

        if sand[int(self.car.x),int(self.car.y)] > 0:
            self.car.velocity = Vector(ai_settings.CAR_VELOCITY_MIN, 0).rotate(self.car.angle)
            last_reward = -1
        else: # otherwise
            self.car.velocity = Vector(ai_settings.CAR_VELOCITY_MAX, 0).rotate(self.car.angle)
            last_reward = -0.2
            if distance < last_distance:
                last_reward = 0.1
        # left
        if self.car.x < ai_settings.ENV_EDGE_MAP:
            self.car.x = ai_settings.ENV_EDGE_MAP
            last_reward = -1
        # right
        if self.car.x > self.width - ai_settings.ENV_EDGE_MAP:
            self.car.x = self.width - ai_settings.ENV_EDGE_MAP
            last_reward = -1
        # botton
        if self.car.y < ai_settings.ENV_EDGE_MAP:
            self.car.y = ai_settings.ENV_EDGE_MAP
            last_reward = -1
        # top - left
        if self.car.y > self.height - ai_settings.ENV_EDGE_MAP:
            self.car.y = self.height - ai_settings.ENV_EDGE_MAP
            last_reward = -1
        # goal update
        if distance < ai_settings.ENV_DISTANCE_MAX:
            goal_x = self.width-goal_x
            goal_y = self.height-goal_y
        last_distance = distance

# Adding the painting tools

class MyPaintWidget(Widget):
    """ Interface style more related to kavy """
    def on_touch_down(self, touch):
        global length, n_points, last_x, last_y
        with self.canvas:
            Color(0.8,0.7,0)
            d = 10.
            touch.ud['line'] = Line(points = (touch.x, touch.y), width = 10)
            last_x = int(touch.x)
            last_y = int(touch.y)
            n_points = 0
            length = 0
            sand[int(touch.x),int(touch.y)] = 1

    def on_touch_move(self, touch):
        global length, n_points, last_x, last_y
        if touch.button == 'left':
            touch.ud['line'].points += [touch.x, touch.y]
            x = int(touch.x)
            y = int(touch.y)
            length += np.sqrt(max((x - last_x)**2 + (y - last_y)**2, 2))
            n_points += 1.
            density = n_points/(length)
            touch.ud['line'].width = int(20 * density + 1)
            sand[int(touch.x) - 10 : int(touch.x) + 10, int(touch.y) - 10 : int(touch.y) + 10] = 1
            last_x = x
            last_y = y

# Adding the API Buttons (clear, save and load)

class CarApp(App):
    """ API Buttons : clear, save and load """
    def build(self):
        Builder.load_file(ai_settings.ENV_KIVY_CFG_FILE_PATH)
        parent = Game()
        parent.serve_car()
        Clock.schedule_interval(parent.update, 1.0/60.0)
        self.painter = MyPaintWidget()
        clearbtn = Button(text = 'clear')
        savebtn = Button(text = 'save', pos = (parent.width, 0))
        loadbtn = Button(text = 'load', pos = (2 * parent.width, 0))
        clearbtn.bind(on_release = self.clear_canvas)
        savebtn.bind(on_release = self.save)
        loadbtn.bind(on_release = self.load)
        parent.add_widget(self.painter)
        parent.add_widget(clearbtn)
        parent.add_widget(savebtn)
        parent.add_widget(loadbtn)
        return parent

    def clear_canvas(self, obj):
        global sand
        self.painter.canvas.clear()
        sand = np.zeros((longueur,largeur))

    def save(self, obj):
        print("saving brain...")
        brain_obj.save()
        plt.plot(scores)
        plt.show()

    def load(self, obj):
        print("loading last saved brain...")
        brain_obj.load()

