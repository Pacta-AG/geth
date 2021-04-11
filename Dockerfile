FROM mwaeckerlin/very-base as build
COPY --chown=${RUN_USER} static-nodes.json /root/home/${RUN_USER}/.ethereum/geth/static-nodes.json
RUN $PKG_INSTALL geth wget
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
ENTRYPOINT ["/usr/bin/geth", "--nousb", "--http.addr", "0.0.0.0", "--http.corsdomain", "*", "--http.vhosts", "*", "--ws.addr", "0.0.0.0", "--ws.origins", "*", "--graphql.addr", "0.0.0.0", "--graphql.corsdomain", "*", "--graphql.vhosts", "*"]
CMD ["--syncmode", "fast", "--http", "--ws", "--graphql"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=12h --retries=4 \
    CMD [ "/bin/sh" "-c", "/usr/bin/geth attach --exec \"net.peerCount>0 && !eth.syncing && !!eth.getBalance('0x05fe7255e0B475A7300A5A4c35e98943BD3bA960')\" | grep -q true"]