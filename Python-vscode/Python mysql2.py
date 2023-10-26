import mysql.connector
from prettytable import PrettyTable

# Replace with your Amazon RDS configuration
db_config = {
    'host': 'your-rds-endpoint.amazonaws.com',
    'user': 'your-rds-username',
    'password': 'your-rds-password',
    'database': 'your-database-name',
}

try:
    # Create a connection to the Amazon RDS instance
    connection = mysql.connector.connect(**db_config)

    if connection.is_connected():
        cursor = connection.cursor()

        # Define your SQL query
        query = "SELECT * FROM employees"

        # Execute the query
        cursor.execute(query)

        # Fetch all the rows
        records = cursor.fetchall()

        # Create a table with column names
        table = PrettyTable(cursor.column_names)

        # Add rows to the table
        for record in records:
            table.add_row(record)

        # Print the formatted table
        print(table)

except mysql.connector.Error as error:
    print(f"Error: {error}")

finally:
    if 'connection' in locals() and connection.is_connected():
        cursor.close()
        connection.close()
        print("MySQL connection is closed")