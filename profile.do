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

if floor(c(stata_version)) == 15 & c(mode) == "" {

	local stata_logs_dir = "//gvvrcommon12/gvvrcommon12/LUN03/NGM_FO_ANA/FO_KOZOS/stata_logs"

	capture confirm file "`stata_logs_dir'/collect_logs.sh"
	if _rc == 0 {

		local date : display %tcCCYY-NN-DD clock("`c(current_date)'","DMY")
		local time = c(current_time)
		local datetime = "`date',`time'"

		file open logfile using "`stata_logs_dir'/`c(username)'.log", write append
		file write logfile "`datetime'" _n
		file close logfile
	}

}
