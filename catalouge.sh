#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.awsdevops

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

dnf module disable nodejs -y  &>> $LOGFILE

VALIDATE $? "disableing nodejs"

dnf module enable nodejs:18 -y  &>> $LOGFILE

VALIDATE $? "enableing nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "einstalling nodejs:18"

useradd roboshop &>> $LOGFILE

VALIDATE $? "useradd roboshop"

mkdir /app  &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalouge application"

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalouge"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies" 

#use absulte path because,catalouge.service exists there
cp /home/centos/roboshop-shell-script/catalouge.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalouge.service" 

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "catalouge daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalouge"

systemctl start catalogue &>> $LOGFILE
 
VALIDATE $? "starting catalouge"

cp /home/centos/roboshop-shell-script/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying catalouge"

dnf install mongodb-org-shell -y  &>> $LOGFILE

VALIDATE $? "install mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalouge data in to mongodb"

