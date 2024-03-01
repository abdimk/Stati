import os
import time
import requests as req
from pathlib import Path
from datetime import datetime


# Get the current date and time
current_datetime = datetime.now()

# Format the datetime object into the desired format
formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M")

default_folder_path = Path('./logs')


def create(filepath):
    urls = {}

    with open(filepath, 'r') as file:
        read = file.readlines()
    for i in range(0, len(read)):
        urls[read[i].split('=')[0]] = read[i].split('=')[1]

    for key, item in urls.items():
        with open(f'{key}_report.log', 'w') as file:
            pass
        print(f'creating {key}.log file')


if not default_folder_path.exists():
    default_folder_path.mkdir(parents=True, exist_ok=True)
    print("Created 'logs' folder.")
    current_directory = Path.cwd()
    log_dir = current_directory / 'logs'
    os.chdir(log_dir)
    create(f'../urls.cfg')

# Check if 'logs' folder exists and contains files with .log extension
elif default_folder_path.is_dir():
    log_files = list(default_folder_path.glob('*.log'))
    if log_files:
        print(f"The 'logs' folder contains {len(log_files)} log files.")
        links = {}
        mylink = []
        with open('urls.cfg', 'r') as file:
            read = file.readlines()
            for i in range(0, len(read)):
                links[read[i].split('=')[0]] = read[i].split('=')[1]

            for key, item in links.items():
                mylink.append(item)
    else:
        print("The logs folder exist but no log files")
        current_directory = Path.cwd()
        log_dir = current_directory / 'logs'
        os.chdir(log_dir)
        create(f'../urls.cfg')

event = {200: 'success',
         400: 'partial',
         204: 'No Content',
         403: 'Forbidden',
         500: 'Internal Server Error',
         0: 'nodata'}


def append_to_file(file_path, content, status):
    print(formatted_datetime+',' + event[status]+'\n')
    with open(file_path, 'r+') as file:
        original_content = file.read()
        file.seek(0)  # Move the file pointer to the beginning
        # Write the new content to the beginning
        file.write(f'{formatted_datetime}, {event[status]}\n')
        # Write the original content after the new content
        file.write(original_content)

        # file.write(f'{formatted_datetime}, {event[status]}\n')


# log_files = list(default_folder_path.glob('*.log'))
# for log_file in log_files:
#     print(log_file.name)
links = {}
try:
    with open('urls.cfg', 'r') as file:
        read = file.readlines()
        for i in range(0, len(read)):
            links[read[i].split('=')[0]] = read[i].split('=')[1]
except Exception as r:
    print('run it agin once')


current_directory = Path.cwd()
log_dir = current_directory / 'logs'
os.chdir(log_dir)
print(Path.cwd())

for key, link in links.items():
    try:
        print(f'\nUrl: {link.strip()}')
        myrequest = req.get(url=str(link.strip()), timeout=5)

        print(f'Status:{myrequest.status_code}')
        response_time = myrequest.elapsed.total_seconds() * 1000
        print(f'Response Time: {round(response_time)}ms')

        append_to_file(f'{key}_report.log', 'w', int(myrequest.status_code))

    except Exception as error:
        print(f'Status: bad request')
        append_to_file(f'{key}_report.log', 'w', 0)

    time.sleep(1)
print(Path.cwd())
