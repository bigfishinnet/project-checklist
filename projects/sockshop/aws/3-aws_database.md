#RDS MYSQL

#Databases required for catalogue

    1. Create password for db using random string generatorCreate RDS Instance
    2. Create the MYSQL Database, port and create username and pass password as attribute
    3. Create subnet group for the RDS Instance
    4. Create security group to allow access for ingre=ssa dn egress to the Database
    5. Output the username, password, fqdn, port for connecting to the db.

    NOTE Catalogue DB will require populating with informartion for the catalogue.
    Connection string format > #my_username:my_password@tcp(database_fqdn:3306)/database_instance

# DocumentDB

# Databases required for carts, orders, user
    1. Create password for db using random string generator
    2. Create DocumentDB cluster, create username and pass password as attribute
    3. Create db subnet group for the DocumentDB cluster
    4. Create security group to allow access for ingress and egress to the Database
    5. Create DocumentDB parameter resources to configure teh DB and turn off TLS
    6. Output the username, password, fqdn, port for connecting to the db.
