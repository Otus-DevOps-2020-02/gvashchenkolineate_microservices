FROM ruby:2.2

RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app

COPY Gemfile* ./
RUN bundle install
COPY . .

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
