# Contributing

## Developer Pull Request Process
1. Github issue created or assigned. 
2. Feature branch is created based on the latest from the `master` branch.
   * Developer forks the repository if (s)he isn't part of the core team and thus does not have permission to commit to the main CrisisCleanup repo. 
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
3. `node/npm` (Optionally, but preferred also install `yarn`)

### Macs
1. [Homebrew](https://brew.sh)
1. Command-line tools - either install Xcode or run `xcode-select --install` from a terminal
1. Postgres headers (for `pg` gem installation) - `brew install postgres`

## Setup
1. Clone repo: `git clone git@github.com:CrisisCleanup/crisiscleanup.git`
   * Clone fork, if applicable, instead of main repo.
2. `cd crisiscleanup`
3. `bundle install`
4. `docker-compose up -d postgres redis` (docker should be installed and running)
5. API keys and environment variables
	- Create your own `.env.development` in the repository base, based on `.env.development.sample`.
	- (Required) You will need your own [Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key)
	- (Optional) You will also need to use your own AWS API key if you need to develop SNS or S3 features.
6. Data Migration - 
	- Using seed data:
		- `bin/rake db:setup` (creates and migrates in one step)
	        - (Mac/HomeBrew) If you encounter an error about byebug and readline, you can work around it by symlinking readline:    
	        `ln -s /usr/local/opt/readline/lib/libreadline.dylib /usr/local/opt/readline/lib/libreadline.6.dylib`
	- (OPTIONAL) Using a DB dumpfile:
		- `bin/rake db:create`
		- `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U crisiscleanup -d crisiscleanup_development dev.dump` (PW: crisiscleanup)
7. Use NPM or YARN to install node dependencies
	- For `NPM`: `npm install`
	- For `YARN`: `yarn` (preferred)
8. Server Start
	- `bin/rails server` - App should be available at `http://localhost:3000`
		- Default credentials:
			- Admin user: `admin@example.com` with password `password`
			- Primary Contact user: `demo@crisiscleanup.org` with password `password`
9. Testing 
	- `chromedriver` is required for now (use `homebrew` or place binary on `PATH`)
	- `RAILS_ENV=test bundle exec rspec`
10. Cleanup
	- `docker-compose down` (will destroy your local dev database)
