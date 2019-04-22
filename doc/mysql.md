# MySQL

## Setup MySQL and PhpMyAdmin
```bash
docker run --name mysql -e MYSQL_ROOT_PASSWORD=PASSWORD -e MYSQL_ROOT_HOST=% -p 3306:3306 -d mysql/mysql-server:latest
docker exec -it mysql sed -i -e 's/# default-authentication-plugin=mysql_native_password/default-authentication-plugin=mysql_native_password/g' /etc/my.cnf
docker exec -it mysql mysql -u root -pPASSWORD -e "ALTER USER root IDENTIFIED WITH mysql_native_password BY 'PASSWORD';"
docker stop mysql; docker start mysql
docker run --name phpmyadmin -d --link mysql:db -p 8080:80 phpmyadmin/phpmyadmin:latest
```

Connect MySQL to the same network as HDP Pseudo Cluster
```bash
docker network connect compose_dev mysql
```

## Import Local CSV Files into MySQL
1. Login
```bash
mysql --local-infile=1 -u root -PPASSWORD mysql
```

3. Reset MySQL Local InFile Permission
```sql
SET GLOBAL local_infile = 1;
```

4. Import Data to MYSQL from CSV
```sql
LOAD DATA LOCAL INFILE "/root/fundamental.csv"
INTO TABLE fundamental
COLUMNS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
```
