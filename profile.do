if c(os) == "Windows" {

	sysdir set PLUS "C:/Users/`c(username)'/.local/share/ado/plus"
	sysdir set PERSONAL "C:/Users/`c(username)'/.config/ado/personal"

	set autotabgraphs on, permanently
	set fastscroll on, permanently
}

set varabbrev off, permanently

set more off, permanently
set scrollbufsize 2000000
set logtype text, permanently

set scheme s1color, permanently
