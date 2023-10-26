import findspark
findspark.init()

# Creating a SparkSession: A SparkSession is the entry point for using the PySpark DataFrame and SQL API.
# To create a SparkSession, use the following code
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("PySpark 101 Exercises").getOrCreate()

# Get version details
print(spark.version)
