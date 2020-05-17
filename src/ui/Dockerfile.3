FROM alpine:3.11.6

ARG BUNDLER_VERSION=1.17.2

RUN apk add --no-cache ruby-full ruby-dev build-base \
  && gem install bundler:$BUNDLER_VERSION

WORKDIR /app

COPY Gemfile* ./
RUN bundle install
COPY . .

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
