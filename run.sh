#!/bin/bash

docker run -d -v $PWD/dav:/tomcat/webapps/dav -p 8080:8080 tomcat8 bash
