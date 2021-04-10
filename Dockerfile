FROM mwaeckerlin/very-base as build
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
EXPOSE  8545 8546 
COPY --from=build /root/ /
ENTRYPOINT ["/usr/bin/geth", "--nousb", "--http.addr", "0.0.0.0", "--http.corsdomain", "*", "--http.vhosts", "*", "--ws.addr", "0.0.0.0", "--ws.origins", "*", "--graphql.addr", "0.0.0.0", "--graphql.corsdomain", "*", "--graphql.vhosts", "*"]
CMD ["--http", "--ws", "--graphql"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=10 \
    CMD [ "/bin/sh", "-c", "(/usr/bin/geth attach --exec admin.peers | grep -qve '\[\]') && (/usr/bin/geth attach --exec eth.syncing | grep -q false)" ]