#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.awsdevops.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R Faield $N"
        exit 1
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

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "useradd roboshop"
else
    echo -e "roboshop user already exist $Y skipping$N"
fi

mkdir -p /app  &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "Installing Dependencies" 

cp /home/centos/roboshop-shell-script/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying user.service" 

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "user daemon-reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE
 
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell-script/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y  &>> $LOGFILE

VALIDATE $? "install mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js  &>> $LOGFILE

VALIDATE $? "Loading user data in to mongodb"



