#!/bin/bash -e
SERVICE=$1

case "$2" in
 run|start )
    STATUS=run ;;
 stop|down )
    STATUS=down ;;
  * )
    STATUS=run ;;
esac

if [ -z "$SERVICE" ]; then
  echo "Service not defined"; exit 1
fi

curStatus=$(sv check "$SERVICE")
if [ $? -ne 0 ]; then
  echo "Service $SERVICE not exists"; exit 1
fi

until (echo $curStatus|grep $STATUS 1>/dev/null 2>&1) ; do
  echo "Wait for service $SERVICE $STATUS"
  sleep 1
  curStatus=$(sv check "$SERVICE")
done
