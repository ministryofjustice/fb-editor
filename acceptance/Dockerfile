FROM ruby:3.1.3-alpine3.16

ARG UID=1001

RUN apk add git yarn build-base postgresql-contrib postgresql-dev bash libcurl
RUN apk add build-base bash tzdata chromium-chromedriver chromium zlib-dev xorg-server

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ nodejs npm

WORKDIR /usr/src/app

COPY Gemfile* ./
RUN gem update --system && gem install bundler
RUN bundle check || BUNDLE_JOBS=4 bundle install

COPY acceptance acceptance
COPY .env.acceptance_tests .
