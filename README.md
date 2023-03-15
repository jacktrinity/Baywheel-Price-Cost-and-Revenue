# Baywheel-Price-Cost-and-Revenue

Contained all Baywheel dataset from 2020 to 2021 from offical website:
https://www.lyft.com/bikes/bay-wheels/system-data

Dataset were joined using Panda dataframe in Python
Then uploaded PostgreSQL database using SQLAlchemy

SQL scripts
1. Get the value of each ride cost by converting ride duration to cost using their rate.
2. Get the revenue by month and year using the table from the first SQL script.
