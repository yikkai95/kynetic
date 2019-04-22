# Sqoop Statement

1. Use Sqoop to import fundamental table from MySql to Hive
```bash
sqoop import --connect jdbc:mysql://172.20.0.5:3306/mysql?characterEncoding=utf8 --username root --password PASSWORD --table fundamental --hive-import
```

2. Use Sqoop to import profile table from MySql to Hive
```bash
sqoop import --connect jdbc:mysql://172.20.0.5:3306/mysql?characterEncoding=utf8 --username root --password PASSWORD --table fundamental --hive-import -m 1
```

3. Use Sqoop to perform incremental import from MySQL to HIVE
```bash
sqoop import --connect jdbc:mysql://172.20.0.5:3306/mysql?characterEncoding=utf8 --username root --password PASSWORD --table fundamental --check-column index --incremental append --last-value 60169 --hive-import --hive-table fundamental
```

4. Use Sqoop to import stock from MySQL to Hive
```bash
sqoop import --connect
jdbc:mysql://172.20.0.5:3306/mysql?characterEncoding=utf8 --username root
--password PASSWORD --table stock --hive-import --driver com.mysql.jdbc.Driver
```
