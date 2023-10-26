import pymysql
from csv import QUOTE_MINIMAL, DictWriter
import csv
from azure.storage.blob import BlobServiceClient, ContainerClient

# MySQL database connection parameters
host = 'localhost'
user = 'root'
password = 'root'
dbname = 'awesome chocolates'

# Azure Blob Storage connection parameters
azure_storage_connection_string = 75d0cfea8ad923ce636e783208576b2eee4860a5
dbname = 'emp'

# Azure Blob Storage connection parameters
azure_storage_connection_string = 'DefaultEndpointsProtocol=https;AccountName=deeksha;AccountKey=/y6A1hM79tMRvwAxDXf5HFyL00fCC1A3A3jHGbnLNGsKAGTq7+ybBeD/kqEaf/bSvzBA6hYivK+H+ASt5fTaHA==;EndpointSuffix=core.windows.net'
container_name = 'ravi'  # Replace with the name of your container

try:
    # Connect to MySQL
    connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
    cursor = connection.cursor()

    # Initialize Azure Blob Storage client
    blob_service_client = BlobServiceClient.from_connection_string(azure_storage_connection_string)
    container_client = blob_service_client.get_container_client(container_name)

    # Get list of tables in the database
    cursor.execute("SHOW TABLES")
    tables = cursor.fetchall()

    for table in tables:
        table_name = table[0]

        # Execute SQL query to fetch data from the table
        cursor.execute(f"SELECT * FROM {table_name}")
        data = cursor.fetchall()

        # Generate a unique CSV file name for each table
        csv_filename = f'{table_name}.csv'

        # Save data to a CSV file
        with open(csv_filename, 'w', newline='') as file:
            csv_writer = csv.writer(file)
            csv_writer.writerows(data)

        # Upload the CSV file to Azure Blob Storage
        blob_client = container_client.get_blob_client(csv_filename)
        with open(csv_filename, 'rb') as data:
            blob_client.upload_blob(data)

        print(f'Data from table {table_name} has been uploaded to Azure Blob Storage')

except Exception as e:
    print(f'Error: {str(e)}')
finally:
    connection.close()