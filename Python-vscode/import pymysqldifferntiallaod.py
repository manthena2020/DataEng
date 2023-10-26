import pymysql
import csv
from azure.storage.blob import BlobServiceClient
from datetime import datetime

# MySQL database connection parameters
host = 'localhost'
user = 'root'
password = 'root'
dbname = 'emp'

# Azure Blob Storage connection parameters
azure_storage_connection_string = 'DefaultEndpointsProtocol=https;AccountName=deeksha;AccountKey=6QM7mw4n5fnp+ls9XkeT15jkis42Uy5hpKYTVa1gYmI1x1Zd6RsQ2cvHMuAoVyvSHWKfF0qyFbTv+AStQUZRHA==;EndpointSuffix=core.windows.net'
container_name = 'ravi'  # Replace with the name of your container

# Function to fetch data from MySQL table
def fetch_data_from_mysql(table_name):
    connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    data = cursor.fetchall()
    connection.close()
    return data

# Function to upload data to Azure Blob Storage
def upload_data_to_azure(data, table_name):
    blob_service_client = BlobServiceClient.from_connection_string(azure_storage_connection_string)
    container_client = blob_service_client.get_container_client(container_name)
    blob_name = f'{table_name}.csv'
    
    with open(blob_name, 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerows(data)

    with open(blob_name, 'rb') as data:
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(data, overwrite=True)

# Function to update the last extraction timestamp for a table in the extraction_timestamps table
def update_last_extraction_timestamp(table_name, timestamp):
    try:
        connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
        cursor = connection.cursor()

        # Construct the SQL update query
        update_query = "INSERT INTO extraction_timestamps (table_name, last_update) VALUES (%s, %s) " \
                       "ON DUPLICATE KEY UPDATE last_update = VALUES(last_update)"
        cursor.execute(update_query, (table_name, timestamp))
        
        connection.commit()
        print(f"Updated timestamp for table {table_name}")
    except Exception as e:
        print(f'Error updating timestamp for table {table_name}: {str(e)}')
    finally:
        if connection:
            connection.close()

def main():
    try:
        # Connect to MySQL
        connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
        cursor = connection.cursor()

        # Get list of tables in the database
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()

        for table in tables:
            table_name = table[0]
            
            # Skip processing of specific tables (e.g., "extraction_timestamps")
            if table_name == "extraction_timestamps":
                continue
            
            print(f"Processing table: {table_name}")

            try:
                # Fetch data from the MySQL table (replace this with your data fetching logic)
                data = fetch_data_from_mysql(table_name)

                # Upload data to Azure Blob Storage (replace this with your data uploading logic)
                upload_data_to_azure(data, table_name)

                # Update the timestamp of the last extraction in extraction_timestamps table
                update_last_extraction_timestamp(table_name, datetime.now())

                print(f'Data from table {table_name} uploaded to Azure Blob Storage')
                print(f"Updated timestamp for table {table_name}")

            except Exception as e:
                print(f'Error processing table {table_name}: {str(e)}')

    except Exception as e:
        print(f'Error: {str(e)}')
    finally:
        connection.close()
if __name__ == "__main__":
    main()