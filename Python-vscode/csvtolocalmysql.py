import pandas as pd
import mysql.connector

# Define MySQL connection parameters
db_config = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "root",
    "database": "share"
}

# CSV file path and table name
csv_file_path = "C:\\data\\marchdata.csv"
table_name = "sharedata"

# Read the CSV file into a DataFrame
df = pd.read_csv(csv_file_path)

# Define the SQL data types for each column
column_data_types = {
    "SYMBOL": "VARCHAR(255)",
    "SERIES": "VARCHAR(255)",
    "OPEN": "DECIMAL(10, 2)",
    "HIGH": "DECIMAL(10, 2)",
    "LOW": "DECIMAL(10, 2)",
    "CLOSE": "DECIMAL(10, 2)",
    "LAST": "DECIMAL(10, 2)",
    "PREVCLOSE": "DECIMAL(10, 2)",
    "TOTTRDQTY": "INT",
    "TOTTRDVAL": "DECIMAL(10, 2)",
    "TIMESTAMP": "TIMESTAMP",
    "TOTALTRADERS": "INT"
}

# Establish a connection to the MySQL database
try:
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()

    # Create the table if it doesn't exist
    create_table_query = f"CREATE TABLE IF NOT EXISTS {table_name} ("
    for column_name, data_type in column_data_types.items():
        create_table_query += f"{column_name} {data_type}, "
    create_table_query = create_table_query.rstrip(", ") + ");"
    
    cursor.execute(create_table_query)

    # Insert data from the DataFrame into the MySQL table
    for _, row in df.iterrows():
        insert_query = f"INSERT INTO {table_name} ({', '.join(df.columns)}) VALUES ({', '.join(['%s']*len(df.columns))});"
        cursor.execute(insert_query, tuple(row))

    # Commit the changes and close the connection
    connection.commit()
    print("Data transferred successfully.")

except mysql.connector.Error as error:
    print(f"Error: {error}")

finally:
    if connection.is_connected():
        cursor.close()
        connection.close()