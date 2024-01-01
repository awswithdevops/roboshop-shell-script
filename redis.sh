#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

echo "Script started executing at $TIMESTAMP"  

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y  

VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y  

VALIDATE $? "enabling redis"

dnf install redis -y 

VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf & 

VALIDATE $? "alloing remote connection"

systemctl enable redis  

VALIDATE $? "enable redis"
