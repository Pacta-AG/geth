# Docker Image for Ethereum geth Client

## Features

Features compared to the original [ethereum/client-go](https://github.com/ethereum/go-ethereum):

- Smaller Size (39.6MB instead of 44.3MB)
- Health Check

## Build

    docker-compose build

Now, your local image is created with image name `geth_geth`. If you want to use my image from dockerhub, just use `mwaeckerlin/geth`.

## Run

    docker-compose up

## Call With Commandline Parameter

    docker run --rm -it geth_geth --help

## Ports

- `8545`: HTTP-RPC Server
- `8546`: WS-RPC Server
- `8547`: GraphQL Server

## Default Parameter

By default, syncmode is loght and HTTP-RPC and Websocket-RPC server are enabled:

    --syncmode light --http --ws

This can be overwritten by passing parameters as command to entrypoint `geth`, e.g.:

    docker run --rm -it geth_geth --syncmode fast --http --ws

## Hard Coded Parameter

These parameters are configured for best experience, they expose the port to the outside and allow access from any domain. Better do CORS limitations in a proxy that you run in front of geth.

Overwrite with `--entrypoint`:

    /usr/bin/geth \
        --nousb \
        --http.addr 0.0.0.0 \
        --http.corsdomain * \
        --http.vhosts * \
        --ws.addr 0.0.0.0 \
        --ws.origins *
