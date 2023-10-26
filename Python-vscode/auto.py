import pymysql
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

# MySQL database connection parameters
host = 'localhost'
user = 'root'
password = 'root'
dbname = 'emp'

# Azure Blob Storage connection parameters
azure_storage_connection_string = 'DefaultEndpointsProtocol=https;AccountName=deeksha;AccountKey=/y6A1hM79tMRvwAxDXf5HFyL00fCC1A3A3jHGbnLNGsKAGTq7+ybBeD/kqEaf/bSvzBA6hYivK+H+ASt5fTaHA==;EndpointSuffix=core.windows.net'
container_name = 'ravi'  # Replace with your container name
blob_name = 'ravi2'    # Replace with the desired blob name

# Connect to MySQL
try:
    connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
    cursor = connection.cursor()

    # Execute SQL query to fetch data from MySQL
    cursor.execute("SELECT * from department")  # Replace with your table name
    data = cursor.fetchall()

    # Close MySQL connection
    connection.close()

    # Save data to a CSV file
    with open('data_from_mysql.csv', 'w') as file:
        for row in data:
            file.write(','.join(map(str, row)) + '\n')

    # Upload the CSV file to Azure Blob Storage
    blob_service_client = BlobServiceClient.from_connection_string(azure_storage_connection_string)
    container_client = blob_service_client.get_container_client(container_name)
    blob_client = container_client.get_blob_client(blob_name)

    with open('data_from_mysql.csv', 'rb') as data:
        blob_client.upload_blob(data)

    print(f'Data from MySQL has been uploaded to Azure Blob Storage as {blob_name}')

except Exception as e:
    print(f'Error: {str(e)}')