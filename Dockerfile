# Stage 1: Build and Prune
FROM rust:1-slim-bookworm AS builder

RUN apt-get -y update && apt-get install -y npm
RUN cargo install --git https://github.com/meltyness/ratchet-pawl
RUN cargo install --git https://github.com/meltyness/ratchet

RUN find /usr/local/cargo -path "*/node_modules/*" -delete

# Stage 2: Install and Launch
FROM debian:bookworm-slim

COPY --from=builder /usr/local/cargo /usr/local/cargo

ENV PATH="$PATH:/usr/local/cargo/bin"
# Each of the *_cmd depends on curl.
RUN apt-get -y update && apt-get install -y curl netcat-openbsd

# https://rocket.rs/guide/v0.5/configuration/#environment-variables
ENV ROCKET_ADDRESS=::
ENV ROCKET_PORT=8000
ENV ROCKET_TLS='{certs="/ratchet/cert.pem",key="/ratchet/fake_key.pem"}'

# https://github.com/meltyness/ratchet/blob/main/README.md#building--running--configuring
ENV RATCHET_CUST_HOSTPORT="[::]:4449"
ENV RATCHET_READ_CLIENTS="/ratchet/clients_cmd.sh"
ENV RATCHET_READ_CREDS="/ratchet/creds_cmd.sh"
ENV RATCHET_USER_CMD_POLICY="/ratchet/user_policy_cmd.sh"
ENV RATCHET_LONG_POLL="/ratchet/poll_cmd.sh"
EXPOSE 8000
EXPOSE 4449

ADD "./ratchet-cycle.sh" "/ratchet/"
ADD "./clients_cmd.sh" "/ratchet/"
ADD "./creds_cmd.sh" "/ratchet/"
ADD "./user_policy_cmd.sh" "/ratchet/"
ADD "./poll_cmd.sh" "/ratchet/"

CMD ["/bin/bash", "/ratchet/ratchet-cycle.sh"]
