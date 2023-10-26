import pymysql
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
gcs_blob_prefix = 'ravi/'    # Replace with the desired prefix for GCS blobs

# Function to fetch data from MySQL table
def fetch_data_from_mysql(table_name):
    connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    data = cursor.fetchall()
    connection.close()
    return data

# Function to upload data to Google Cloud Storage with headers
def upload_data_to_gcs_with_headers(data, table_name):
    # Add headers as the first row
    headers = [column[0] for column in cursor.description]
    data_with_headers = [headers] + data

    # Initialize a GCS client
    storage_client = storage.Client()
    bucket = storage_client.bucket(gcs_bucket_name)
    blob_name = f'{gcs_blob_prefix}{table_name}.csv'

    # Create a temporary CSV file
    temp_file_path = "/tmp/temp.csv"
    with open(temp_file_path, 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerows(data_with_headers)

    # Upload the temporary CSV file to GCS
    blob = bucket.blob(blob_name)
    blob.upload_from_filename(temp_file_path)

    # Delete the temporary file
    os.remove(temp_file_path)

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

                # Upload data to Google Cloud Storage with headers
                upload_data_to_gcs_with_headers(data, table_name)

                print(f'Data from table {table_name} uploaded to Google Cloud Storage')

            except Exception as e:
                print(f'Error processing table {table_name}: {str(e)}')

    except Exception as e:
        print(f'Error: {str(e)}')
    finally:
        if connection:
            connection.close()

if __name__ == "_main_":
    main()