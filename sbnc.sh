#!/usr/bin/env bash

# shroudBNC provision script, written by Som
set -e
set -u

_author="Som / somsubhra1 [at] xshellz.com"
_package="shroudBNC"
_version="1.3.9"

echo "Running provision for package $_package version: $_version by $_author"

cd ~
dir="bnc"

if [ -d $dir ]
then
 echo "$dir is already present in $HOME. Aborting!"
 exit
fi

if pgrep sbnc >/dev/null 2>&1
then
 echo "sBNC is already running. Aborting installation!"
 exit 
fi

wget http://shroudbnc.info/files/sbnc/sbnc-1.3.9.tar.gz

tar -zxvf sbnc-1.3.9.tar.gz

mkdir bnc
cd 'sbnc-1.3.9'

#Starting configuration

./configure --prefix="$HOME/bnc"

echo "sBNC has been successfully configured. Continuing installation"

#Starting installation

make
make install


cd ~
cd bnc/bin
chmod +x sbnc

#Entering preferred data

/usr/bin/expect - <<-EOF
spawn ./sbnc --config $HOME/bnc
set timeout 15
expect "1. Which port should the bouncer listen on (valid ports are in the range 1025 - 65535):"
send "$port\r"
expect "2. What should the first user's name be?"
send "$username\r"
expect "3. Please enter a password for the first user:"
send "$password\r"
expect "4. Please confirm your password by typing it again:"
send "$password\r"
set timeout 20
expect -ex "$prompt"
expect eof
EOF

#Restarting sBNC

./sbnc --config $HOME/bnc

#cleanup

cd ~
rm sbnc-1.3.9.tar.gz

#Check if sbnc ran successfully or not.
if pgrep sbnc >/dev/null 2>&1
then
 echo "sBNC is running successfully"
else
 echo "Error occured"
 exit 
fi

echo "Provision done, successfully."
