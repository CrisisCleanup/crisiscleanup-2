FROM ruby:2.2.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN gem install bundler
RUN mkdir /crisiscleanup
WORKDIR /crisiscleanup
ADD Gemfile /crisiscleanup/Gemfile
ADD Gemfile.lock /crisiscleanup/Gemfile.lock
RUN bundle install
ADD . /crisiscleanup