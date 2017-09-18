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
1. Clone repo: `git clone git@github.com:CrisisCleanup/crisiscleanup.git`
2. `cd crisiscleanup`
3. `docker-compose up -d` (docker should be installed and running)
4. API keys and environment variables
	- Google Maps API key - The map feature of CCU uses the Google Maps API.  Currently, the referrer URL settings do not allow for `localhost` to access the API with that key.  Replace the API key value in this file with your own API key: `app/assets/javascripts/plugins/google.js`
	- AWS keys - Several features of CCU use the AWS S3 and SNS services.  The sample `.env.development.sample` file should be copied and name to `.env.development` personal AWS API keys entered.
5. Data Migration - 
	- Using seed data:
		- `bin/rake db:setup` (creates and migrates)
	- Using a DB dumpfile:
		- `bin/rake db:create`
		- `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U crisiscleanup -d crisiscleanup_development dev.dump` (PW: crisiscleanup)
6. Server Start
	- `bin/rails server`
7. Testing 
	- `RAILS_ENV=test bundle exec rspec`
8. Cleanup
	- `docker-compose down` (will destroy the database)