import os
import azure.functions as func
from azure.data.tables import TableServiceClient
from azure.data.tables import TableClient
from azure.data.tables import UpdateMode
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

#connection to cosmosdb
def get_secret():
    keyVaultName = os.getenv("KEY_VAULT_NAME")
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=KVUri, credential=credential)
    secretcreds = "Connectionstringdb"
    retrieved_secret = client.get_secret(secretcreds)
    connection_string = retrieved_secret.value
    return connection_string

connection_string = get_secret()
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
