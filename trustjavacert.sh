##########################
# Author: Ross Payne
# Org:    UAFS
# Date:   2024-04-03
##########################

if [ "$EUID" -ne 0 ]
  then echo -e "Please use 'sudo'."
  exit
fi

FQDN=$1
PORT=$2
STOREPASS=$3
DATE=$(date +%Y%m%d)
JSSECACERTS="/usr/lib/jvm/jre/lib/security/jssecacerts"
CACERTS="/etc/pki/ca-trust/extracted/java/cacerts"

if [[ $# -ne 3 ]]
then echo -e "Proper usage is trustjavacert.sh FQDN portnumber keystorepass"; exit 1;
fi

echo $FQDN":"$PORT

# Display cert and SHA256 fingerprint for identification
< /dev/null openssl s_client -connect ${FQDN}:${PORT} 2>/dev/null | openssl x509 -noout -sha256 -fingerprint

echo -e "\nAdd this certificate to the system Java trust stores?"
echo ${JSSECACERTS}, ${CACERTS}
read -p "[y/n] "
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Skipping certificate. Exiting."
    exit 1
fi

# Get SHA256 fingerprint of certificate
FINGERPRINT=$(< /dev/null openssl s_client -connect ${FQDN}:${PORT} 2>/dev/null | openssl x509 -noout -sha256 -fingerprint | cut -f2 -d"=")

# Save remote server SSL certificate to /tmp/tmpcert-name-YYYYmmdd.pem
< /dev/null openssl s_client -connect ${FQDN}:${PORT} 2>/dev/null | openssl x509  > /tmp/tmpcert-${FQDN}-${DATE}.pem

# Check /usr/lib/jvm/jre/lib/security/jssecacerts and install cert if needed
echo "Checking if certificate SHA256 fingerprint already exists ${JSSECACERTS}..."
if ! [ -f ${JSSECACERTS} ]
then
    echo "${JSSECACERTS} does not exist. Skipping."
else
    keytool -list -v -keystore ${JSSECACERTS} -storepass "${STOREPASS}" | grep ${FINGERPRINT} 1> /dev/null
    EXITCODE1=$?
    if [ $EXITCODE1 -eq 1 ]
    then
        echo -e "Installing certificate to ${JSSECACERTS}...\n"
        keytool -import -trustcacerts -alias ${FQDN}-${DATE} -file /tmp/tmpcert-${FQDN}-${DATE}.pem -keystore ${JSSECACERTS} -storepass "${STOREPASS}"
    else
        echo "Certificate already in ${JSSECACERTS}."
        sleep 2
    fi
fi

# Check /etc/pki/ca-trust/extracted/java/cacerts and install cert if needed
echo "Checking if certificate SHA256 fingerprint already exists ${CACERTS}..."
if ! [ -f ${CACERTS} ]
then
    echo "${CACERTS} does not exist. Skipping."
else
    keytool -list -v -keystore ${CACERTS} -storepass "${STOREPASS}" | grep ${FINGERPRINT} 1> /dev/null
    EXITCODE2=$?
    if [ $EXITCODE2 -eq 1 ]
    then
        echo -e "Installing certificate to ${CACERTS}...\n"
        keytool -import -trustcacerts -alias ${FQDN}-${DATE} -file /tmp/tmpcert-${FQDN}-${DATE}.pem -keystore ${CACERTS} -storepass "${STOREPASS}"
    else
        echo "Certificate already in ${CACERTS}."
        sleep 2
    fi
fi

echo "Done."
