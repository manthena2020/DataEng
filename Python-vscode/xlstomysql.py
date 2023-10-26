import pandas as pd
import mysql.connector

df = pd.read_excel('C:\\data\\marchapril.xlsx')
print(df.columns)
connection = mysql.connector.connect(host='127.0.0.1', user='root', password='root', database='share')
cursor = connection.cursor()
query = 'INSERT INTO sharedata(SYMBOL, SERIES, OPEN, HIGH, LOW, CLOSE, LAST, PREVCLOSE, TOTTRDQTY, TOTTRDVAL, TIMESTAMP, TOTALTRADES) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)'
for row in df.itertuples():
    cursor.execute(query, (row.SYMBOL, row.SERIES, row.OPEN, row.HIGH, row.LOW, row.CLOSE, row.LAST, row.PREVCLOSE, row.TOTTRDQTY, row.TOTTRDVAL, row.TIMESTAMP.strftime('%Y-%m-%d %H:%M:%S'), row.TOTALTRADES))
    connection.commit()