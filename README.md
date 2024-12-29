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
