FROM rust:1.83-bullseye

RUN apt-get -y update && apt-get install -y npm

RUN cargo install --git https://github.com/meltyness/ratchet-pawl --branch devel/long-polling
RUN cargo install --git https://github.com/meltyness/ratchet --branch devel/long-polling

# https://rocket.rs/guide/v0.5/configuration/#environment-variables
ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8000
ENV ROCKET_TLS='{certs="/cert.pem",key="/key.pem"}'

# https://github.com/meltyness/ratchet/blob/main/README.md#building--running--configuring
ENV RATCHET_CUST_HOSTPORT="[::]:4449"
ENV RATCHET_READ_CLIENTS="/clients_cmd.sh"
ENV RATCHET_READ_CREDS="/creds_cmd.sh"
ENV RATCHET_LONG_POLL="/poll_cmd.sh"
EXPOSE 8000
EXPOSE 4449

ADD "./ratchet-cycle.sh" "/"
ADD "./clients_cmd.sh" "/"
ADD "./creds_cmd.sh" "/"
ADD "./poll_cmd.sh" "/"

CMD ["/bin/bash", "/ratchet-cycle.sh"]