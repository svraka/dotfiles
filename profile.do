if c(os) == "Windows" {

	sysdir set PLUS "C:/Users/`c(username)'/ado/plus"
	sysdir set PERSONAL "C:/Users/`c(username)'/ado/personal"

	if c(version) >= 10 set autotabgraphs on, permanently
	set fastscroll on, permanently
	// if c(version) >= 10 graph set window fontface "Calibri"

}

if c(version) < 12 set memory 1500m, permanently

if c(version) >= 10 set varabbrev off, permanently

set more off, permanently
if c(version) < 10 set scrollbufsize 500000
if c(version) >= 10 set scrollbufsize 2000000
set logtype text, permanently

set scheme s1color, permanently
