FROM alpine:3.12 as config

WORKDIR /opt/config

RUN wget --quiet -O - https://matched.auth0.com/.well-known/jwks.json > rsa.jwk.pub

FROM postgrest/postgrest:v7.0.1

COPY --from=config /opt/config /opt/config

USER 1000

CMD [ "postgrest", "/etc/postgrest.conf" ]