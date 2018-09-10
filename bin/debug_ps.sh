#!/usr/bin/env bash
# mvn package
# java -Dspring.profiles.active=local -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=1043,suspend=n -jar target/provisioning-service.jar
java -Dspring.profiles.active=local -Dansible.path=/bin/true -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=1043,suspend=n -jar target/provisioning-service.jar
