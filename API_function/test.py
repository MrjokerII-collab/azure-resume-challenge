import json
def conn_string():
    with open('config.json', 'r') as config_file:
        config_data = json.load(config_file)
        connection_string = config_data['database']['connectionString']
        return connection_string

test = conn_string()

print (test)