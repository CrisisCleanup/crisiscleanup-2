# Contributing

## Developer Pull Request Process
1. Github issue created 
2. Create feature branch based off of the latest from the `master` branch
3. Local development and testing
4. Create pull request into `staging` branch.  Add reviewers and comments. (triggers circleci)
5. Reviewers will then approve the PR, provide feedback, and then merge into staging

## Reviewers and Testers
1. Reviewer approves the PR and merges into the `staging` branch (triggers a staging environment deployment) 
2. Reviewer creates a new PR set to merge into `master`.  Reviewer adds testers to PR.
3. Testers verify PR/issue in the staging environment.
4. All parties approve PR.  Reviewer merges and closes PR into master and triggers a production deployment.
5. Smoke test

## Pre-Reqs
1. Ruby 2.2.5 (use rbenv or RVM) 
	- with `bundler` gem installed i.e. `gem install bundler`
2. `docker` and `docker-compose`

## Setup
The development environment is containerized using Docker compose. This is the fastest way to get up and running with the correct version of Ruby/Rails. Ensure you have docker installed and running.

1. Clone repo: `git clone git@github.com:CrisisCleanup/crisiscleanup.git`
1. `cd crisiscleanup`
1. API keys and environment variables
	- Google Maps API key - The map feature of CCU uses the Google Maps API.  Currently, the referrer URL settings do not allow for `localhost` to access the API with that key.  Replace the API key value in this file with your own API key: `app/assets/javascripts/plugins/google.js`
	- AWS keys - Several features of CCU use the AWS S3 and SNS services.  The sample `.env.development.sample` file should be copied and name to `.env.development` personal AWS API keys entered.
1. Build the docker image (needed right after cloning and any time the Bundlefile, Bundlefile.lock, or Dockerfile changes)
	- `docker-compose build`
1. Data Migration
	- Using seed data:
		- `docker-compose run --rm web bundle exec rake db:setup` (creates and migrates)
	- Using a DB dumpfile:
		- `docker-compose run --rm web bundle exec rake db:create`
		- `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U crisiscleanup -d crisiscleanup_development dev.dump` (PW: crisiscleanup)
1. Server Start
	- `$ docker-compose up` (optionally add `-d` to run the app as a daemon in the background)
1. Testing. Testing currently happens outside the docker container, but will by default access the database running in Docker.
	- Create the test database
		- `RAILS_ENV=test bundle exec rake db:setup`
	- Run the test suite
		- `RAILS_ENV=test bundle exec rspec`
1. Cleanup
	- To tear down (preserves data)
		- `$ docker-compose down`
	- To tear down including the volumes (database)
		- `$ docker-compose down -v`

### Running the Project Without Docker

The project can be run without Docker.

Dependencies:
1. A postgres server on localhost with the default port.
1. A redis server on localhost with the default port.

Run the rails app normally (e.g. `bundle exec rails s -p 3000 -b '0.0.0.0'`).