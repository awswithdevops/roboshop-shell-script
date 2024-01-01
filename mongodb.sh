#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R Faield $N"
    else
        echo -e "$2 .....$G Sucess $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:pleae run with root access $N "
    exit 1 # you can give other than 0
else
    echo -e "$G Root user $N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongodb repo"