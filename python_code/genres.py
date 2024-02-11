"""This code creates the 'genres' dataset"""

# Importing the required libraries
import json
import configparser
import pandas as pd
from requests import post

# Importing credentials to access the API
config = configparser.ConfigParser()
config.read('config.cfg')
access_token = config.get('Credentials', 'access_token')
client_id = config.get('Credentials', 'client_id')

# Using the requests library to gather data from the IGDB API
data = post('https://api.igdb.com/v4/genres',
            **{'headers': {'Client-ID': client_id, 'Authorization': f'Bearer {access_token}'},
               'data': """fields name;
                          sort id asc;
                          limit 50;"""}, timeout=10)

# Transforming the data into a json file
data = str(data.json()).replace("\'", "\"")
data = json.loads(data)

# Loading the json file into a Pandas data frame
data = pd.json_normalize(data)

# Exporting the data frame to a csv file
data.to_csv("genres.csv")
