#! /bin/bash

FAILED_NODE=$1
NEW_MASTER=$2
TRIGGER_FILE=$3

if [ $FAILED_NODE = 0 ]; 
then
	echo "Ведомый сервер вышел из строя"
	exit 1
fi

echo "Ведущий сервер вышел из строя"
echo "Новый ведущий сервер: $NEW_MASTER"
ssh -T postgres@$NEW_MASTER touch $TRIGGER_FILE

exit 0
