import mysql.connector
from prettytable import PrettyTable
db_config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'root',
    'database': 'emp',
}  
connection = mysql.connector.connect(**db_config)
if connection.is_connected():
        cursor = connection.cursor()
        query1 = "use share" 
        cursor.execute(query1) 
        query2 = " SELECT * from sharedata "      
        cursor.execute(query2)      
        records = cursor.fetchall()     
        table = PrettyTable(cursor.column_names)
        for record in records:
            table.add_row(record)
        print(table)
        print(" Table Retrived Sucessfull")
        cursor.close()
        connection.close()
else:
        cursor.close()
        connection.close()
        print("Not Sucessfull")

 
