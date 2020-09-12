#!/bin/bash

target=$1
name=$2
box=$3

if [ $# -gt 2 ];
then

  ## Create directory
  mkdir -p ~/machines/$name
  mkdir -p ~/machines/$name/recon
  mkdir -p ~/machines/$name/exploits

  ## Create session
  cd ~/machines/$name
  export target
  export box
  export name
  
  echo "Starting Just Port Scanning"
  nmap -sS -p- $target > recon/PortsOnly
  sleep 1
  echo "Starting Just in Details Port Scanning"
  nmap -sC -sV -A -p- $target > recon/initial_nmap.txt
  sleep 1
  echo "Starting Just UDP 100 Ports Scanning"
  nmap -sU --top-ports 1000 $target > recon/UDPscan 
  sleep 1
  #masscan -p1-65535 -oL recon/allports.txt --rate=1000 -vv -Pn $target
  echo "Checking if we have a Webserver Port avialable"
  #if [ cat recon/PortsOnly | grep 80 ]; then
  echo "Creating a Wordlist from the WebSite Content"
  cewl -d 10 -m 3 --with-number http://$target > recon/SiteWordlist.txt 
  echo "Brute Forcing Directories"
  /opt/git/bruteforcing/dirsearch/dirsearch.py -u http://$target -x 403,503 -e *  > recon/UDPscan
  echo "Brute Forcing Files"
  ffuf -c -v -w /opt/git/password/wordlists/SecLists/Discovery/Web-Content/big.txt -u http://$target/FUZZ | tee recon/directories.txt
  echo "Brute Forcing SubDomains"
  ffuf -c -v -w /opt/git/password/wordlists/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -u http://FUZZ.$target | tee subdomains.txt
  echo "Scanning WebContent"
  nikto -h http://$target > recon/Nikto
  #else
  #  echo "No WebServer Exist"
  #fi

  
  echo "# Info" >> Notes.md
  echo "* Name: $name" >> Notes.md
  echo "* IP: $target" >> Notes.md
  echo "* Box: $box" >> Notes.md
  echo "* Level: " >> Notes.md
  vim Notes.md

else
  echo "Usage: ./recon.sh <IP> <Name_of_Machine> <OS> "
  echo "Example: ./workspace.sh 10.10.10.180 HTB/box-name Windows/linux"

fi
