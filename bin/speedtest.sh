#!/usr/bin/env bash

CSV="/Users/andras/speedtest.csv"

if [ ! -f $CSV ]; then
	speedtest --csv-header > $CSV
fi

speedtest --secure --csv >> $CSV
