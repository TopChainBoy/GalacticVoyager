#!/bin/bash

# Ask the user for their current balance
while true; do
  echo "Enter your current balance in dollars:"
  read balance
  if [[ $balance =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$balance >= 0" | bc -l) )); then
    break
  else
    echo "Invalid input. Please enter a valid positive number."
  fi
done

# Ask the user for the distance they want to travel
while true; do
  echo "Enter the distance you want to travel:"
  read distance
  if [[ $distance =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$distance > 0" | bc -l) )); then
    break
  else
    echo "Invalid input. Please enter a valid positive number."
  fi
done

# Ask the user for the unit of distance
while true; do
  echo "Enter the unit of distance (1 for kilometers, 2 for miles):"
  read unit_choice
  if [[ $unit_choice == "1" || $unit_choice == "2" ]]; then
    break
  else
    echo "Invalid input. Please enter 1 for kilometers or 2 for miles."
  fi
done

# Convert the distance to kilometers if it was entered in miles
if [ "$unit_choice" == "2" ]; then
  distance=$(echo "scale=2; $distance * 1.60934" | bc)
fi

# Define an array with the order of keys
keys=("foot" "skateboard" "bike" "boat with paddles" "boat with gas engine" "boat with electric engine" "electric car" "gas car" "scooter" "bus" "train" "plane" "fighter jet" "aurora x1" "spacex rocket" "speed of light" "speed of light power of 10" "speed of light power of 1000")

# Ask the user for the mode of transportation
echo "Enter the mode of transportation (or 'all' for all modes):"
read mode_choice
if [[ $mode_choice != "all" && ! " ${keys[@]} " =~ " ${mode_choice} " ]]; then
  echo "Invalid input. Please enter a valid mode of transportation."
  exit 1
fi

# Define speeds for each mode of transportation
declare -A speeds
speeds=(["foot"]=5 ["skateboard"]=10 ["bike"]=20 ["boat with paddles"]=2 ["boat with gas engine"]=30 ["boat with electric engine"]=25 ["electric car"]=120 ["gas car"]=100 ["scooter"]=15 ["bus"]=60 ["train"]=200 ["plane"]=900 ["fighter jet"]=2200 ["aurora x1"]=15000 ["spacex rocket"]=28000 ["speed of light"]=1079252848.8 ["speed of light power of 10"]=10792528488 ["speed of light power of 1000"]=1079252848800)

# Define CO2 footprint for each mode of transportation in kg/km
declare -A co2_footprints
co2_footprints=(["foot"]=0 ["skateboard"]=0 ["bike"]=0 ["boat with paddles"]=0 ["boat with gas engine"]=0.15 ["boat with electric engine"]=0.05 ["electric car"]=0.04 ["gas car"]=0.2 ["scooter"]=0.02 ["bus"]=0.1 ["train"]=0.04 ["plane"]=0.25 ["fighter jet"]=2 ["aurora x1"]=10 ["spacex rocket"]=20 ["speed of light"]=0 ["speed of light power of 10"]=0 ["speed of light power of 1000"]=0)

# Define cost for each mode of transportation in $/km
declare -A costs
costs=(["foot"]=0 ["skateboard"]=0.01 ["bike"]=0.02 ["boat with paddles"]=0.1 ["boat with gas engine"]=0.5 ["boat with electric engine"]=0.3 ["electric car"]=0.05 ["gas car"]=0.07 ["scooter"]=0.03 ["bus"]=0.1 ["train"]=0.2 ["plane"]=0.15 ["fighter jet"]=100 ["aurora x1"]=10000 ["spacex rocket"]=50000 ["speed of light"]=0 ["speed of light power of 10"]=0 ["speed of light power of 1000"]=0)

# Function to convert time into the desired format
convert_time() {
  local time=$1
  local seconds=$((time%60))
  local minutes=$((time/60%60))
  local hours=$((time/3600%24))
  local days=$((time/86400%7))
  local weeks=$((time/604800%4))
  local months=$((time/2592000%12))
  local years=$((time/31536000%10))
  local decades=$((time/315360000%10))
  local centuries=$((time/3153600000%10))
  local millennia=$((time/31536000000))

  # Only print time units that are not zero
  [[ $millennia -ne 0 ]] && echo -n "$millennia millennia "
  [[ $centuries -ne 0 ]] && echo -n "$centuries centuries "
  [[ $decades -ne 0 ]] && echo -n "$decades decades "
  [[ $years -ne 0 ]] && echo -n "$years years "
  [[ $months -ne 0 ]] && echo -n "$months months "
  [[ $weeks -ne 0 ]] && echo -n "$weeks weeks "
  [[ $days -ne 0 ]] && echo -n "$days days "
  [[ $hours -ne 0 ]] && echo -n "$hours hours "
  [[ $minutes -ne 0 ]] && echo -n "$minutes minutes "
  [[ $seconds -ne 0 ]] && echo -n "$seconds seconds"
  echo
}

# Loop through the array and calculate the time for each mode of transportation
for mode in "${keys[@]}"; do
  speed=${speeds[$mode]}
  speed_mph=$(echo "scale=2; $speed / 1.60934" | bc)
  time=$(echo "scale=2; $distance / $speed" | bc)
  co2=$(echo "scale=2; $distance * ${co2_footprints[$mode]}" | bc)
  cost=$(echo "scale=2; $distance * ${costs[$mode]}" | bc)
  echo -e "Mode of transportation: \033[1;34m$mode\033[0m"
  echo -e "Speed: \033[1;32m$speed km/h ($speed_mph mph)\033[0m"
  
  # Convert time to seconds and then use the convert_time function
  time_seconds=$(echo "$time * 3600" | bc | cut -f1 -d.)
  if [[ $time_seconds -eq 0 ]]; then
    echo -e "Time to reach destination: \033[1;33m0 milliseconds\033[0m"
  else
    time_converted=$(convert_time $time_seconds)
    echo -e "Time to reach destination: \033[1;33m$time_converted\033[0m"
  fi
  echo -e "CO2 footprint: \033[1;31m$co2 kg\033[0m"
  echo -e "Cost: \033[1;35m$cost dollars\033[0m"
  # Check if the user has enough balance to afford the cost
  if (( $(echo "$balance < $cost" | bc -l) )); then
    echo -e "\033[1;31mYou do not have enough balance to afford this mode of transportation.\033[0m"
    continue
  fi
  echo
done
echo "Note: Costs include energy, gas and food."
echo "CO2 footprint and cost values are just approximations."
