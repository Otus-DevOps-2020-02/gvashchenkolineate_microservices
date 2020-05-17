FROM alpine:3.11.6

ARG BUNDLER_VERSION=1.17.2

RUN apk add --no-cache ruby-full ruby-dev build-base \
  && gem install bundler:$BUNDLER_VERSION

WORKDIR /app

COPY Gemfile* ./
RUN bundle install
COPY . .

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
