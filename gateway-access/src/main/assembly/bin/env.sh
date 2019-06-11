cd `dirname $0`
BIN_DIR=`pwd`
cd ..
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf

APP="sn-pay-gateway"
LOG_BASE="/opt/export/log"
LOG_DIR="$LOG_BASE/$APP"

