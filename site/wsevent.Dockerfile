FROM oven/bun:alpine

WORKDIR /app/
RUN bun install yargs qu ws simplesets

EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

ENTRYPOINT bun /app/websocket/daemon.js
