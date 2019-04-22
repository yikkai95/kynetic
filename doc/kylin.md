# To enable kylin cube building
su -hdfs
hdfs dfs -mkdir /kylin
hdfs dfs -chown root /kylin

# To enable Hive View
su -hdfs
hdfs dfs -mkdir /user/admin
hdfs dfs -chown admin /user/admin

# To use hive
hdfs dfs -mkdir /user/root
hdfs dfs -chown root /user/root
