FROM ruby:2.5

RUN apt-get update && apt-get install -y nodejs
RUN apt-get install -y cron

RUN mkdir /jett-api
WORKDIR /jett-api

ADD Gemfile /jett-api/Gemfile
ADD Gemfile.lock /jett-api/Gemfile.lock 

RUN gem install bundler
RUN bundle update --bundler
RUN bundle install

ADD . /jett-api
RUN bundle exec whenever --update-crontab --set environment=development

EXPOSE 3000
