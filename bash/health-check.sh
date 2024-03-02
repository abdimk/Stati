#!/bin/bash


# DON'T TOUCH OLD STUFF!
# DON'T MESS WITH THIS !
# mybe i will use it in the future God know!
#



commit=true
origin=$(git remote get-url origin)
# Adjust the condition based on the actual origin URL
if [[ $origin == *abdimk/Stati* ]]; then
  commit=false
fi

KEYSARRAY=()
URLSARRAY=()

urlsConfig="./urls.cfg"
echo "Reading $urlsConfig"
# Check if the file exists before reading it
if [ ! -f "$urlsConfig" ]; then
  echo "Error: $urlsConfig does not exist."
  exit 1
fi

# Read URLs from the configuration file
while IFS='=' read -r key url; do
  echo "  $key=$url"
  KEYSARRAY+=("$key")
  URLSARRAY+=("$url")
done < "$urlsConfig"

echo "***********************"
echo "Starting health checks with ${#KEYSARRAY[@]} configs:"

mkdir -p logs || { echo "Error: Unable to create logs directory"; exit 1; }

for (( index=0; index < ${#KEYSARRAY[@]}; index++)); do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"
  echo "  $key=$url"

  for i in 1 2 3 4; do
    # Use double quotes around variables to prevent issues with spaces or special characters in URLs
    response=$(curl --write-out '%{http_code}' --silent --output /dev/null "$url")
    if [[ "$response" -eq 200 || "$response" -eq 202 || "$response" -eq 301 || "$response" -eq 302 || "$response" -eq 307 ]]; then
      result="success"
      break
    else
      result="failed"
      sleep 5
    fi
  done
  
  dateTime=$(date +'%Y-%m-%d %H:%M')
  if [[ $commit == true ]]; then
    echo "$dateTime, $result" >> "logs/${key}_report.log"
    # Limit the log file to 2000 lines
    tail -n 2000 "logs/${key}_report.log" > "logs/${key}_report_temp.log"
    mv "logs/${key}_report_temp.log" "logs/${key}_report.log"
  else
    echo "    $dateTime, $result"
  fi
done

if [[ $commit == true ]]; then
  # Set local Git user name and email
  git config --local user.name 'abdimk'
  git config --local user.email 'abdisamk@gmail.com'
  # Add and commit logs
  git add -A --force logs/ && \
  git commit -m '[Automated] Update Health Check Logs' && \
  git push || { echo "Error: Failed to commit and push changes."; exit 1; }
fi










































# # In the original repository we'll just print the result of status checks,
# # without committing. This avoids generating several commits that would make
# # later upstream merges messy for anyone who forked us.
# commit=true
# origin=$(git remote get-url origin)
# # if [[ $origin == *statsig-io/statuspage* ]]
# if [[ $origin == *abdimk/Stati* ]]
# then
#   commit=false
# fi

# KEYSARRAY=()
# URLSARRAY=()

# urlsConfig="./urls.cfg"
# echo "Reading $urlsConfig"
# while read -r line
# do
#   echo "  $line"
#   IFS='=' read -ra TOKENS <<< "$line"
#   KEYSARRAY+=(${TOKENS[0]})
#   URLSARRAY+=(${TOKENS[1]})
# done < "$urlsConfig"

# echo "***********************"
# echo "Starting health checks with ${#KEYSARRAY[@]} configs:"

# mkdir -p logs

# for (( index=0; index < ${#KEYSARRAY[@]}; index++))
# do
#   key="${KEYSARRAY[index]}"
#   url="${URLSARRAY[index]}"
#   echo "  $key=$url"

#   for i in 1 2 3 4; 
#   do
#     response=$(curl --write-out '%{http_code}' --silent --output /dev/null $url)
#     if [ "$response" -eq 200 ] || [ "$response" -eq 202 ] || [ "$response" -eq 301 ] || [ "$response" -eq 302 ] || [ "$response" -eq 307 ]; then
#       result="success"
#     else
#       result="failed"
#     fi
#     if [ "$result" = "success" ]; then
#       break
#     fi
#     sleep 5
#   done
#   dateTime=$(date +'%Y-%m-%d %H:%M')
#   if [[ $commit == true ]]
#   then
#     echo $dateTime, $result >> "logs/${key}_report.log"
#     # By default we keep 2000 last log entries.  Feel free to modify this to meet your needs.
#     echo "$(tail -2000 logs/${key}_report.log)" > "logs/${key}_report.log"
#   else
#     echo "    $dateTime, $result"
#   fi
# done

# if [[ $commit == true ]]
# then
#   # Let's make Vijaye the most productive person on GitHub.
#   git config --local user.name 'abdimk'
#   git config --local user.email 'abdisamk@gmail.com' 
#   git add -A --force logs/
#   git add .
#   git commit -am '[Automated] Update Health Check Logs'
#   git push
# fi
