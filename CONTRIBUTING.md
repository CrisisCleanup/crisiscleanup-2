# Contributing

## Developer Pull Request Process
1. Github issue created or assigned. 
2. Feature branch is created based on the latest from the `master` branch.
3. Local development and testing is performed **including** writing unit and functional tests for new features and bugs.
4. Create a pull request into the `master` branch.  Add reviewers and comments. (will trigger CircleCI)
5. Reviewers will then approve the PR, provide feedback, and then merge into the `staging` environment.

## Reviewers and Testers
1. Reviewer triggers a staging environment deployment
2. Testers verify PR/issue in the staging environment.
3. All parties approve developer PR.  Reviewer merges and closes PR into master and triggers a production deployment.
4. Smoke testing in `production` environment

## Pre-Reqs
1. Ruby 2.2.5 (use rbenv or RVM) 
	- with `bundler` gem installed i.e. `gem install bundler`
2. `docker` and `docker-compose`
3. `node/npm` (Also optionally `yarn`) (`nvm` recommended for `node` management)

## Setup
1. Clone repo: `git clone git@github.com:CrisisCleanup/crisiscleanup.git`
2. `cd crisiscleanup`
3. `docker-compose up -d postgres redis` (docker should be installed and running)
4. API keys and environment variables
	- Create your own `.env.development` in the repository base, based on `.env.development.sample`.
	- (Required) You will need your own [Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key)
	- (Optional) You will also need to use your own AWS API key if you need to develop SNS or S3 features.
5. Data Migration - 
	- Using seed data:
		- `bin/rake db:setup` (creates and migrates in one step)
	- (OPTIONAL) Using a DB dumpfile:
		- `bin/rake db:create`
		- `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U crisiscleanup -d crisiscleanup_development dev.dump` (PW: crisiscleanup)
6. Server Start
	- `bin/rails server`
7. Testing 
	- `RAILS_ENV=test bundle exec rspec`
8. Cleanup
	- `docker-compose down` (will destroy the database)