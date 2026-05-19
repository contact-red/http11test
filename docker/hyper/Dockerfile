FROM rust:alpine AS build

RUN apk add --no-cache musl-dev

WORKDIR /app

COPY Cargo.toml ./
COPY src ./src
RUN cargo build --release

FROM alpine:latest

COPY --from=build /app/target/release/http-test-target /usr/local/bin/

EXPOSE 80
CMD ["http-test-target"]
