#!/bin/bash

# Ask the user for the distance to the destination
echo "Enter the distance to your destination:"
read distance

# Ask the user for the unit of the distance
echo "Is the distance in 1) km or 2) miles? (Enter '1' or '2')"
read unit_choice

# Convert the distance to kilometers if it was entered in miles
if [ "$unit_choice" == "2" ]; then
  distance=$(echo "scale=2; $distance * 1.60934" | bc)
fi

# Define an array with the order of keys
keys=("foot" "skateboard" "bike" "boat" "car" "train" "plane" "fighter jet" "aurora x1" "spacex rocket" "speed of light" "speed of light power of 10" "speed of light power of 1000")

# Define speeds for each mode of transportation
declare -A speeds
speeds=(["foot"]=5 ["skateboard"]=10 ["bike"]=20 ["boat"]=30 ["car"]=100 ["train"]=200 ["plane"]=900 ["fighter jet"]=2200 ["spacex rocket"]=28000 ["aurora x1"]=15000 ["speed of light"]=1079252848.8 ["speed of light power of 10"]=10792528488 ["speed of light power of 1000"]=1079252848800)

# Define CO2 footprint for each mode of transportation in kg/km
declare -A co2_footprints
co2_footprints=(["foot"]=0 ["skateboard"]=0 ["bike"]=0 ["boat"]=0.15 ["car"]=0.12 ["train"]=0.04 ["plane"]=0.25 ["fighter jet"]=2 ["aurora x1"]=10 ["spacex rocket"]=20 ["speed of light"]=0 ["speed of light power of 10"]=0 ["speed of light power of 1000"]=0)

# Define cost for each mode of transportation in $/km
declare -A costs
costs=(["foot"]=0 ["skateboard"]=0.01 ["bike"]=0.02 ["boat"]=0.5 ["car"]=0.1 ["train"]=0.2 ["plane"]=0.15 ["fighter jet"]=100 ["aurora x1"]=10000 ["spacex rocket"]=50000 ["speed of light"]=0 ["speed of light power of 10"]=0 ["speed of light power of 1000"]=0)

# Loop through the array and calculate the time for each mode of transportation
for mode in "${keys[@]}"; do
  speed=${speeds[$mode]}
  speed_mph=$(echo "scale=2; $speed / 1.60934" | bc)
  time=$(echo "scale=2; $distance / $speed" | bc)
  co2=$(echo "scale=2; $distance * ${co2_footprints[$mode]}" | bc)
  cost=$(echo "scale=2; $distance * ${costs[$mode]}" | bc)
  echo -e "Mode of transportation: \033[1;34m$mode\033[0m"
  echo -e "Speed: \033[1;32m$speed km/h ($speed_mph mph)\033[0m"
  
  # If time is less than 1 hour, convert it to minutes. If it's less than 1 minute, convert it to seconds. If it's less than 1 second, convert it to milliseconds.
  if (( $(echo "$time < 1" | bc -l) )); then
    time=$(echo "scale=2; $time * 60" | bc)
    if (( $(echo "$time < 1" | bc -l) )); then
      time=$(echo "scale=2; $time * 60" | bc)
      if (( $(echo "$time < 1" | bc -l) )); then
        time=$(echo "scale=2; $time * 1000" | bc)
        echo -e "Time to reach destination: \033[1;33m$time milliseconds\033[0m"
      else
        echo -e "Time to reach destination: \033[1;33m$time seconds\033[0m"
      fi
    else
      echo -e "Time to reach destination: \033[1;33m$time minutes\033[0m"
    fi
  else
    echo -e "Time to reach destination: \033[1;33m$time hours\033[0m"
  fi
  
  echo -e "CO2 footprint: \033[1;31m$co2 kg\033[0m"
  echo -e "Cost: \033[1;35m$cost dollars\033[0m"
  echo
done
echo "Note: Costs include energy, gas and food."
echo "CO2 footprint and cost values are just approximations."
