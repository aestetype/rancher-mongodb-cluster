#!/bin/bash

if [ -n "$CATTLE_SCRIPT_DEBUG" ]; then
	set -x
fi

GIDDYUP=/opt/rancher/bin/giddyup

function cluster_init {
	sleep 10
	# MYIP=$($GIDDYUP ip myip)
  # Using hostname instead of ips to solve this: https://jira.mongodb.org/browse/NODE-746
  MYHOSTNAME=$($GIDDYUP ip myname)
	mongo --eval "printjson(rs.initiate({_id :'rs0', members:[{_id:0, host:'$MYHOSTNAME.rancher.internal:27017'}]}))"
	for member in $($GIDDYUP ip stringify --use-container-names --delimiter " "); do
		if [ "$member" != "$MYHOSTNAME" ]; then
			mongo --eval "printjson(rs.add('$member.rancher.internal:27017'))"
			sleep 5
		fi
	done
}

function find_master {
	for member in $($GIDDYUP ip stringify --delimiter " "); do
		IS_MASTER=$(mongo --host $member --eval "printjson(db.isMaster())" | grep 'ismaster')
		if echo $IS_MASTER | grep "true"; then
			return 0
		fi
	done
	return 1
}
# Script starts here
# wait for mongo to start
$GIDDYUP service wait scale --timeout 120

# Wait until all services are up
while ! mongo --eval "db.version()" > /dev/null 2>&1; do sleep 0.1; done
find_master
if [ $? -eq 0 ]; then
	echo 'Master is already initated.. nothing to do!'
else
	echo 'Initiating the cluster!'
	cluster_init
fi
