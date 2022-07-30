# Overview 

Formula 1 (F1) Telemetry dashboard for real-time data analysis and visualization 

Telemetry enables recording data in real-time thanks to various sensors present within the car and transmit(throught wireless system) to the pitwall to be analysed by the Engineers/race strategists

## Data Acquisition 

F1 car has around 300 sensors (in average) that exchange data of ~3-4 GB/s (1.5k data points)
- control sensors : accelerator pedal sensor  ...
- monitoring sensors : hydraulic system pressure...
- instrumentation sensors : pressure and fuel flow sensors ...

## data sources :
- Primary stage : data will come from a static source like : csv file ou db ...
- Secondary stage (of the rocket) : the data will be transmitter from a F1 simulator like psp/xbox game or mobile games via UDP telemetry. 
- Playload : Run this with a (real) F1 car !!!

# Requirements : 
Data sources : 
- UDP Telemetry (psp/xbox/mobile F1 racing game)
Data Wrangling  ? 
- python
Data ingestion : 
- kafka ? 
- apache spark ? 
- adx ? 
Data viz
- Grafana ? 

# Usage

Just run the notebook after you got all the tool above installed

# Contribution 

- Feel free to pull request if you have an addictional fun ideas !


# References

F1 :
how does F1 telemetry work : https://www.youtube.com/watch?v=sW31u4gFFeE
chainbear : https://www.youtube.com/watch?v=lfqkhCCq5sg

AWS + F1 data analytics :
https://www.youtube.com/watch?v=D7usPAR9a1k
https://www.youtube.com/watch?v=vD-XDjg_Ta0

Data driven jobs in F1 : 
https://www.youtube.com/watch?v=lYkqQL0Tn3c


redhat F1 telemetry + Kafka : https://www.youtube.com/watch?v=OkXlSb4vfDk
	https://www.youtube.com/watch?v=Re9LOAYZi2A
	
F1 telemetry + ADX (Azure Data eXporer : https://www.youtube.com/watch?v=--zaVHOh--I	

AWS : the fastest driver in Formula 1 : 
https://aws.amazon.com/blogs/machine-learning/the-fastest-driver-in-formula-1/

- https://masseyratings.com/theory/massey97.pdf

How Formula 1 Car Sensors Create Data at Every Turn : 
https://blog.purestorage.com/perspectives/how-formula-1-car-sensors-create-data-at-every-turn/
Mobile Data Centers Bring Data to the Edge : 
https://blog.purestorage.com/perspectives/in-formula-1-data-at-the-edge-brings-competitive-edge/

Activate the telemetry option from the game : 
https://www.youtube.com/watch?v=fBnko8tWnPI

#### <q> A lot of people criticize Formula 1 as an unnecessary risk. But what would life be like if we only did what is necessary ? </q>