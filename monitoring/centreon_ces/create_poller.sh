#!/bin/bash
# create_poller.sh
# version 1.02
# date 24/03/2016
# use Centreon_Clapi
# $1 name of admin
# $2 password admin
# $3 name of poller
# $4 poller ip
# $5 central ip
# version 1.0.2
# fix parameter retention_path
# fix parameter stats
if [ $# -ne 6 ]
then
    echo Usage: $0 admin password \<name poller\> \<ip poller\> \<ip central\> 1>&2
    echo This program create template poller  1>&2
    echo for Centreon 1>&2
    exit 1
fi

CLAPI_DIR=/usr/bin
USER_CENTREON=$1
PWD_CENTREON=$2
NAME_POLLER=$3
MIN_NAME_POLLER="$(echo $NAME_POLLER | tr 'A-Z' 'a-z')"
IP_POLLER=$4
IP_CENTRAL=$5

# create instance poller
RESULT=`$CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a show -v $NAME_POLLER | grep $NAME_POLLER | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER" ]
then
    echo create instance poller
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a ADD -v "$NAME_POLLER;$IP_POLLER;22;CENGINE"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;localhost;0"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;is_default;0"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;ns_activate;1"

    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;init_script;/etc/init.d/centengine"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;init_script_centreontrapd;/etc/init.d/centreontrapd"
  
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;nagios_bin;/usr/sbin/centengine"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;nagiostats_bin;/usr/sbin/centenginestats"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_cfg_path;/etc/centreon-broker"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;centreonbroker_module_path;/usr/share/centreon/lib/centreon-broker"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;centreonconnector_path;/usr/lib64/centreon-connector"
    $CLAPI_DIR/centreon -u $1 -p $2 -o INSTANCE -a setparam -v "$NAME_POLLER;snmp_trapd_path_conf;/etc/snmp/centreon_traps/"
else
   echo instance $NAME_POLLER  already exist !
fi

#create module broker for poller
RESULT=`$CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a show -v $MIN_NAME_POLLER-module | grep $MIN_NAME_POLLER-module | cut -d";" -f2`
if [ "$RESULT" != "$MIN_NAME_POLLER-module" ]
then
   echo create module broker for poller
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a ADD -v "$MIN_NAME_POLLER-module;$NAME_POLLER"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;filename;$MIN_NAME_POLLER-module.xml"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;retention_path;/var/lib/centreon-broker"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setparam -v "$MIN_NAME_POLLER-module;stats_activate;1"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a ADDLOGGER -v "$MIN_NAME_POLLER-module;/var/log/centreon-engine/$MIN_NAME_POLLER-module.log;file"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;config;yes"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;debug;no"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;error;yes"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;info;no"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;level;low"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setlogger -v "$MIN_NAME_POLLER-module;1;type;file"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-module;$MIN_NAME_POLLER-module-output;ipv4"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;protocol;bbdo"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;tls;no"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;compression;no"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;port;5669"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;failover;$MIN_NAME_POLLER-module-output-failover"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;retry_interval;"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;buffering_timeout;"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;host;$IP_CENTRAL"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;1;type;ipv4"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a ADDOUTPUT -v "$MIN_NAME_POLLER-module;$MIN_NAME_POLLER-module-output-failover;file"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;2;path;/var/lib/centreon-engine/$MIN_NAME_POLLER-module-output.retention"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;2;type;file"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;2;protocol;bbdo"
   $CLAPI_DIR/centreon -u $1 -p $2 -o CENTBROKERCFG -a setoutput -v "$MIN_NAME_POLLER-module;2;compression;auto"
else
   echo module broker for poller $MIN_NAME_POLLER  already exist !
fi

#create engine poller
RESULT=`$CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a show -v $NAME_POLLER-cfg | grep $NAME_POLLER-cfg | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER-cfg" ]
then
   echo create engine poller
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a add -v "$NAME_POLLER-cfg;$NAME_POLLER;Poller Engine"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;status_file;/var/log/centreon-engine/status.dat"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;cfg_dir;/etc/centreon-engine"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;log_file;/var/log/centreon-engine/centengine.log"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;temp_file;/var/log/centreon-engine/centengine.tmp"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;lock_file;/var/lock/subsys/centengine.lock"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;command_file;/var/lib/centreon-engine/rw/centengine.cmd"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;log_archive_path;/var/log/centreon-engine/archives/"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;state_retention_file;/var/log/centreon-engine/retention.dat"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;broker_module;/usr/lib64/centreon-engine/externalcmd.so|/usr/lib64/nagios/cbmod.so /etc/centreon-broker/$MIN_NAME_POLLER-module.xml"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;nagios_user;centreon-engine"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;nagios_group;centreon-engine"
   $CLAPI_DIR/centreon -u $1 -p $2 -o nagioscfg -a setparam -v "$NAME_POLLER-cfg;p1_file;"
else
   echo engine poller $NAME_POLLER-cfg  already exist !
fi

#apply poller to resourcecfg
echo apply poller to resourcecfg
$CLAPI_DIR/centreon -u $1 -p $2 -o resourcecfg -a show -v 1 |
while read line
do
   ID=$(echo $line | cut -d";" -f1 )
   CHAINE=$(echo $line | cut -d";" -f6 )
   if [ "1" == "$ID" ]
   then
     CONCACT=$CHAINE\|$NAME_POLLER
     $CLAPI_DIR/centreon -u $1 -p $2 -o resourcecfg -a setparam -v "1;instance;$CONCACT"
   fi
done

#create poller host
RESULT=`$CLAPI_DIR/centreon -u $1 -p $2 -o host -a show -v $NAME_POLLER | grep $NAME_POLLER | cut -d";" -f2`
if [ "$RESULT" != "$NAME_POLLER" ]
then
   echo create poller host
   $CLAPI_DIR/centreon -u $1 -p $2 -o host -a add -v "$NAME_POLLER;poller $NAME_POLLER;$IP_POLLER;generic-host;$NAME_POLLER;Linux-Servers"
   $CLAPI_DIR/centreon -u $1 -p $2 -o host -a addtemplate -v "$NAME_POLLER;Servers-Linux"
   $CLAPI_DIR/centreon -u $1 -p $2 -o host -a applytpl -v "$NAME_POLLER"
else
   echo poller host $NAME_POLLER  already exist !
fi
