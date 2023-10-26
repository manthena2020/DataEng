import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
import pymysql
import csv
from google.cloud import storage
from datetime import datetime

class ExtractAndUploadToGCS(beam.DoFn):
    def process(self, element):
        table_name = element
        data = fetch_data_from_mysql(table_name)
        upload_data_to_gcs(data, table_name)
        update_last_extraction_timestamp(table_name, datetime.now())
        return [table_name]

def fetch_data_from_mysql(table_name):
    def fetch_data_from_mysql(table_name):
    connection = pymysql.connect(host=host, user=user, password=password, db=dbname)
    cursor = connection.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    data = cursor.fetchall()
    connection.close()
    return data


def upload_data_to_gcs(data, table_name):
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

def update_last_extraction_timestamp(table_name, timestamp):
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


def run():
    options = PipelineOptions()
    options.view_as(SetupOptions).save_main_session = True

    with beam.Pipeline(options=options) as p:
        tables = p | "Read Tables" >> beam.Create(["table1", "table2"])  # Replace with a query to fetch table names
        processed_tables = tables | "Process Tables" >> beam.ParDo(ExtractAndUploadToGCS())

if __name__== '_main_':
    run()