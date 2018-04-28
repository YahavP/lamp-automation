#!/bin/bash

########################################################################
#Author  : YahavP
#Date    : 28/04/2018
#Purpose : Lamp automation for Centos
#Version : 1.1.1
########################################################################

#checks if the user uses root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#checks the if user's distro is Redhat's

cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^\"centos\"$|^\"fedora\"$" &> /dev/null

if [[ $? -eq 0 ]] ;then
    Distro_Val="centos"
    echo "this is Centos"
else
  echo "This script is for RedHat distributions only"
  exit 1
fi

#checking for updates
echo "Updating, this might take a few minutes."
sleep 5
yum -y update

if [[ $? -eq 0 ]] ;then
    echo "Update succeeded"
else
  echo "Something went wrong, Exiting."
  sleep 3
  exit 1
fi

#welcome
echo "Welcome to YahavP's LAMP automation script"
sleep 3
main()


#apache installation
apache(){
  echo "Installing Apache"
  yum -y install httpd
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi
  echo "Would you like to delete the welcome page? Y/N"
  OPTIONS=("Y" "N")
  select opt in $OPTIONS; do
    case $opt in
        "Y")
            echo "Deleting the welcome page"
            rm -f /etc/httpd/conf.d/welcome.conf
            main()
            ;;
        "N")
            main()
            ;;
          *)
            *) echo "Invalid option"
    esac
done
}

#nginx installation
nginx(){
  echo "Installing Nginx"
  yum install epel-release
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi
  yum install nginx
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi

#web server selection
  main_web(){
    echo "Which web server would you like to install? 1.Apache 2.Ngnix"
    WEBS=("1" "2")
    select opt in $WEBS; do
      case $opt in
          "1")
               apache()
              ;;
          "2")
               Ngnix()
              ;;
            *) echo "Invalid option"
              main_web()
      esac
  done
  }

#mariadb installation
mariadb(){
  echo "Installing MariaDB"
  yum --enablerepo=centos-sclo-rh -y install rh-mariadb102-mariadb-server
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi
main()


#SQLServer installation
SQLServer(){
  echo "Installing SQLServer"
  curl https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo -o /etc/yum.repos.d/mssql-server-2017.repo
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi
  curl https://packages.microsoft.com/config/rhel/7/prod.repo -o /etc/yum.repos.d/msprod.repo
  if [[ $? -eq 0 ]] ;then
      echo "Done"
  else
    echo "Something went wrong, Exiting."
    sleep 3
    exit 1
  fi
   yum -y install mssql-server mssql-tools unixODBC-devel
   if [[ $? -eq 0 ]] ;then
       echo "Done"
   else
     echo "Something went wrong, Exiting."
     sleep 3
     exit 1
   fi
main()

PostgreSQL()
  echo "installing PostgreSQL"
   yum --enablerepo=centos-sclo-rh -y install rh-postgresql96-postgresql-server
   if [[ $? -eq 0 ]] ;then
       echo "Done"
   else
     echo "Something went wrong, Exiting."
     sleep 3
     exit 1
   fi
   main()
 #DB server selection
   main_DB(){
     echo "Which DB server would you like to install? 1.Mariadb 2.SQLServer 3.PostgreSQL"
     DBS=("1" "2" "3")
     select opt in $DBS; do
       case $opt in
           "1")
                mariadb()
               ;;
           "2")
                SQLServer()
               ;;
            "3")
                PostgreSQL()
                ;;
             *) echo "Invalid option"
               main_DB()
       esac
   done
   }

#python 3.6 installation
  python3(){
     echo "Installing python 3.6"
      yum --enablerepo=centos-sclo-rh -y install rh-python36
     if [[ $? -eq 0 ]] ;then
         echo "Done"
     else
       echo "Something went wrong, Exiting."
       sleep 3
       exit 1
     fi
   main()

#installing php 7.2
php7(){
   echo "Installing PHP 7.2"
   yum --enablerepo=remi-safe -y install php72 php72-php-pear php72-php-mbstring
   if [[ $? -eq 0 ]] ;then
       echo "Done"
   else
     echo "Something went wrong, Exiting."
     sleep 3
     exit 1
   fi
 main()

 #installing ruby 2.4
 ruby2(){
    echo "Installing Ruby 2.4"
    yum --enablerepo=centos-sclo-rh -y install rh-ruby24
    if [[ $? -eq 0 ]] ;then
        echo "Done"
    else
      echo "Something went wrong, Exiting."
      sleep 3
      exit 1
    fi
  main()

#language installation
  main_lan(){
  echo "Which language would you like to install? 1.Python3 2.PHP 3.Ruby"
  LANS=("1" "2" "3")
  select opt in $LANS; do
    case $opt in
        "1")
             python3()
            ;;
        "2")
             php7()
            ;;
         "3")
             ruby2()
             ;;
          *) echo "Invalid option"
            main_lan()
    esac
done
}
  }
#main menu
  main() {
    echo "What would you like to install? 1.Web server 2.DB server 3.Development language"
  MAINS=("1" "2" "3")
    select opt in $MAINS; do
      case $opt in
          "1")
               main_web()
              ;;
          "2")
               main_DB()
              ;;
           "3")
               main_lan()
               ;;
            *) echo "Invalid option"
              main()
      esac
  done





  }
