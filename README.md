> [!WARNING]
> This is prototype-phase software, please use with caution!

# ratchet-cycle
> cliicckkkkk, cliickkkk

## Building 
The docker image is built simply with a docker command like this this:
``` bash
docker build --no-cache -t ratchet-cycle .
```

## Operating
Once `ratchet-cycle` is installed, a container can be launched with.
``` bash
# Replace RATCHET_PAWL_MASKING_KEY with something private, non-obvious, and permanent.
docker run -p 49:4449 -p 443:8000 -e RATCHET_PAWL_MASKING_KEY=1234 ratchet-cycle

# Monitor output for the initial username and password.
```

And navigate to https://localhost which will have a self-signed hosted HTTPS site for you to administer `ratchet`.

## Architectural Overview
`ratchet-pawl` writes out a file called `ratchet_db.redb`. That file is encrypted using the AES256 key written in `RATCHET_PAWL_MASKING_KEY`, so if you intend to recover it then you could ensure that the same key is used from one deployment to another; for example if a volume-container architectural separation is desired.

On first launch, an API key is intialized and written into the embedded database. The same API key is spewed to `stdout` by `ratchet-pawl` and then scooped up by `ratchet-cycle` and handed over to the `clients`, `creds`, and `long-poll` commands.

Speaking of which, `ratchet` associates to `pawl` through the following 3 interfaces:
- `clients` which lists TACACS+ client networks and their associated keys
- `creds` which lists authenticateable users, and the hash of their password
- `long-poll` which busy-waits until clients or creds contain interesting changes, which `ratchet` then scoops up, at its leisure.
  - This means that there's a max rate at which `clients` and `creds` can reasonably be updated, but it's probably fine, don't worry about it.
