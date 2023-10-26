import pymysql
import os
import csv
from google.cloud import storage
from datetime import datetime

# MySQL database connection parameters
host = 'localhost'
user = 'root'
password = 'root'
dbname = 'emp'

# Google Cloud Storage connection parameters
gcs_bucket_name = 'deeksha'  # Replace with your GCS bucket name
gcs_blob_prefix = 'ravi/'  # Replace with the desired prefix for GCS blobs

# Function to fetch data from MySQL table
def fetch_data_from_mysql(table_name):
    connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    data = cursor.fetchall()
    connection.close()
    return data

# Function to upload data to Google Cloud Storage
def upload_data_to_gcs(data, table_name):
    storage_client = storage.Client()
    bucket = storage_client.bucket(gcs_bucket_name)
    blob_name = f'{gcs_blob_prefix}{table_name}.csv'
    full_file_path = os.path.join('/', blob_name)
    
    with open(full_file_path, 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerows(data)

    blob = bucket.blob(blob_name)
    blob.upload_from_filename(full_file_path)

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
                # Fetch data from the MySQL table
                data = fetch_data_from_mysql(table_name)

                # Upload data to Google Cloud Storage
                upload_data_to_gcs(data, table_name)

                # Update the timestamp of the last extraction in extraction_timestamps table
                update_last_extraction_timestamp(table_name, datetime.now())

                print(f'Data from table {table_name} uploaded to Google Cloud Storage')
                print(f"Updated timestamp for table {table_name}")

            except Exception as e:
                print(f'Error processing table {table_name}: {str(e)}')

    except Exception as e:
        print(f'Error: {str(e)}')
    finally:
        connection.close()

if __name__ == "__main__":
    main()