# Usage

1. Install the latest version of docker
2. These containers are not pushed to DockerHub, thus you'll need to build them locally:
  ```
  docker-compose -f examples/compose/single-container.yml build
  ```

3. Run and wait until Ambari's Web UI at localhost:8080. Default User/PW is admin/admin as usual.
  ```
  docker-compose -f examples/compose/single-container.yml up
  ```

4. Submit Blueprint and monitor the progress on Ambari's Web UI
  ```
  sh submit-blueprint.sh single-node-kylin.sh
  ```

5. Upon completion of operation, login to master node
  ```
  docker-exec -it compose_master0 bash
  ```

6. Run the following commands to create directory for kylin and hive
  ```
  su - hdfs
  hdfs dfs -mkdir /kylin /user/admin /user/root
  hdfs dfs -chown root /kylin /user/root
  hdfs dfs -chown admin /user/admin
  ```

7. Start Kylin
  ```
  $KYLIN_HOME/bin/kylin.sh start
  ```

8. To start with fresh containers, before each run do:
  ```
  docker-compose -f examples/compose/multi-container.yml rm
  ```

