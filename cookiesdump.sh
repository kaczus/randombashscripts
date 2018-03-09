#!/usr/bin/env sh
#$ extract_cookies $HOME/.mozilla/firefox/*/cookies.sqlite > /tmp/cookies.txt
#$ wget --load-cookies=/tmp/cookies.txt http://mysite.com
#$ # OR 
#$ curl --cookie /tmp/cookies.txt http://mysite.com 

cleanup() {
    rm -f $TMPFILE
    exit 1
}

trap cleanup \
    EXIT INT QUIT TERM

# This is the format of the sqlite database:
# CREATE TABLE moz_cookies (id INTEGER PRIMARY KEY, name TEXT, value TEXT, host TEXT, path TEXT,expiry INTEGER, lastAccessed INTEGER, isSecure INTEGER, isHttpOnly INTEGER);

# We have to copy cookies.sqlite, because FireFox has a lock on it
TMPFILE=`mktemp /tmp/cookies.sqlite.XXXXXXXXXX`
cat $1 >> $TMPFILE
sqlite3 -separator '    ' $TMPFILE << EOF
.mode tabs
.header off
select host,
case substr(host,1,1)='.' when 0 then 'FALSE' else 'TRUE' end,
path,
case isSecure when 0 then 'FALSE' else 'TRUE' end,
expiry,
name,
value
from moz_cookies;
EOF
cleanup
