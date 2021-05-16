FROM ethereum/client-go:stable as geth

FROM mwaeckerlin/very-base as build
COPY --chown=${RUN_USER} static-nodes.json /root/home/${RUN_USER}/.ethereum/geth/static-nodes.json
COPY --from=geth /usr/local/bin/geth /usr/bin/geth
RUN tar cp \
    /bin \
    $(which geth) \
    $(for f in $(which geth); do \
    ldd $f | sed -n 's,.* => \([^ ]*\) .*,\1,p'; \
    done 2> /dev/null) 2> /dev/null \
    | tar xpC /root/

FROM mwaeckerlin/scratch
ENV CONTAINERNAME "geth"
EXPOSE  8545 8546 8547 30303
COPY --from=build /root/ /
ENTRYPOINT ["/usr/bin/geth", "--nousb", "--http.addr", "0.0.0.0", "--http.corsdomain", "*", "--http.vhosts", "*", "--ws.addr", "0.0.0.0", "--ws.origins", "*" ]
CMD ["--syncmode", "light", "--http", "--ws"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=12h --retries=4 \
    CMD /bin/sh -c '/usr/bin/geth attach --exec "net.peerCount>0 && !eth.syncing && !!eth.getBalance('"'"'0x05fe7255e0B475A7300A5A4c35e98943BD3bA960'"'"')" | grep -q true'