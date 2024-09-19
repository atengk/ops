#!/bin/sh
exec java -XX:+HeapDumpOnOutOfMemoryError -XX:+UseZGC -server ${JAVA_OPTS} -jar ${JAR_FILE} $@

