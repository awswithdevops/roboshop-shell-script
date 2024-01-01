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

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installed mongodb "

systemctl enable mongod  &>> $LOGFILE
VALIDATE $? "enable mongodb "

systemctl start mongod &>> $LOGFILE
VALIDATE $? "start mongodb "

sed -i 's/127.0.0.1 to 0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote access to mongodb "

systemctl restart mongod  &>> $LOGFILE
VALIDATE $? "Restart mongodb "