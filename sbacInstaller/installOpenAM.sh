#!/bin/bash

################################################################################
#  Educational Online Test Delivery System
#  Copyright (c) 2013 American Institutes for Research
#
#  Distributed under the AIR Open Source License, Version 1.0
#  See accompanying file AIR-License-1_0.txt or at
#  https://bitbucket.org/sbacoss/eotds/wiki/AIR_Open_Source_License
################################################################################

MAINDIR="/opt"                           # all files will be installed in this folder
SCRIPTDIR="$MAINDIR/scripts"             # location of the script directory
LOGSDIR="$MAINDIR/scripts/logs"          # location of the script directory
TOMCATDIR="$MAINDIR/tomcat"              # location of the open installation directory
INSTALLUSER="root"                       # user who is performing the installation
OPENAMUSER="openam"                      # user that tomcat/OpenAM will run as
OPENAMTOOLSDIR="$MAINDIR/openamtools"    # location of openamtools
JAVAVERSION="1.7.0_76"                   # java version this server has been tested with
SSOADM="$OPENAMTOOLSDIR/auth/bin/ssoadm" # location of ssoadm
PWDFILE="$OPENAMTOOLSDIR/pwd.txt"        # password file used by ssoadm

clear
echo "************************************************************************"
echo "*"
echo "* SBAC Environment OpenAM Installation Script"
echo "*"
echo "* Phase 1:  System Verification"
echo "*"
echo "* In this phase, the script will verify the existing Linux environment."
echo "*"
echo "************************************************************************"
echo "Hit the <ENTER> key to continue"
read CONTINUE

echo "Verifying identity of current user..."

USER=`whoami`
if [[ "$USER" != "$INSTALLUSER" ]]; then
    echo "ERROR:  You are executing this script as: $USER.  You must execute this script as: $INSTALLUSER!"
    echo
    exit
else
    echo "CONFIRMED:  You are executing this script as: $USER"
    echo
fi

echo "Verifying the current working directory..."
# verify the current directory; this script should be run out of /opt
CWD=`pwd`
if [[ "$CWD" != "$MAINDIR" ]]; then
    echo "ERROR:  This script needs to be run out of the /opt folder!"
    echo
    exit
else
    echo "CONFIRMED:  You are executing this script from the /opt folder"
    echo
fi

echo "Searching for the current version of Java..."
if type -p java; then
    echo "CONFIRMED:  The java executable was found in the PATH variable"
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo "CONFIRMED:  The java executable was found in the JAVA_HOME variable"
    _java="$JAVA_HOME/bin/java"
else
    echo "ERROR:  The java executable was not found on this server."
    echo "        Java is a requirement for the opendj server."
    exit
fi

if [[ "$_java" ]]; then
    VERSION=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    if [[ "$VERSION" != "$JAVAVERSION" ]]; then
        echo "ERROR:  You must be running Java $VERSION"
        echo
        exit
    else
        echo "CONFIRMED:  You are running java version $VERSION"
        echo
    fi
fi

echo "Checking for the existence of the openam user..."
USER=`grep $OPENAMUSER /etc/passwd`
if [[ -z "$USER" ]]; then
    `useradd -d /opt/openam -m -c "OpenAM User" -s /bin/bash $OPENAMUSER`
    echo "MESSAGE:  The openam user was created."
    echo
else
    echo "CONFIRMED:  The openam user exists."
    echo
fi

echo "Checking to see if $TOMCATDIR already exists..."
# check to see if the tomcat directory exists, if so, exit the installation script
if [ -e $TOMCATDIR ]; then
    echo "ERROR:  $TOMCATDIR already exists!"
    echo
    exit
else
    echo "$TOMCATDIR does not exist"
    echo
fi

echo "CONFIRMED:  This is a new installation."
echo
echo "Hit the <ENTER> key to continue"
read CONTINUE

clear
echo "************************************************************************"
echo "*"
echo "* SBAC Environment OpenAM Installation Script"
echo "*"
echo "* Phase 2: Gather configuration info"
echo "*"
echo "* In this phase, the script will collect data from you that will be"
echo "* needed to perform the installation and configuration of the system."
echo "*"
echo "************************************************************************"
echo

# Initialize variables
FQDN=""
PASSWORD=""
CONFIRMPASSWORD="x"
LDAPFQDN=""
LDAPPASSWORD=""
CONFIRMLDAPPASSWORD="x"
FIRSTINSTANCE=""
EXISTINGFQDN=""
SITECONFIG=""
SITEURL=""
MAILSERVER=""
MAILSERVERPORT=""

# Get amadmin password
while [ "$PASSWORD" != "$CONFIRMPASSWORD" ]; do
    read -s -p "Choose a password for the amadmin user: " PASSWORD
    echo
    read -s -p "Enter the password for the amadmin user (again): " CONFIRMPASSWORD
    echo
    if [ "$PASSWORD" != "$CONFIRMPASSWORD" ]; then
        echo "Passwords do not match. Please try again."
    fi
done
echo

# Get FQDN
while [ -z "$FQDN" ]; do
    read -p "Enter the Fully Qualified Domain Name (FQDN) of this system (Ex. server.co.com): " FQDN
done
echo

# Get cookie domain from the FQDN
OIFS="$IFS"
IFS='.' read -a array <<< "$FQDN"
LEN=${#array[@]}
COOKIEDOMAIN=".${array[LEN-2]}.${array[LEN-1]}"

# Configuration Data Store Settings
while [ "$FIRSTINSTANCE" != "yes" ] && [ "$FIRSTINSTANCE" != "no" ]; do
    read -p "Is this the first instance of OpenAM you are deploying (yes/no) : " FIRSTINSTANCE
    if [ "$FIRSTINSTANCE" == "no" ]; then
        echo
        while [ -z "$EXISTINGFQDN" ]; do
            read -p "Enter the Fully Qualified Domain Name of the existing OpenAM server (Ex. server.co.com): " EXISTINGFQDN
        done
    fi
done
echo

# Site Configuration
while [ "$SITECONFIG" != "yes" ] && [ "$SITECONFIG" != "no" ]; do
    read -p "Will this instance be deployed behind a load balancer as part of a site configuration? (yes/no) : " SITECONFIG
    if [ "$SITECONFIG" == "yes" ]; then
        echo
        while [ -z "$SITEURL" ]; do
            read -p "Enter the load balancer URL (Ex. https://server.co.com:443/auth): " SITEURL
        done
        # Get Site FQDN from SITEURL
        PROTO="$(echo $SITEURL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
        URL=$(echo $SITEURL | sed -e s,$PROTO,,g)
        HOSTPORT=`echo $URL | cut -d/ -f1`
        PORT=`echo $HOSTPORT | grep : | cut -d: -f2`
        if [ -n "$PORT" ]; then
            SITEFQDN=`echo $HOSTPORT | grep : | cut -d: -f1`
        else
            SITEFQDN=$HOSTPORT
        fi
        # Set URL for IDP metadata
        IDPURL="$SITEURL"
    else
        IDPURL="http://$FQDN:8080/auth"
    fi
done
echo

if [ "$FIRSTINSTANCE" == "yes" ]; then
    # Get LDAP FQDN
    while [ -z "$LDAPFQDN" ]; do
        read -p "Enter LDAP load balancer FQDN or IP Address (Ex. ldap.co.com or xx.xx.xx.xx): " LDAPFQDN
    done
    echo

    # Get LDAP password
    while [ "$LDAPPASSWORD" != "$CONFIRMLDAPPASSWORD" ]; do
        read -s -p "Enter the password for the \"cn=SBAC Admin\" user: " LDAPPASSWORD
        echo
        read -s -p "Enter the password for the \"cn=SBAC Admin\" user (again): " CONFIRMLDAPPASSWORD
        echo
        if [ "$LDAPPASSWORD" != "$CONFIRMLDAPPASSWORD" ]; then
            echo "Passwords don not match. Please try again."
        fi
    done
    echo

    # Get Mail Server
    while [ -z "$MAILSERVER" ]; do
        read -p "Enter your mail server FQDN or IP Address (Ex. ldap.co.com or xx.xx.xx.xx): " MAILSERVER
    done
    echo

    # Get Mail Server Port
    while [ -z "$MAILSERVERPORT" ]; do
        read -p "Enter your mail server SMTP port (Ex. 25): " MAILSERVERPORT
    done
    echo

    # Update input files with data supplied
    if [ "$SITECONFIG" == "no" ]; then
        cat $MAINDIR/artifacts/templates/config.txt | sed -e "s/\${FQDN}/$FQDN/" -e "s/\${PASSWORD}/$PASSWORD/" -e "s/\${COOKIEDOMAIN}/$COOKIEDOMAIN/" > $MAINDIR/artifacts/configfiles/config.txt
    else
        cat $MAINDIR/artifacts/templates/config.txt | sed -e "s/\${FQDN}/$FQDN/" -e "s/\${PASSWORD}/$PASSWORD/" -e "s/\${COOKIEDOMAIN}/$COOKIEDOMAIN/" -e "s/^#LB_/LB_/g" -e "s,\${SITEURL},$SITEURL," > $MAINDIR/artifacts/configfiles/config.txt
    fi
    cat $MAINDIR/artifacts/templates/datastore_info.txt | sed -e "s/\${LDAPFQDN}/$LDAPFQDN/" -e "s/\${LDAPPASSWORD}/$LDAPPASSWORD/" > $MAINDIR/artifacts/configfiles/datastore_info.txt
    cat $MAINDIR/artifacts/templates/authModule_info.txt | sed -e "s/\${LDAPFQDN}/$LDAPFQDN/" -e "s/\${LDAPPASSWORD}/$LDAPPASSWORD/" > $MAINDIR/artifacts/configfiles/authModule_info.txt
    cat $MAINDIR/artifacts/templates/iPlanetAMPasswordResetService_info.txt | sed -e "s/\${LDAPPASSWORD}/$LDAPPASSWORD/" > $MAINDIR/artifacts/configfiles/iPlanetAMPasswordResetService_info.txt
    cat $MAINDIR/artifacts/templates/iPlanetAMAuthService_info.txt > $MAINDIR/artifacts/configfiles/iPlanetAMAuthService_info.txt
    cat $MAINDIR/artifacts/templates/IDP_metadata.xml | sed -e "s,\${IDPURL},$IDPURL,g" > $MAINDIR/artifacts/configfiles/IDP_metadata.xml
    cat $MAINDIR/artifacts/templates/IDP_extended_metadata.xml | sed -e "s,\${IDPURL},$IDPURL,g" > $MAINDIR/artifacts/configfiles/IDP_extended_metadata.xml
    cat $MAINDIR/artifacts/templates/OAuth2Provider_info.txt > $MAINDIR/artifacts/configfiles/OAuth2Provider_info.txt
    cat $MAINDIR/artifacts/templates/sb_client_group_info.txt > $MAINDIR/artifacts/configfiles/sb_client_group_info.txt
    cat $MAINDIR/artifacts/templates/OAuth2Client_info.txt > $MAINDIR/artifacts/configfiles/OAuth2Client_info.txt


else
    if [ "$SITECONFIG" == "no" ]; then
        cat $MAINDIR/artifacts/templates/add_config.txt | sed -e "s/\${FQDN}/$FQDN/" -e "s/\${PASSWORD}/$PASSWORD/" -e "s/\${COOKIEDOMAIN}/$COOKIEDOMAIN/" -e "s/\${EXISTINGFQDN}/$EXISTINGFQDN/" > $MAINDIR/artifacts/configfiles/config.txt
    else
        cat $MAINDIR/artifacts/templates/add_config.txt | sed -e "s/\${FQDN}/$FQDN/" -e "s/\${PASSWORD}/$PASSWORD/" -e "s/\${COOKIEDOMAIN}/$COOKIEDOMAIN/" -e "s/\${EXISTINGFQDN}/$EXISTINGFQDN/" -e "s/^#LB_/LB_/g" -e "s,\${SITEURL},$SITEURL," > $MAINDIR/artifacts/configfiles/config.txt
    fi
fi

clear
echo "************************************************************************"
echo "*"
echo "* SBAC Environment OpenAM Installation Script"
echo "*"
echo "* Phase 3: Extraction of Tomcat and OpenAM Tools"
echo "*"
echo "* In this phase, the script will extract tomcat and start it up with the"
echo "* SBAC-Specific OpenAM war deployed."
echo "*"
echo "************************************************************************"
echo "Hit the <ENTER> key to continue"
read CONTINUE

echo "Extracting the tomcat binary w/OpenAM war included..."
unzip -q $CWD/artifacts/tomcat.zip
chown -R openam:openam $TOMCATDIR
if [ -d $TOMCATDIR ]; then
    echo "The binaries have been extracted to the following folder: $TOMCATDIR."
    echo
else
    echo "ERROR:  There was an error creating the tomcat folder structure!"
    echo
    exit
fi

echo "Starting tomcat..."
if [ -f $TOMCATDIR/bin/startup.sh ]; then
    /bin/su - $OPENAMUSER -c $TOMCATDIR/bin/startup.sh
    NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
    count=1
    while [ -z "$NETSTAT" ]; do
        ((count++))
        if [ $count -gt 120 ]; then
            echo "ERROR: Tomcat is not starting in a timely fashion.  Please check $TOMCATDIR/logs/catalina.out for errors."
            echo
            exit
        fi
        sleep 1
        NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
    done
    echo "Tomcat started."
    echo
else
    echo "ERROR:  Tomcat startup script does not exist at $TOMCATDIR/bin/startup.sh"
    echo
    exit
fi

echo "Extracting OpenAM tools..."
unzip -q $CWD/artifacts/openamtools.zip
# Update ssoadm for site configuration
SITEPROP=""
if [ "$SITECONFIG" == "yes" ]; then
    SITEPROP='-D"com.iplanet.am.naming.map.site.to.server='$SITEURL'=http://'$FQDN':8080/auth" \\'  #'
fi
sed -i.bak "s,\${SITEPROP},$SITEPROP," $SSOADM

# Create pwd.txt file for ssoadm
cat $MAINDIR/artifacts/templates/pwd.txt | sed -e "s,\${SSOADMPWD},$PASSWORD,g" > $OPENAMTOOLSDIR/pwd.txt

# Change openamtools ownership
chown -R openam:openam $OPENAMTOOLSDIR

# Set required permissions on password file
chmod 400 $OPENAMTOOLSDIR/pwd.txt

if [ -d $TOMCATDIR ]; then
    echo "The OpenAM Tools have been extracted to the following folder: $OPENAMTOOLSDIR."
    echo
else
    echo "ERROR:  There was an error creating the OpenAM Tools folder structure!"
    echo
    exit
fi

clear
echo "************************************************************************"
echo "*"
echo "* SBAC Environment OpenAM Installation Script"
echo "*"
if [ "$FIRSTINSTANCE" == "yes" ]; then
    echo "* Phase 4: Initial Configuration of OpenAM"
    echo "*"
    echo "* In this phase, the script will create the initial configuration"
    echo "* of OpenAM"
else
    echo "* Phase 4: Add Server to Existing Configuration"
    echo "*"
    echo "* In this phase, the script will add this server to the configuration"
    echo "* of OpenAM on $EXISTINGFQDN"
fi
echo "*"
echo "************************************************************************"
echo "Hit the <ENTER> key to continue"
read CONTINUE

if [ "$FIRSTINSTANCE" == "yes" ]; then
    echo "Creating initial configuration for OpenAM (this may take a few moments)..."
else
    echo "Adding this server to the configuration of OpenAM on $EXISTINGFQDN (this may take a few moments)..."
fi
if [ -d $OPENAMTOOLSDIR ]; then
    export JAVA_HOME=/usr/lib/jvm/java-7-oracle
    java -jar $OPENAMTOOLSDIR/openam-configurator-tool-12.0.0.jar -f $MAINDIR/artifacts/configfiles/config.txt
    # Copy new keystore
    cp $MAINDIR/artifacts/keystore.jks $MAINDIR/openam/auth/keystore.jks
    chown openam:openam $MAINDIR/openam/auth/keystore.jks
    echo
    echo "Stopping tomcat..."
    echo
    if [ -f $TOMCATDIR/bin/shutdown.sh ]; then
        /bin/su - $OPENAMUSER -c $TOMCATDIR/bin/shutdown.sh
        NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
        count=1
        while [[ "$NETSTAT" != "" ]]; do
            ((count++))
            if [ $count -gt 120 ]; then
                echo "ERROR: Tomcat is not shutting down in a timely fashion.  Please check $TOMCATDIR/logs/catalina.out for errors."
                echo
                exit
            fi
            sleep 1
            NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
        done
        echo
        echo "Starting tomcat..."
        echo
        /bin/su - $OPENAMUSER -c $TOMCATDIR/bin/startup.sh
        NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8005"'`
        count=1
        while [ -z "$NETSTAT" ]; do
            ((count++))
            if [ $count -gt 120 ]; then
                echo "ERROR: Tomcat is not starting in a timely fashion.  Please check $TOMCATDIR/logs/catalina.out for errors."
                echo
                exit
            fi
            sleep 1
            NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8005"'`
        done
        echo
        echo "Tomcat restarted."
        echo
    else
        echo "ERROR:  Tomcat shutdown script does not exist at $TOMCATDIR/bin/shutdown.sh"
        echo
        exit
    fi
    echo
else
    echo "ERROR:  $OPENAMTOOLSDIR does not exist."
    echo
    exit
fi

if [ "$FIRSTINSTANCE" == "yes" ]; then
    clear
    echo "************************************************************************"
    echo "*"
    echo "* SBAC Environment OpenAM Installation Script"
    echo "*"
    echo "* Phase 5: Final Configuration of OpenAM"
    echo "*"
    echo "* In this phase, the script will perform the SBAC specific configuration"
    echo "* of OpenAM"
    echo "*"
    echo "************************************************************************"
    echo "Hit the <ENTER> key to continue"
    read CONTINUE

    echo "Final configuration of OpenAM (this may take a few moments)..."
    if [ -f $SSOADM ]; then
        # Create sbac realm
        $SSOADM create-realm --realm sbac -u amadmin -f $PWDFILE
        # Delete embedded DataStore
        $SSOADM delete-datastores -e /sbac -u amadmin -f $PWDFILE -m embedded
        # Create OpenDJ DataStore"
        $SSOADM create-datastore -e /sbac -u amadmin -f $PWDFILE -m OpenDJ -t LDAPv3ForOpenDS -D $MAINDIR/artifacts/configfiles/datastore_info.txt
        # Update LDAP authentication module
        $SSOADM update-auth-instance -e /sbac -u amadmin -f $PWDFILE -m LDAP -D $MAINDIR/artifacts/configfiles/authModule_info.txt
        # Create sbacChain authentication chain
        $SSOADM create-auth-cfg -e /sbac -u amadmin -f $PWDFILE -m sbacChain
        # Update sbacChain chain
        $SSOADM add-auth-cfg-entr -e /sbac -u amadmin -f $PWDFILE  -m sbacChain -o LDAP -c REQUIRED
        # Update Authentication service
        $SSOADM set-svc-attrs -e /sbac -u amadmin -f $PWDFILE -s iPlanetAMAuthService -D $MAINDIR/artifacts/configfiles/iPlanetAMAuthService_info.txt
        # Add Password Reset service
        $SSOADM add-svc-realm -e /sbac -u amadmin -f $PWDFILE -s iPlanetAMPasswordResetService -D $MAINDIR/artifacts/configfiles/iPlanetAMPasswordResetService_info.txt
        # Add OAuth2Provider service
        $SSOADM add-svc-realm -e /sbac -u amadmin -f $PWDFILE -s OAuth2Provider -D $MAINDIR/artifacts/configfiles/OAuth2Provider_info.txt
        # Create OAuth2 Client Group
        $SSOADM create-agent-grp -e /sbac -u amadmin -f $PWDFILE -b sb_client_group -t OAuth2Client -D $MAINDIR/artifacts/configfiles/sb_client_group_info.txt
        # Create OAuth2 Agents
        $SSOADM create-agent -e /sbac -u amadmin -f $PWDFILE -b mna -t OAuth2Client -D $MAINDIR/artifacts/configfiles/OAuth2Client_info.txt
        $SSOADM create-agent -e /sbac -u amadmin -f $PWDFILE -b permissions -t OAuth2Client -D $MAINDIR/artifacts/configfiles/OAuth2Client_info.txt
        $SSOADM create-agent -e /sbac -u amadmin -f $PWDFILE -b pm -t OAuth2Client -D $MAINDIR/artifacts/configfiles/OAuth2Client_info.txt
        $SSOADM create-agent -e /sbac -u amadmin -f $PWDFILE -b testreg -t OAuth2Client -D $MAINDIR/artifacts/configfiles/OAuth2Client_info.txt
        $SSOADM create-agent -e /sbac -u amadmin -f $PWDFILE -b tis -t OAuth2Client -D $MAINDIR/artifacts/configfiles/OAuth2Client_info.txt
        # Add OAuth2 Agents to OAuth2 Client Group
        $SSOADM add-agent-to-grp -e /sbac -u amadmin -f $PWDFILE -b sb_client_group -s mna permissions pm testreg tis
        # Set OAuth2 Agent inheritance from OAuth2 Client Group
        $SSOADM agent-remove-props -e /sbac -u amadmin -f $PWDFILE -b mna -a com.forgerock.openam.oauth2provider.clientType com.forgerock.openam.oauth2provider.defaultScopes com.forgerock.openam.oauth2provider.idTokenSignedResponseAlg com.forgerock.openam.oauth2provider.scopes sunIdentityServerDeviceStatus
        $SSOADM agent-remove-props -e /sbac -u amadmin -f $PWDFILE -b permissions  -a com.forgerock.openam.oauth2provider.clientType com.forgerock.openam.oauth2provider.defaultScopes com.forgerock.openam.oauth2provider.idTokenSignedResponseAlg com.forgerock.openam.oauth2provider.scopes sunIdentityServerDeviceStatus
        $SSOADM agent-remove-props -e /sbac -u amadmin -f $PWDFILE -b pm  -a com.forgerock.openam.oauth2provider.clientType com.forgerock.openam.oauth2provider.defaultScopes com.forgerock.openam.oauth2provider.idTokenSignedResponseAlg com.forgerock.openam.oauth2provider.scopes sunIdentityServerDeviceStatus
        $SSOADM agent-remove-props -e /sbac -u amadmin -f $PWDFILE -b testreg  -a com.forgerock.openam.oauth2provider.clientType com.forgerock.openam.oauth2provider.defaultScopes com.forgerock.openam.oauth2provider.idTokenSignedResponseAlg com.forgerock.openam.oauth2provider.scopes sunIdentityServerDeviceStatus
        $SSOADM agent-remove-props -e /sbac -u amadmin -f $PWDFILE -b tis  -a com.forgerock.openam.oauth2provider.clientType com.forgerock.openam.oauth2provider.defaultScopes com.forgerock.openam.oauth2provider.idTokenSignedResponseAlg com.forgerock.openam.oauth2provider.scopes sunIdentityServerDeviceStatus
        # Create sbac CoT
        $SSOADM create-cot -t sbac -e sbac -u amadmin -f $PWDFILE
        # Create IDP entity
        $SSOADM import-entity -e /sbac -u amadmin -f $PWDFILE -t sbac -m $MAINDIR/artifacts/configfiles/IDP_metadata.xml -x $MAINDIR/artifacts/configfiles/IDP_extended_metadata.xml
        # Set max sessions
        $SSOADM update-server-cfg -u amadmin -f $PWDFILE -s default -a com.iplanet.am.session.maxSessions=100000
        # Set mail server host and port
        $SSOADM update-server-cfg -u amadmin -f $PWDFILE -s default -a com.iplanet.am.smtphost=$MAILSERVER com.iplanet.am.smtpport=$MAILSERVERPORT
        # Enable old password field in End User change password page
        $SSOADM set-attr-defs -u amadmin -f $PWDFILE -s iPlanetAMAdminConsoleService -t Organization -a iplanet-am-admin-console-password-reset-enabled=true
        # Set minimum password length to 6
        $SSOADM set-realm-svc-attrs -u amadmin -f $PWDFILE -s sunIdentityRepositoryService -e /sbac -a sunIdRepoAttributeValidator=minimumPasswordLength=6
        # Disable XUI
        $SSOADM set-attr-defs -u amadmin -f $PWDFILE -s iPlanetAMAuthService -t Global -a openam-xui-interface-enabled=false
        # Remove site FQDN from the / realm and add it to the /sbac realm
        if [ "$SITECONFIG" == "yes" ]; then
            REALMPROPS=`$SSOADM get-realm -u amadmin -f $PWDFILE -e / -s sunIdentityRepositoryService`
            REALMPROPS=$(echo $REALMPROPS | sed -e s/sunOrganizationAliases=$SITEFQDN//g)
            $SSOADM set-realm-attrs -u amadmin -f $PWDFILE -e / -s sunIdentityRepositoryService -a $REALMPROPS
            $SSOADM set-realm-attrs -u amadmin -f $PWDFILE -e /sbac -s sunIdentityRepositoryService -a sunOrganizationAliases=$SITEFQDN
            # Enable Session Failover
            $SSOADM set-sub-cfg -u amadmin -f $PWDFILE -s iPlanetAMSessionService -g sbaclb -o set -a iplanet-am-session-sfo-enabled=true
        fi
        echo
        # Restart Tomcat
        echo "Stopping tomcat..."
        echo
        if [ -f $TOMCATDIR/bin/shutdown.sh ]; then
            /bin/su - $OPENAMUSER -c $TOMCATDIR/bin/shutdown.sh
            NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
            count=1
            while [[ "$NETSTAT" != "" ]]; do
                ((count++))
                if [ $count -gt 120 ]; then
                    echo "ERROR: Tomcat is not shutting down in a timely fashion.  Please check $TOMCATDIR/logs/catalina.out for errors."
                    echo
                    exit
                fi
                sleep 1
                NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
            done
            echo
            echo "Starting tomcat..."
            echo
            /bin/su - $OPENAMUSER -c $TOMCATDIR/bin/startup.sh
            NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8005"'`
            count=1
            while [ -z "$NETSTAT" ]; do
                ((count++))
                if [ $count -gt 120 ]; then
                    echo "ERROR: Tomcat is not starting in a timely fashion.  Please check $TOMCATDIR/logs/catalina.out for errors."
                    echo
                    exit
                fi
                sleep 1
                NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8005"'`
            done
            echo
            echo "Tomcat restarted."
            echo
        else
            echo "ERROR:  Tomcat shutdown script does not exist at $TOMCATDIR/bin/shutdown.sh"
            echo
            exit
        fi
    else
        echo "ERROR:  ssoadm does not exist at $SSOADM"
        echo
        exit
    fi
fi

if [ "$SITECONFIG" == "yes" ]; then
    echo "Install complete.  You may now access the system at $SITEURL/UI/Login."
    echo "The end user change password URL is $SITEURL/idm/EndUser?action=pw."
    echo "The Logout URL is $SITEURL/UI/Logout."
else
    echo "Install complete.  you may now access the system at http://$FQDN:8080/auth/UI/Login"
    echo "The end user change password URL is http://$FQDN:8080/auth/idm/EndUser?action=pw."
    echo "The Logout URL is http://$FQDN:8080/auth/UI/Logout."
fi
echo
echo "Have a nice day!"
