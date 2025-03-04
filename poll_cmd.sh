if [ $# -gt 0 ]; then
    curl --cacert /ratchet/cert.pem -s -H "X-Ratchet-Api-Key: ${RATCHET_PAWL_API_KEY}" https://localhost:8000/api/longpoll?serial=$1
else
    curl --cacert /ratchet/cert.pem -s -H "X-Ratchet-Api-Key: ${RATCHET_PAWL_API_KEY}" https://localhost:8000/api/longpoll
fi