#!/bin/sh
exec java -XX:+HeapDumpOnOutOfMemoryError -XX:+UseG1GC -server ${JAVA_OPTS} -jar ${JAR_FILE} $@

