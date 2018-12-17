# Asterisk-16-Docker
Docker for Unraid 6 very much WIP


sudo docker run --name asterisk-16
-v /mnt/user/appdata/asterisk/msmtprc:/etc/msmtprc
-v /mnt/user/appdata/asterisk/etc/asterisk:/etc/asterisk
-v /mnt/user/appdata/asterisk/var/lib/asterisk:/var/lib/asterisk
-v /mnt/user/appdata/asterisk/var/spool/asterisk:/var/spool/asterisk
-v /mnt/user/appdata/asterisk/var/ssl:/ssl
 -net=host -d -t brownster/asterisk-16-docker    
