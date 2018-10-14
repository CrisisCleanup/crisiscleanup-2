# Contributing

## Developer Pull Request Process
1. Github issue created or assigned. 
1. Feature branch is created based on the latest from the `master` branch.
   * Developer forks the repository if (s)he isn't part of the core team and thus does not have permission to commit to the main CrisisCleanup repo. 
1. Local development and testing is performed **including** writing unit and functional tests for new features and bugs.
1. Create a pull request into the `master` branch.  Add reviewers and comments. (will trigger CircleCI)
1. Reviewers will then approve the PR, provide feedback, and then merge into the `staging` environment.

## Reviewers and Testers
1. Reviewer triggers a staging environment deployment
1. Testers verify PR/issue in the staging environment.
1. All parties approve developer PR.  Reviewer merges and closes PR into master and triggers a production deployment.
1. Smoke testing in `production` environment

## Docker-based Development Environment (ideal)

### Pre-reqs
1. `docker 1.17+` and `docker-compose 1.22+`

### Setup
1. Clone repo: `git clone git@github.com:CrisisCleanup/crisiscleanup.git`
   * Clone fork, if applicable, instead of main repo.
1. `cd crisiscleanup`
1. API keys and environment variables
	- Create your own `.env.docker` in the repository base, based on `.env.development.sample`.
	    - i.e. `cp .env.docker.sample .env.docker` and replace the values in `.env.docker`
	- (Required) You will need your own [Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key)
	- (Optional) You will also need to use your own AWS API key if you need to develop SNS or S3 features.
1. `docker-compose build`
1. `docker-compose up -d`
1. Access web app at `http://localhost:8080`
1. Web container will hot-reload with code changes

### Useful commands
1. `docker-compose stop web && docker-compose rm web && docker-compose build --no-cache web && docker-compose up -d web` - Stop, remove, clean build, and re-deploy web container only
1. `docker-compose down -v` - Take down entire app including postgres data volumes

### Docker - Testing
1. `docker-compose exec web bash -c "RAILS_ENV=test POSTGRES_HOST=postgres bin/rake db:create"`
2. `docker-compose exec web bash -c "RAILS_ENV=test POSTGRES_HOST=postgres bundle exec rspec"`

## Local (outside of docker) Environment

### Pre-Reqs
1. Ruby 2.2.5 (use rbenv or RVM) 
	- with `bundler` gem installed i.e. `gem install bundler`
1. `docker` and `docker-compose`
1. `node/npm` (Optionally, but preferred also install `yarn`)

### Macs
1. [Homebrew](https://brew.sh)
1. Command-line tools - either install Xcode or run `xcode-select --install` from a terminal
1. Postgres headers (for `pg` gem installation) - `brew install postgres`

### Setup
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
		- `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d postgres dev.dump` (PW: crisiscleanup)
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
	- `docker-compose down -v` (will destroy your local dev database)