#!/bin/bash

SUBNET=$1
NAME=$2
PASSWORD=$3

nmap -sP $SUBNET -oG - | awk -v NAME=$NAME -v PASSWORD=$PASSWORD '/Up$/{
sub(/\(/,"",$3)
sub(/\)/,"",$3)
if($3=="") $3="HOST-"NR
print "centreon -u "NAME" -p "PASSWORD" -o HOST -a ADD -v \""toupper($3)";"toupper($3)";"$2";generic-active-host-custom;central;hostgroup\""}'
