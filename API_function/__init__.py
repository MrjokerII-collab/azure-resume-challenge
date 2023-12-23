import logging
import uuid
import json
from datetime import datetime
import azure.functions as func
from azure.data.tables import TableServiceClient
from azure.data.tables import TableClient
from azure.data.tables import UpdateMode

def conn_string():
    with open('API_function/config.json', 'r') as config_file:
        config_data = json.load(config_file)
        connection_string = config_data['database']['connectionString']
        return connection_string

connection_string = conn_string()
table="Visitors_count"
table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
connection_table = TableClient.from_connection_string(conn_str=connection_string, table_name=table)
partitionkey = "ID_01"
rowkey = "Visitors"
countkey = "Count"

def main(req: func.HttpRequest, message: func.Out[str]) -> func.HttpResponse:

    #recuperation de la valeur du champ Count
    entity_01 = connection_table.get_entity(partition_key=partitionkey, row_key=rowkey)
    current_count = entity_01[countkey]

    #incrementation de la valeur
    inc_count = current_count + 1
    entity_01[countkey] = inc_count 

    # Met à jour l'entité avec la nouvelle valeur de partition_key
    connection_table.update_entity(mode=UpdateMode.MERGE, entity=entity_01)

 
    return func.HttpResponse(f"{inc_count}")
