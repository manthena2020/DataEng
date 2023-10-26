import pymysql
import pyarrow as pa
import pyarrow.parquet as pq
from azure.storage.blob import BlobServiceClient
from datetime import datetime
import pandas as pd

# MySQL database connection parameters
host = 'localhost'
user = 'root'
password = 'root'
dbname = 'emp'

# Azure Blob Storage connection parameters
azure_storage_connection_string = 'DefaultEndpointsProtocol=https;AccountName=YOUR_ACCOUNT_NAME;AccountKey=YOUR_ACCOUNT_KEY;EndpointSuffix=core.windows.net'
container_name = 'ravi'  # Replace with the name of your container

# Function to fetch data from MySQL table
def fetch_data_from_mysql(table_name, cursor):
    cursor.execute(f"SELECT * FROM {table_name}")
    data = cursor.fetchall()
    return data

# Function to upload data to Azure Blob Storage as Parquet
def upload_data_to_azure_parquet(data, table_name):
    try:
        # Convert the data to a Pandas DataFrame
        df = pd.DataFrame(data)

        # Ensure that column names are strings
        df.columns = df.columns.map(str)

        # Define the Parquet file path
        parquet_file_path = f'{table_name}.parquet'

        # Write the Pandas DataFrame to Parquet format
        df.to_parquet(parquet_file_path)

        # Upload the Parquet file to Azure Blob Storage
        blob_service_client = BlobServiceClient.from_connection_string(azure_storage_connection_string)
        container_client = blob_service_client.get_container_client(container_name)
        blob_client = container_client.get_blob_client(parquet_file_path)
        with open(parquet_file_path, 'rb') as data:
            blob_client.upload_blob(data, overwrite=True)

        print(f'Data from table {table_name} uploaded to Azure Blob Storage as Parquet')
    except Exception as e:
        print(f'Error uploading data for table {table_name}: {str(e)}')

# Function to update the last extraction timestamp for a table in the extraction_timestamps table
def update_last_extraction_timestamp(table_name, timestamp, cursor):
    try:
        # Construct the SQL update query
        update_query = "INSERT INTO extraction_timestamps (table_name, last_update) VALUES (%s, %s) " \
                       "ON DUPLICATE KEY UPDATE last_update = VALUES(last_update)"
        cursor.execute(update_query, (table_name, timestamp))
        print(f"Updated timestamp for table {table_name}")
    except Exception as e:
        print(f'Error updating timestamp for table {table_name}: {str(e)}')

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
                # Fetch data from the MySQL table
                data = fetch_data_from_mysql(table_name, cursor)
                print(f"Data fetched for table: {table_name}")

                # Upload data to Azure Blob Storage as Parquet
                upload_data_to_azure_parquet(data, table_name)

                # Update the timestamp of the last extraction in extraction_timestamps table
                update_last_extraction_timestamp(table_name, datetime.now(), cursor)

            except Exception as e:
                print(f'Error processing table {table_name}: {str(e)}')

    except Exception as e:
        print(f'Error: {str(e)}')
    finally:
        connection.close()

if __name__ == "__main__":
    main()