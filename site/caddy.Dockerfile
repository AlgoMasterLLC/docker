FROM caddy:2-builder AS builder

RUN apk add build-base git make pkgconfig python3-dev

RUN CGO_ENABLED=1 xcaddy build --with github.com/mliezun/caddy-snake

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
