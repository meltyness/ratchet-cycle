#!/bin/bash

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=localhost"

coproc PAWL { ratchet-pawl; }

RATCHET_PAWL_API_KEY=""

NUM_RUNS=10

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

# echo "Fetched API Key: ${RATCHET_PAWL_API_KEY}"
export RATCHET_PAWL_API_KEY

 ratchet & cat - < /dev/fd/${PAWL[0]}
