import mysql.connector

#establish connection via socket to server, assign a database
mydb = mysql.connector.connect(
    host = "localhost",
    user= "root",
    password = "mypassword", #password must be changed accordingly
    database = "e-propertiesdb"
)

mycursor = mydb.cursor()    #create parsing cursor
#if database is unknown, check the server's databases and manually copy-paste the name of the database shown that you want to access
# mycursor.execute("SHOW DATABASES")
# for x in mycursor:
#     print(x)

#Same as with databases, if tables are unknown, check the db's tables
# mycursor.execute("SHOW TABLES")
# for x in mycursor:
#     print(x)

#To send a SELECT query to the db, simply write it inline as a character string
#mycursor.execute("SELECT p.propid, p.address FROM property AS p, region AS r, evaluation AS e WHERE p.location = r.regid AND r.avg_inc> 40000 AND p.propid = e.prop_id AND e.est_date BETWEEN '2020-12-24' AND '2020-12-31';")

#Alternative SQL queries. To create a multiple line string use """\ at start and """ at the end
myquery = """\
SELECT *
FROM region;"""
#myvals = ()
mycursor.execute(myquery)

#Fetch the table returned by executing myquery in the MySQL server. Table in this case contains all regions
regions = mycursor.fetchall()

#Print to check correctly fetched data
print("Region IDs, Regions, Population, AVG Inc")
for x in regions:
    print(x)

myquery = """\
SELECT * 
FROM evaluation
WHERE YEAR(evaluation.est_date) = %s;
"""
myvals = ("2020",) #separate tuple for explicit values to avoid SQL injection
mycursor.execute(myquery,myvals)

#Fetch the table returned by executing myquery in the MySQL server. Table in this case contains all evaluations in the year 2020
evaluations = mycursor.fetchall()

print("Evaluations:")
for x in evaluations:
    print(x)

myquery = """\
SELECT DISTINCT p.*
FROM property as p, evaluation as e
WHERE p.propid = e.prop_id AND YEAR(e.est_date) = %s;
"""
myvals = ("2020",) #separate tuple for explicit values to avoid SQL injection
mycursor.execute(myquery,myvals)

#Fetch the table returned by executing myquery in the MySQL server. Table in this case contains all properties evaluated in the year 2020
properties = mycursor.fetchall()

print("Properties:")
for x in properties:
    print(x)

#Database socket is shut down to minimize connection time
mycursor.close()

#From now on, only python and list processing is used to create the end result:
result = list()
totalpop = 0
for x in regions:           #store all region IDs into newly created list of lists
    result.append([x[0]])
    totalpop += x[2]        #calculate total population of all regions

for x in range(0,len(regions)): #for each region, calculate its' population as a % of the total population
    result[x].append(regions[x][2]/totalpop*100)
    result[x].append(0)     #initialize a 0 value to be used as a counter of total evaluations

totalevals = len(evaluations) #total evaluations is the length of the list evaluations

for x in evaluations:       #iterate through evaluations
    id = x[4]
    for y in properties:
        if y[0] == id:      #find the property evaluated, will use the region number to access result list
            for z in result:
                if y[5] == z[0]:    #access result list
                    z[2] += 1       #increment counter

for x in result:
    x[2] = x[2]/totalevals*100 #replace all counters with their representations as a % of total evaluations

result.insert(0,["RegionID","% of Total Population","% of Total Evaluations"]) #add column names as requested

for x in result: #simply show the result
     print(x)






