#!/bin/bash

########################################################################
#Author  : YahavP
#Date    : 28/04/2018
#Purpose : Lamp automation for Centos
#Version : 1.1.1
########################################################################

LogFolder="/var/log/LAMPScript"

#checks if the user uses root
RootCheck(){
  if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root"
     exit 1
  fi
}
#checks the if user's distro is Redhat's
User_Check(){
  cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^\"centos\"$|^\"fedora\"$" &> /dev/null
  if [[ $? -eq 0 ]] ;then
      Distro_Val="centos"
      mkdir -p $LogFolder
  else
    echo "This script is for RedHat distributions only"
    exit 1
  fi
}

#checking for updates
Update_Check(){
  echo "Updating, this might take a few minutes."
  sleep 3
  if [[ -d $LogFolder/Updates ]]; then
      :
    else
      mkdir $LogFolder/Updates
    fi
  yum -y update &>> $LogFolder/Updates/Updates.log
  if [[ $? -eq 0 ]] ;then
      echo "Update succeeded"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi
}

#apache installation
Apache(){
  echo "Installing Apache"
  yum -y install httpd &>> $LogFolder/WebFolder/Apache.log
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
      echo "Something went wrong, Exiting. Rerurning to the web server menu."
      sleep 3
      Main_Web
  fi
  echo "Would you like to delete the welcome page? Y/N"
  OPTIONS=("Y" "N")
  select opt in $OPTIONS; do
    case $opt in
        "Y")
            echo "Deleting the welcome page"
            rm -f /etc/httpd/conf.d/welcome.conf &>> $LogFolder/WebFolder/Apache.log
            Main
            ;;
        "N")
            Main
            ;;
          *) echo "Invalid option. Rerurning to the web server menu."
            Main_Web
            ;;
    esac
done
}

#nginx installation
Nginx(){
  echo "Installing Nginx"
  yum -y install epel-release &>> $LogFolder/WebFolder/Nginx.log
  if [[ $? -eq 0 ]] ;then
    echo "Done"
  else
    echo "Something went wrong, Exiting. Rerurning to the web server menu."
    sleep 3
    Main_Web
  fi
  yum -y install nginx &>> $LogFolder/WebFolder/Nginx.log
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting. Rerurning to the web server menu."
    sleep 3
    Main_Web
  fi
}
#web server selection
  Main_Web(){
    echo "Which web server would you like to install? 1.Apache 2.Ngnix"
    WEBS=("1" "2")
    select opt in $WEBS; do
      case $opt in
          "1")
               Apache
              ;;
          "2")
               Ngnix
              ;;
            *) echo "Invalid option. Returning to the main menu."
              Main
              ;;
      esac
  done
  }

#mariadb installation
Mariadb(){
  echo "Installing MariaDB"
  yum --enablerepo=centos-sclo-rh -y install rh-mariadb102-mariadb-server &>> $LogFolder/DBFolder/Mariadb.log

  if [[ $? -eq 0 ]] ;then
    echo "Done"
  else
    echo "Something went wrong, Exiting. Rerurning to the DB server menu."
    sleep 3
    Main_DB
  fi
Main
}

#SQLServer installation
SQLServer(){
  echo "Installing SQLServer"
  curl https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo -o /etc/yum.repos.d/mssql-server-2017.repo &>> $LogFolder/DBFolder/SQLServer.log
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting. Rerurning to the DB server menu."
    sleep 3
    Main_DB
  fi
  curl https://packages.microsoft.com/config/rhel/7/prod.repo -o /etc/yum.repos.d/msprod.repo &>> $LogFolder/DBFolder/SQLServer.log
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting. Rerurning to the DB server menu."
    sleep 3
    Main_DB
  fi
   yum -y install mssql-server mssql-tools unixODBC-devel &>> $LogFolder/DBFolder/SQLServer.log
   if [[ $? -eq 0 ]] ;then
       echo "Done"
    else
     echo "Something went wrong, Exiting. Rerurning to the DB server menu."
     sleep 3
     Main_DB
   fi
Main
}

PostgreSQL(){
  echo "installing PostgreSQL"
   yum --enablerepo=centos-sclo-rh -y install rh-postgresql96-postgresql-server &>> $LogFolder/DBFolder/PostgreSQL.log
   if [[ $? -eq 0 ]] ;then
       echo "Done"
    else
     echo "Something went wrong, Exiting. Rerurning to the DB server menu."
     sleep 3
     Main_DB
   fi
   Main
}


 #DB server selection
   Main_DB(){
     echo "Which DB server would you like to install? 1.Mariadb 2.SQLServer 3.PostgreSQL"
     DBS=("1" "2" "3")
     select opt in $DBS; do
       case $opt in
           "1")
                Mariadb
               ;;
           "2")
                SQLServer
               ;;
            "3")
                PostgreSQL
                ;;
              *) echo "Invalid option. Returning to the main menu."
                Main
                ;;
       esac
   done
   }

#python 3.6 installation
  Python3(){
     echo "Installing python 3.6"
      yum --enablerepo=centos-sclo-rh -y install rh-python36 &>> $LogFolder/LanFolder/Python3.log
     if [[ $? -eq 0 ]] ;then
         echo "Done"
      else
       echo "Something went wrong, Exiting. Rerurning to the languages menu."
       sleep 3
       Main_Lan
     fi
   Main
}

#installing php 7.2
Php7(){
   echo "Installing PHP 7.2"
   yum --enablerepo=remi-safe -y install php72 php72-php-pear php72-php-mbstring &>> $LogFolder/LanFolder/Php7.log
   if [[ $? -eq 0 ]] ;then
       echo "Done"
    else
      echo "Something went wrong, Exiting. Rerurning to the languages menu."
      sleep 3
      Main_Lan
   fi
 Main
}

 #installing ruby 2.4
 Ruby2(){
    echo "Installing Ruby 2.4"
    yum --enablerepo=centos-sclo-rh -y install rh-ruby24 &>> $LogFolder/LanFolder/Ruby2.log
    if [[ $? -eq 0 ]] ;then
        echo "Done"
    else
      echo "Something went wrong, Exiting. Rerurning to the languages menu."
     sleep 3
     Main_Lan
    fi
  Main
}

#language installation
  Main_Lan(){
  echo "Which language would you like to install? 1.Python3 2.PHP 3.Ruby"
  LANS=("1" "2" "3")
  select opt in $LANS; do
    case $opt in
        "1")
             Python3
            ;;
        "2")
             Php7
            ;;
         "3")
             Ruby2
             ;;
          *) echo "Invalid option.Rerurning to the main menu."
            Main
            ;;
    esac
done
}
#main menu
  Main(){
    echo "Welcome to YahavP's LAMP automation script."
    sleep 2
    echo "What would you like to install? 1.Web server 2.DB server 3.Development language"
  MAINS=("1" "2" "3")
    select opt in $MAINS; do
      case $opt in
          "1")
              if [[ -d $LogFolder/WebFolder ]]; then :
              else
                 mkdir $LogFolder/WebFolder
              fi
               Main_Web
              ;;
          "2")
               if [[ -d $LogFolder/DBFolder ]]; then :
               else
                  mkdir $LogFolder/DBFolder
               fi
               Main_DB
              ;;
           "3")
               if [[ -d $LogFolder/LanFolder ]]; then :
               else
                  mkdir $LogFolder/LanFolder
               fi
               Main_Lan
               ;;
            *) echo "Invalid option.Rerurning to the main menu."
               Main
               ;;
      esac
  done

  }

RootCheck
User_Check
Update_Check
Main
