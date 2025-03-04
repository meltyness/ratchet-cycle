#!/bin/bash

cd /ratchet

# Apparently there is disagreement about the file
# perms depending on the build context; they ought to be +x
chmod +x *.sh
useradd -M -N -s /bin/bash ratchet
chown ratchet ./
chown ratchet ./*
chmod +rw ./
su -m ratchet

if [ ! -e "key.pem" ]; then
    openssl genrsa -passout pass:$RATCHET_PAWL_MASKING_KEY -aes256 -out key.pem 4096
    openssl req -x509 \
        -new \
        -key key.pem -passin pass:$RATCHET_PAWL_MASKING_KEY \
        -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=localhost" \
        -addext "subjectAltName = DNS:localhost,IP:127.0.0.1,IP:::1"
fi

if [ ! -e "fake_key.pem" ]; then
    mkfifo "fake_key.pem"
fi

openssl rsa -in key.pem -passin pass:$RATCHET_PAWL_MASKING_KEY 2>/dev/null > fake_key.pem &

coproc PAWL { ratchet-pawl; }

RATCHET_PAWL_API_KEY=""

NUM_RUNS=300

for i in $(seq 0 $NUM_RUNS)
do
    read -r line < /dev/fd/${PAWL[0]}
    if [[ "$line" == *"Api-Key: "* ]]; then
        RATCHET_PAWL_API_KEY=$(echo "$line" | awk -F'Api-Key: ' '{print $2}')
        break
    else
        echo "Looking at $line"
        continue
    fi
done

while ! nc -z ::1 8000; do
    sleep 1;
done

# echo "Fetched API Key: ${RATCHET_PAWL_API_KEY}"
export RATCHET_PAWL_API_KEY

ratchet & cat - < /dev/fd/${PAWL[0]}
