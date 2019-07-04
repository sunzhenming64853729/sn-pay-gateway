#!/bin/bash
export LANG="zh_CN.UTF-8"
. `dirname $0`/env.sh
cd $DEPLOY_DIR

SERVER_NAME=`sed '/app.application.name/!d;s/.*=//' conf/app.properties | tr -d '\r'`
SERVER_PROTOCOL=`sed '/app.protocol.name/!d;s/.*=//' conf/app.properties | tr -d '\r'`
SERVER_PORT=`sed '/app.protocol.port/!d;s/.*=//' conf/app.properties | tr -d '\r'`
LOGS_FILE=`sed '/app.log4j.file/!d;s/.*=//' conf/app.properties | tr -d '\r'`
API_SERVER_PORT=`sed '/api.server.port/!d;s/.*=//' conf/app.properties | tr -d '\r'`


if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=`hostname`
fi

PIDS=`ps -ef | grep java | grep "$CONF_DIR" |awk '{print $2}'`
if [ -n "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME already started!"
    echo "PID: $PIDS"
    exit 1
fi

if [ -n "$SERVER_PORT" ]; then
    SERVER_PORT_COUNT=`netstat -tln | grep $SERVER_PORT | wc -l`
    if [ $SERVER_PORT_COUNT -gt 0 ]; then
        echo "ERROR: The $SERVER_NAME port $SERVER_PORT already used!"
        exit 1
    fi
fi

if [ -n "API_SERVER_PORT" ]; then
    API_SERVER_PORT_COUNT=`netstat -tln | grep $API_SERVER_PORT | wc -l`
    if [ $API_SERVER_PORT_COUNT -gt 0 ]; then
        echo "ERROR: The $SERVER_NAME port $API_SERVER_PORT already used!"
        exit 1
    fi
fi

LOGS_DIR=""
if [ -n "$LOGS_FILE" ]; then
    LOGS_DIR=`dirname $LOGS_FILE`
fi
if [ -z "$LOGS_DIR" ] ;then
    LOGS_DIR="$DEPLOY_DIR/logs"
    if [ ! -e "$LOGS_DIR" ] ;then
        if [ ! -d "$LOG_DIR" ] ;then
            mkdir -p "$LOG_DIR"
        fi
        ln -s "$LOG_DIR" "$LOGS_DIR"
    fi
    if [ ! -L "$LOGS_DIR" ] ;then
        echo "ERROR, $LOGS_DIR should be a link of $LOG_DIR" 1>&2
        exit 1
    fi
else 
    if [ ! -d $LOGS_DIR ]; then
        mkdir -p $LOGS_DIR
    fi
fi
STDOUT_FILE=$LOGS_DIR/sn-pay-gateway.out

LIB_DIR=$DEPLOY_DIR
LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'|tr "\n" ":"`

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "
JAVA_DEBUG_OPTS=""
if [ "$1" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi
JAVA_JMX_OPTS=""
if [ "$1" = "jmx" ]; then
    JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi
JAVA_MEM_OPTS=""
BITS=`java -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
    JAVA_MEM_OPTS=" -server -Xmx2g -Xms2g -Xmn1024m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 "
else
    JAVA_MEM_OPTS=" -server -Xms1g -Xmx1g -XX:PermSize=256m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi

echo -e "Starting the $SERVER_NAME ...\c"
nohup java $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -classpath $CONF_DIR -jar  $DEPLOY_DIR/apps/sn-pay-gateway.jar > $STDOUT_FILE 2>&1 &

COUNT=0
while [ $COUNT -lt 1 ]; do    
    echo -e ".\c"
    sleep 1 
    if [ -n "$API_SERVER_PORT" ]; then
        COUNT=`netstat -an | grep $API_SERVER_PORT | wc -l`
    else
    	COUNT=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}' | wc -l`
    fi
    if [ $COUNT -gt 0 ]; then
        break
    fi
done

echo "OK!"
PIDS=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}'`
echo "PID: $PIDS"
echo "STDOUT: $STDOUT_FILE"

