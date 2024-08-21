# F1 Telemetry Dashboard

## Overview 

This is a F1 (Formula 1) Telemetry dashboard for real-time data acquisition and analysis. 

**Goal**

The system capture data in real-time from multiple sensors in the car and transfer (throught wireless system) to the dashboard for data exporation and analysis (EDA).

**Telemetry Data**

F1 car has around 300 sensors (in average) that exchange data of ~3-4 GB/s (1.5k data points)
- control sensors : accelerator pedal sensor  ...
- monitoring sensors : hydraulic system pressure...
- instrumentation sensors : pressure and fuel flow sensors ...

## System Architecture 
- Data Acquisition 
- Data Visualization

## Development Pipeline
- Phase I: data will come from a static source like: csv file ou db 
- Phase II: the data will be transfer from a F1 simulator like psp/xbox game or mobile games via UDP telemetry. 
- Phase III: Run this with a (real) F1 car or a Robot.

## Requirements 

- Software: 

```
- python
- fastf1
- kafka
- apache spark
- adx
- Grafana
- Matplotlib

```
- Hardware

```
- F1 racing game emulator with UDP Telemetry (PSP/xbox/mobile F1 racing game)
```

## Usage

```
@TBD
```

## Contributing

Feel free to create a PR and open an issue, if you encounter any problem running the project. 

Please follow these steps to contribute:

- Fork this repository and clone it to your local machine.
- Create a new branch with a descriptive name for your contribution.
- Add your code and files to the branch and commit your changes.
- Push your branch to your forked repository and create a pull request to the main repository.
- Wait for your pull request to be reviewed and merged.


## References

How does F1 telemetry work?
- https://www.youtube.com/watch?v=sW31u4gFFeE
- chainbear: https://www.youtube.com/watch?v=lfqkhCCq5sg 

AWS + F1 data analytics:
- https://www.youtube.com/watch?v=D7usPAR9a1k
- https://www.youtube.com/watch?v=vD-XDjg_Ta0

Data driven jobs in F1: 
- https://www.youtube.com/watch?v=lYkqQL0Tn3c


Redhat F1 telemetry + Kafka: https://www.youtube.com/watch?v=OkXlSb4vfDk
- https://www.youtube.com/watch?v=Re9LOAYZi2A
	
F1 telemetry + ADX Azure Data eXporer: 
- https://www.youtube.com/watch?v=--zaVHOh--I	

AWS: the fastest driver in Formula 1: 
- https://aws.amazon.com/blogs/machine-learning/the-fastest-driver-in-formula-1/

- https://masseyratings.com/theory/massey97.pdf

How Formula 1 Car Sensors Create Data at Every Turn: 
- https://blog.purestorage.com/perspectives/how-formula-1-car-sensors-create-data-at-every-turn/

Mobile Data Centers Bring Data to the Edge: 
- https://blog.purestorage.com/perspectives/in-formula-1-data-at-the-edge-brings-competitive-edge/

Activate the telemetry option from the game : 
- https://www.youtube.com/watch?v=fBnko8tWnPI

> ### "A lot of people criticize Formula 1 as an unnecessary risk. But what would life be like if we only did what is necessary?" - Niki Lauda
> 