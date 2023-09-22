# create a code that reads AX.sqlite sqlite file and converts it into JSON format
# and saves it in a file called AX.json

import sqlite3
import json

conn = sqlite3.connect('AX.sqlite')
cur = conn.cursor()

# print list of tables and records in each
cur.execute('SELECT name FROM sqlite_master WHERE type="table"')
print(cur.fetchall())
# get tag table data
cur.execute('SELECT * FROM tag')
tags = cur.fetchall()
# get timestamp of each 'Col' tag
cur.execute('SELECT datetime FROM tag WHERE meta="Col"')
collisions = cur.fetchall()
cur.execute('SELECT datetime FROM tag WHERE meta="Axel"')
accelerations = cur.fetchall()

# get last 50 axelerometer data before each timestamp
col_data = {}
for timestamp in collisions:
    cur.execute('SELECT * FROM axelerometer WHERE datetime <= ? LIMIT 50', timestamp)
    col_data[timestamp[0]] = cur.fetchall()

# the same for accelerations
acc_data = {}
for timestamp in accelerations:
    cur.execute('SELECT * FROM axelerometer WHERE datetime <= ? LIMIT 50', timestamp)
    acc_data[timestamp[0]] = cur.fetchall()


# save data into C folder. For each data create csv file. Create 3 columns named x, y, z. Save data in each column
for timestamp in collisions:
    with open('C/' + str(timestamp[0]) + '.csv', 'w') as f:
        f.write('x,y,z\n')
        for row in col_data[timestamp[0]]:
            f.write(str(row[1]) + ',' + str(row[2]) + ',' + str(row[3]) + '\n')

# the same for accelerations
for timestamp in accelerations:
    with open('A/' + str(timestamp[0]) + '.csv', 'w') as f:
        f.write('x,y,z\n')
        for row in acc_data[timestamp[0]]:
            f.write(str(row[1]) + ',' + str(row[2]) + ',' + str(row[3]) + '\n')


cur.close()
conn.close()
