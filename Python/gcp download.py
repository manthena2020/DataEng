import subprocess
from google.cloud import storage

# Set the MySQL database credentials
db_user = "root"
db_password = "Aditya908"
db_host = "zeyodb.cz7qhc39aphp.ap-south-1.rds.amazonaws.com"
db_name = "zeyodb"
table_name = "salesdata"

# Use the mysqldump command to export the MySQL data to a file
dump_command = f"mysqldump -u {db_user} -p{db_password} -h {db_host} {db_name} {table_name} > {table_name}.sql"
subprocess.run(dump_command, shell=True, check=True)

# Upload the file to the GCP Storage bucket
storage_client = storage.Client()
bucket_name = "your-bucket-name"
bucket = storage_client.bucket(bucket_name)
blob = bucket.blob(f"{table_name}.sql")
blob.upload_from_filename(f"{table_name}.sql")
