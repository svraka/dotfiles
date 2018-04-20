program define loadsql
*! Load the output of an SQL file into Stata, version 1.3 (dvmaster@gmail.com)
version 13.1
syntax using/, DSN(string) [User(string) Password(string) CLEAR NOQuote LOWercase SQLshow ALLSTRing DATESTRing]

#delimit;
tempname mysqlfile exec line;

file open `mysqlfile' using `"`using'"', read text;
file read `mysqlfile' `line';

while r(eof)==0 {;
    local `exec' `"``exec'' ``line''"';
    file read `mysqlfile' `line';
};

file close `mysqlfile';


odbc load, exec(`"``exec''"') dsn(`"`dsn'"') user(`"`user'"') password(`"`password'"') `clear' `noquote' `lowercase' `sqlshow' `allstring' `datestring';

end;
