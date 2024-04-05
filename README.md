# trustjavacert.sh
- author: Ross Payne
- org:    UAFS
- date:   2024-04-03

## Description
This script will connect to a given remote server on a given port. An TLS handshake is attempted with `openssl s_client`.
If successful and the certificate is not already in the sytem's Java trust stores at `/usr/lib/jvm/jre/lib/security/jssecacerts`
and `/etc/pki/ca-trust/extracted/java/cacerts`, the SSL certificate can be added to both.

> [!NOTE]  
> From my research, if the `jssecacerts` keystore exists then the `cacerts` keystore will often be ignored. The `jssecacerts` keystore is functionally an override of the `cacerts` keystore. However, to ensure compatibility, this script will add the given certificate to both keystores.

## Usage
`sudo` privileges are needed for modifying system trust store files.

`sudo ./trustjavacert.sh google.com 443 secretpass`
`sudo ./trustjavacert.sh uafs.edu 9999 secretpass`

## Examples

### Certificate already in both keystores
```
[rossp@server scripts]$ sudo ./trustjavacert.sh $FQDN $PORT $STOREPASS
calendar.uafs.edu:443
SHA256 Fingerprint=B7:74:83:BF:2D:18:06:7D:B7:46:25:4B:B6:B8:8A:34:1B:E5:13:F3:3D:D6:20:C7:4D:F3:15:DD:EB:66:89:7B

Add this certificate to the system Java trust stores?
/usr/lib/jvm/jre/lib/security/jssecacerts, /etc/pki/ca-trust/extracted/java/cacerts
[y/n] y

Checking if certificate SHA256 fingerprint already exists /usr/lib/jvm/jre/lib/security/jssecacerts...
Certificate already in /usr/lib/jvm/jre/lib/security/jssecacerts.
Checking if certificate SHA256 fingerprint already exists /etc/pki/ca-trust/extracted/java/cacerts...
Certificate already in /etc/pki/ca-trust/extracted/java/cacerts.
Done.
```

### Certificate already in one keystore, but not the other
```
[rossp@server scripts]$ sudo ./trustjavacert.sh $FQDN $PORT $STOREPASS
calendar.uafs.edu:443
SHA256 Fingerprint=B7:74:83:BF:2D:18:06:7D:B7:46:25:4B:B6:B8:8A:34:1B:E5:13:F3:3D:D6:20:C7:4D:F3:15:DD:EB:66:89:7B

Add this certificate to the system Java trust stores?
/usr/lib/jvm/jre/lib/security/jssecacerts, /etc/pki/ca-trust/extracted/java/cacerts
[y/n] y

Checking if certificate SHA256 fingerprint already exists /usr/lib/jvm/jre/lib/security/jssecacerts...
Installing certificate to /usr/lib/jvm/jre/lib/security/jssecacerts...

Owner: CN=*.uafs.edu
Issuer: CN=R3, O=Let's Encrypt, C=US

---snip---

Trust this certificate? [no]:  y
Certificate was added to keystore
Checking if certificate SHA256 fingerprint already exists /etc/pki/ca-trust/extracted/java/cacerts...
Certificate already in /etc/pki/ca-trust/extracted/java/cacerts.
Done.
```

### Certificate not found in either keystore
```
[rossp@server scripts]$ sudo ./trustjavacert.sh $FQDN $PORT $STOREPASS
calendar.uafs.edu:443
SHA256 Fingerprint=B7:74:83:BF:2D:18:06:7D:B7:46:25:4B:B6:B8:8A:34:1B:E5:13:F3:3D:D6:20:C7:4D:F3:15:DD:EB:66:89:7B

Add this certificate to the system Java trust stores?
/usr/lib/jvm/jre/lib/security/jssecacerts, /etc/pki/ca-trust/extracted/java/cacerts
[y/n] y

Checking if certificate SHA256 fingerprint already exists /usr/lib/jvm/jre/lib/security/jssecacerts...
Installing certificate to /usr/lib/jvm/jre/lib/security/jssecacerts...

Owner: CN=*.uafs.edu
Issuer: CN=R3, O=Let's Encrypt, C=US

---snip---

Trust this certificate? [no]:  y
Certificate was added to keystore
Checking if certificate SHA256 fingerprint already exists /etc/pki/ca-trust/extracted/java/cacerts...
Installing certificate to /etc/pki/ca-trust/extracted/java/cacerts...

Owner: CN=*.uafs.edu
Issuer: CN=R3, O=Let's Encrypt, C=US

---snip---

Trust this certificate? [no]:  y
Certificate was added to keystore
Done.
```
