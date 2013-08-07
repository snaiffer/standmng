#!/bin/bash

PRIMARY_DATA=$1 
SLAVE_IP=$2 
SLAVE_DATA=$3

PRIMARY_IP=$(ifconfig eth0| sed -n '2 {s/^.*inet addr:\([0-9.]*\) .*/\1/;p}') 
TMP_DIR=/var/lib/pgsql/tmp

cd $PRIMARY_DATA 
rm -f recovery.* failover 
cat postgresql.conf | grep '#hot_standby = on'

if [ $? = 1 ] 
then   
	sed -i 's/hot_standby = on/#hot_standby = on/' postgresql.conf   
	/usr/bin/pg_ctl restart -D $PGDIR 
fi

ssh -T postgres@$SLAVE_IP "/usr/bin/pg_ctl stop -D $SLAVE_DATA" 
psql -c "SELECT pg_start_backup('Streaming Replication', true)" postgres 
rsync -a $PRIMARY_DATA/ $SLAVE_IP:$SLAVE_DATA/ --exclude postmaster.pid --exclude postmaster.opts

mkdir $TMP_DIR 
cd $TMP_DIR 
cp $PRIMARY_DATA/postgresql.conf $TMP_DIR/ 
sed -i 's/#hot_standby = on/hot_standby = on/' postgresql.conf

echo "standby_mode = 'on'" > recovery.conf 
echo "primary_conninfo = 'host=$PRIMARY_IP port=5432 user=postgres'" >> recovery.conf 
echo "trigger_file = 'failover'" >> recovery.conf

ssh -T postgres@$SLAVE_IP rm -f $SLAVE_DATA/recovery.* 
scp postgresql.conf postgres@$SLAVE_IP:$SLAVE_DATA/postgresql.conf 
scp recovery.conf postgres@$SLAVE_IP:$SLAVE_DATA/recovery.conf

psql -c "SELECT pg_stop_backup()" postgres

cd .. 
rm -fr $TMP_DIR
