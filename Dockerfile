FROM ruby:2.7.1-alpine3.12

WORKDIR /app

RUN apk add --no-cache build-base git postgresql-dev postgresql-client
