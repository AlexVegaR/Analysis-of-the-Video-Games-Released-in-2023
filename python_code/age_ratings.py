"""This code creates the 'age-ratings' dataset"""

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
data = post('https://api.igdb.com/v4/games',
            **{'headers': {'Client-ID': client_id, 'Authorization': f'Bearer {access_token}'},
               'data': """fields age_ratings.category, age_ratings.rating;
                          where age_ratings.category = 1
                          & aggregated_rating > 0
                          & first_release_date > 1672531199
                          & first_release_date < 1704067200
                          & game_modes != null
                          & genres != null
                          & name != null
                          & platforms != null
                          & status = null
                          & themes != null
                          & version_parent = null
                          & category = (0, 3, 8, 9, 10, 11);
                          sort first_release_date asc;
                          limit 500;"""}, timeout=10)

# Transforming the data into a json file
data = str(data.json()).replace("\'", "\"")
data = json.loads(data)

# Loading the json file into a Pandas data frame
data = pd.json_normalize(data)

# Exporting the data frame to a csv file
data.to_csv("age-ratings.csv")
