#!/bin/sh
exec java -XX:+HeapDumpOnOutOfMemoryError -XX:+UseZGC ${JAVA_OPTS} -jar ${JAR_FILE} $@

