#asterisk docker file for unraid 6
FROM phusion/baseimage:0.11
MAINTAINER marc brown <https://github.com/Brownster> v0.1
# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV ASTERISKUSER asterisk
ENV ASTERISKVER 16.1.0
ENV ASTERISK_DB_PW pass123
ENV AUTOBUILD_UNIXTIME 1418234402
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
# Add start.sh
ADD start.sh /root/
#Install deps
RUN apt-get update \
    && apt-get install -y \
        build-essential \
        openssl \
        libxml2-dev \
        libncurses5-dev \
        uuid-dev \
        sqlite3 \
        libsqlite3-dev \
        pkg-config \
        libjansson-dev \
        libssl-dev \
        curl \
        msmtp
# add asterisk user
RUN groupadd -r $ASTERISKUSER \
  && useradd -r -g $ASTERISKUSER $ASTERISKUSER \
  && mkdir /var/lib/asterisk \
  && chown $ASTERISKUSER:$ASTERISKUSER /var/lib/asterisk \
  && usermod --home /var/lib/asterisk $ASTERISKUSER \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get purge -y
#build pj project
#build jansson
WORKDIR /temp/src/
RUN git clone https://github.com/asterisk/pjproject.git 1>/dev/null \
  && git clone https://github.com/akheron/jansson.git 1>/dev/null \
  && cd /temp/src/pjproject \
  && ./configure --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr 1>/dev/null \
  && make dep 1>/dev/null \
  && make 1>/dev/null \
  && make install 1>/dev/null \
  && cd /temp/src/jansson \
  && autoreconf -i 1>/dev/null \
  && ./configure 1>/dev/null \
  && make 1>/dev/null \
  && make install 1>/dev/null \  
# Download asterisk.
# $ASTERISKVER (16.1.0).
  && curl -sf -o /tmp/asterisk.tar.gz -L http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-$ASTERISKVER.tar.gz 1>/dev/null \
# gunzip asterisk
  && mkdir /tmp/asterisk \
  && tar -xzf /tmp/asterisk.tar.gz -C /tmp/asterisk --strip-components=1 1>/dev/null
WORKDIR /tmp/asterisk
# make asterisk.
RUN mkdir /etc/asterisk \
# Configure
  && ./configure --with-ssl=/opt/local --with-crypto=/opt/local 1> /dev/null \
# Remove the native build option
  && make menuselect.makeopts 1>/dev/null \
#  && sed -i "s/BUILD_NATIVE//" menuselect.makeopts 1>/dev/null \
  && menuselect/menuselect --enable chan_sip.so --disable BUILD_NATIVE  --enable CORE-SOUNDS-EN-WAV --enable CORE-SOUNDS-EN-SLN16 --enable MOH-OPSOUND-WAV --enable MOH-OPSOUND-SLN16 menuselect.makeopts 1>/dev/null \
# Continue with a standard make.
  && make 1> /dev/null \
  && make install 1> /dev/null \
  && make config 1>/dev/null \
  && ldconfig \
  && cd /var/lib/asterisk/sounds \
  && wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz 1>/dev/null \
  && tar xfz asterisk-extra-sounds-en-wav-current.tar.gz 1>/dev/null \
  && rm -f asterisk-extra-sounds-en-wav-current.tar.gz 1>/dev/null \
  && wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz 1>/dev/null \
  && tar xfz asterisk-extra-sounds-en-g722-current.tar.gz 1>/dev/null \
  && rm -f asterisk-extra-sounds-en-g722-current.tar.gz \
  && chown $ASRERISKUSER. /var/run/asterisk \
  && chown -R $ASTERISKUSER. /etc/asterisk \
  && chown -R $ASTERISKUSER. /var/lib/asterisk \
  && chown -R $ASTERISKUSER. /var/log/asterisk \
  && chown -R $ASTERISKUSER. /var/spool/asterisk \
  && chown -R $ASTERISKUSER. /var/run/asterisk \
  && chown -R $ASTERISKUSER. /var/lib/asterisk \
#clean up
  && find /temp -mindepth 1 -delete \
  && apt-get purge -y \
  && apt-get --yes autoremove \
  && apt-get clean all \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD bash -C '/root/start.sh';'bash' 
