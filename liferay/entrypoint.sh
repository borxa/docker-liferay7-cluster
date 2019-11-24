#!/bin/sh

set -o errexit

IP=`hostname -i`

main () {
	
	show_motd
	set_database
	set_resources_data
	set_elastic_search
	set_cluster_cache
	set_redis_session

	run_portal "$@"
}

function show_motd() {
	echo "
	Starting Liferay 7.2.1 node.
	IP: $IP
  	LIFERAY_HOME: $LIFERAY_HOME

  	JDBC_READ_DRIVER: $JDBC_READ_DRIVER
  	JDBC_READ_URL: $JDBC_READ_URL
  	JDBC_READ_USERNAME: $JDBC_READ_USERNAME
  	JDBC_READ_PASSWORD: $JDBC_READ_PASSWORD

	JDBC_WRITE_DRIVER: $JDBC_WRITE_DRIVER
  	JDBC_WRITE_URL: $JDBC_WRITE_URL
  	JDBC_WRITE_USERNAME: $JDBC_WRITE_USERNAME
  	JDBC_WRITE_PASSWORD: $JDBC_WRITE_PASSWORD

  	ES_OPERATIONMODE: $ES_OPERATIONMODE
  	ES_CLUSTERNAME: $ES_CLUSTERNAME
  	ES_TRANSPORTADDRESSES: $ES_TRANSPORTADDRESSES
	
	CLUSTER_UNICAST_FILENAME: $CLUSTER_UNICAST_FILENAME

	REDIS_URL: $REDIS_URL

  	run as: `id -u -n`
  	"
}

function set_database() {
	echo "Configuring Database ..."

	if [[ ! -z "$JDBC_READ_DRIVER" ]]; then
    	sed -i "s|\(jdbc\.read\.driverClassName=\).*\$|\1${JDBC_READ_DRIVER}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	if [[ ! -z "$JDBC_READ_URL" ]]; then
        sed -i "s|\(jdbc\.read\.url=\).*\$|\1${JDBC_READ_URL}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	if [[ ! -z "$JDBC_READ_USERNAME" ]]; then
        sed -i "s|\(jdbc\.read\.username=\).*\$|\1${JDBC_READ_USERNAME}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	if [[ ! -z "$JDBC_READ_PASSWORD" ]]; then
        sed -i "s|\(jdbc\.read\.password=\).*\$|\1${JDBC_READ_PASSWORD}|" $LIFERAY_HOME/portal-ext.properties
  	fi

	if [[ ! -z "$JDBC_WRITE_DRIVER" ]]; then
    	sed -i "s|\(jdbc\.write\.driverClassName=\).*\$|\1${JDBC_WRITE_DRIVER}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	if [[ ! -z "$JDBC_WRITE_URL" ]]; then
        sed -i "s|\(jdbc\.write\.url=\).*\$|\1${JDBC_WRITE_URL}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	if [[ ! -z "$JDBC_WRITE_USERNAME" ]]; then
        sed -i "s|\(jdbc\.write\.username=\).*\$|\1${JDBC_WRITE_USERNAME}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	if [[ ! -z "$JDBC_WRITE_PASSWORD" ]]; then
        sed -i "s|\(jdbc\.write\.password=\).*\$|\1${JDBC_WRITE_PASSWORD}|" $LIFERAY_HOME/portal-ext.properties
  	fi

  	echo " Continuing..."
}

function set_resources_data() {

	echo "Configuring Resources Data Properties Files ..."

	echo 'rootDir="/data/liferay/document_library"' > $LIFERAY_HOME/osgi/configs/com.liferay.portal.store.file.system.configuration.AdvancedFileSystemStoreConfiguration.config
	echo 'useHardLinks="false"' >> $LIFERAY_HOME/osgi/configs/com.liferay.portal.store.file.system.configuration.AdvancedFileSystemStoreConfiguration.config
	
	sed -i "s|\(dl\.store\.impl=\).*\$|\1com\.liferay\.portal\.store\.file\.system\.AdvancedFileSystemStore|" $LIFERAY_HOME/portal-ext.properties

	echo " Continuing..."
}

function set_elastic_search() {

	echo "Configuring ElasticSearch Properties Files ..."

	echo '#ElasticSearch Config' > $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
  	echo 'operationMode="EMBEDDED"' >> $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
	echo 'clusterName="LiferayElasticsearchCluster"' >> $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
	echo 'transportAddresses="localhost:9300"' >> $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
	
	if [[ ! -z "$ES_OPERATIONMODE" ]]; then
        sed -i "s|\(operationMode=\).*\$|\1\"${ES_OPERATIONMODE}\"|" $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
  	fi

  	if [[ ! -z "$ES_CLUSTERNAME" ]]; then
        sed -i "s|\(clusterName=\).*\$|\1\"${ES_CLUSTERNAME}\"|" $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
  	fi

  	if [[ ! -z "$ES_TRANSPORTADDRESSES" ]]; then
        sed -i "s|\(transportAddresses=\).*\$|\1\"${ES_TRANSPORTADDRESSES}\"|" $LIFERAY_HOME/osgi/configs/com.liferay.portal.search.elasticsearch6.configuration.ElasticsearchConfiguration.config
  	fi

  	echo " Continuing..."
}

function set_cluster_cache() {

	echo "Configuring Cluster Cache Files ..."

	sed -i '/cluster\.link\.enabled/s/^\s*#//g' $LIFERAY_HOME/portal-ext.properties
	
	if [[ ! -z "$CLUSTER_UNICAST_FILENAME" ]]; then
		sed -i '/cluster\.link\.channel\.properties\.control/s/^\s*#//g' $LIFERAY_HOME/portal-ext.properties
		sed -i '/cluster\.link\.channel\.properties\.transport\.0/s/^\s*#//g' $LIFERAY_HOME/portal-ext.properties
        	sed -i "s|\(cluster\.link\.channel\.properties\.control=\).*\$|\1${CLUSTER_UNICAST_FILENAME}|" $LIFERAY_HOME/portal-ext.properties
		sed -i "s|\(cluster\.link\.channel\.properties\.control\.0=\).*\$|\1${CLUSTER_UNICAST_FILENAME}|" $LIFERAY_HOME/portal-ext.properties
	
		if ! grep -Fq -- -Djgroups.bind_addr= $LIFERAY_HOME/tomcat-9.0.17/bin/setenv.sh; then
        		sed -i "s/CATALINA_OPTS=\"[^\"]*/& -Djgroups.bind_addr=$IP/g" $LIFERAY_HOME/tomcat/bin/setenv.sh
		else
        		sed -i -E "s/bind_addr=\d+\.\d+\.\d+\.\d+/bind_addr=$IP/g" $LIFERAY_HOME/tomcat/bin/setenv.sh
		fi
	fi

	echo " Continuing..."
}

function set_redis_session() {

	echo "Configuring Redis Session Files ..."

	if [[ ! -z "$REDIS_URL" ]]; then

		cp $LIFERAY_HOME/tomcat/conf/server-default.xml $LIFERAY_HOME/tomcat/conf/server.xml
		cp $LIFERAY_HOME/tomcat/conf/context-redis.xml $LIFERAY_HOME/tomcat/conf/context.xml
		
		echo 'singleServerConfig:' > $LIFERAY_HOME/tomcat/conf/redisson.conf
		echo '  address: "${REDIS_URL}"' >> $LIFERAY_HOME/tomcat/conf/redisson.conf
	else
		cp $LIFERAY_HOME/tomcat/conf/server-cluster-multicast.xml $LIFERAY_HOME/tomcat/conf/server.xml
		cp $LIFERAY_HOME/tomcat/conf/context-default.xml $LIFERAY_HOME/tomcat/conf/context.xml
	fi

	echo " Continuing..."
}

function run_portal() {

	echo "Run Liferay Portal ..."
	$LIFERAY_HOME/tomcat/bin/catalina.sh "$@"
}

main "$@"
