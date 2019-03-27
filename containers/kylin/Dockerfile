FROM yikkai95/ambari-master:1.0
RUN curl -sL https://archive.apache.org/dist/kylin/apache-kylin-1.5.4.1/apache-kylin-1.5.4.1-hbase1.x-bin.tar.gz | tar -xz -C /usr/local
RUN cd /usr/local/ && ln -s ./apache-kylin-1.5.4.1-hbase1.x-bin kylin
ENV KYLIN_HOME=/usr/local/kylin
ENV HIVE_CONF=/usr/hdp/current/hive-client/conf
ENV HCAT_HOME=/usr/hdp/current/hive-webhcat
EXPOSE 7070
