#!/bin/sh
set -e
DIR=`dirname "$0"`
java -jar $DIR/ECUxPlot-`cat $DIR/version.txt`.jar "$@"
