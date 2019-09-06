from invoke import task
import time

ENV = 'dev'
ENVS = ['dev']
SERVICES = []

BASE_COMPOSE_CMD = "docker-compose -f docker-compose.yml"

NAME_ARG_HELP = 'Name of service'
ENV_ARG_HELP = "Name of environment to use - dev, test, perf"
NOCACHE_ARG_HELP = 'Build with no docker layer caching'

SERVICES = {
    'postgres': {
        'buildable': False,
        'context': '.',
    },
    'redis': {
        'buildable': False,
        'context': '.',
    },
    'web': {
        'buildable': True,
        'context': '.',
    }   
}

@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP
})
def stop_svc(c, name, env='dev'):
    """
    Docker-compose - Stop a compose service
    """
    print('STOPPING {0} WITH ENV: {1}'.format(name, env))
    cmd1 = "{0} -f docker-compose.{1}.yml stop {2}".format(BASE_COMPOSE_CMD, env, name)
    cmd2 = "{0} -f docker-compose.{1}.yml rm -f {2}".format(BASE_COMPOSE_CMD, env, name)
    c.run(cmd1)
    c.run(cmd2)
    
@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP,
    'nocache': NOCACHE_ARG_HELP
})
def build_svc(c, name, env='dev', nocache=False):
    """
    Docker-compose - Build a compose service
    """
    print('BUILDING {0} WITH ENV: {1}'.format(name, env))
    nocache_flag = ''
    if nocache:
        nocache_flag = "--no-cache"
    cmd = "{0} -f docker-compose.{1}.yml build {2} {3}".format(BASE_COMPOSE_CMD, env, nocache_flag, name)
    c.run(cmd)    
    
@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP
})
def up_svc(c, name, env='dev'):
    """
    Docker-compose - Deploy (up) and daemonize a compose service
    """
    print('UP {0} WITH ENV: {1}'.format(name, env))
    cmd = "{0} -f docker-compose.{1}.yml up -d {2}".format(BASE_COMPOSE_CMD, env, name)
    c.run(cmd)
    
@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP
})
def restart_svc(c, name, env='dev'):
    """
    Restart service
    """
    print('RESTARTING {0} WITH ENV: {1}'.format(name, env))
    cmd = "{0} -f docker-compose.{1}.yml restart {2}".format(BASE_COMPOSE_CMD, env, name)
    c.run(cmd)   

@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP,
    'nocache': NOCACHE_ARG_HELP
})
def rebuild_svc(c, name, env='dev', nocache=False):
    """
    Docker-compose - Restart a compose service
    """
    print('REBUILDING {0} WITH ENV: {1}'.format(name, env))
    stop_svc(c, name, env)
    build_svc(c, name, env, nocache)
    up_svc(c, name, env)
    
@task(help = {
    'nocache': NOCACHE_ARG_HELP
})
def rebuild_db(c, nocache=False):
    """
    Docker-compose - Rebuild db
    """
    print('REBUILDING DEV ENV')
    c.run('docker-compose down -v')
    rebuild_svc(c, 'redis', 'dev', nocache)
    rebuild_svc(c, 'postgres', 'dev', nocache)    
    rebuild_svc(c, 'web', 'dev')
    time.sleep(15)
    c.run('./migrate_real_data.sh', pty=True)   
    cmd = 'docker-compose exec web bash -c "RAILS_ENV=docker bin/rake db:migrate"'
    c.run(cmd, pty=True)
    
@task(help = {})
def migrate_db(c):
    """
    Migrate DB
    """
    print('MIGRATING DB')
    c.run('docker-compose exec web bash -c "RAILS_ENV=docker bin/rake db:migrate"', pty=True)
    
@task(help = {
    'nocache': NOCACHE_ARG_HELP
})
def rebuild_dev_env(c, nocache=False):
    """
    Docker-compose - Rebuild dev env
    """
    print('REBUILDING DEV ENV')
    rebuild_svc(c, 'redis', 'dev', nocache)    
    rebuild_svc(c, 'postgres', 'dev', nocache)    
    rebuild_svc(c, 'web', 'dev', nocache)       
    cmd = 'docker-compose exec web bash -c "RAILS_ENV=docker bin/rake db:setup"'
    c.run(cmd, pty=True)
    c.run('./migrate_real_data.sh', pty=True)
    
@task(help = {
})
def up_dev_env(c):
    """
    Docker-compose - Up dev env
    """
    up_svc(c, 'redis', 'dev')    
    up_svc(c, 'postgres', 'dev')    
    up_svc(c, 'web', 'dev')    

@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP
})
def logs(c, name, env='dev'):
    """
    Docker-compose - Print service container logs for a given service and environment.
    """
    cmd = "{0} -f docker-compose.{1}.yml logs --tail=500 -f {2}".format(BASE_COMPOSE_CMD, env, name)
    c.run(cmd)
    
@task(help = {
    'env': ENV_ARG_HELP
})
def ps(c, env='dev'):
    """
    Docker-compose - View status of compose services in a given environment.
    """
    cmd = "{0} -f docker-compose.{1}.yml ps".format(BASE_COMPOSE_CMD, env)
    c.run(cmd)    
    
def down_all(c, env='dev'):
    """
    Docker-compose - Destroy all compose services.
    """
    print('DESTROYING ALL SERVICES IN ENV')
    for env in ENVS:
        cmd = "{0} -f docker-compose.{1}.yml down -v".format(BASE_COMPOSE_CMD, env)
        c.run(cmd)       
        
def stop_all(c, env='dev'):
    """
    Docker-compose - Stop all services for a given environment
    """
    print('STOPPING ALL SERVICES IN ENV: {0}'.format(env))
    cmd = "{0} -f docker-compose.{1}.yml stop".format(BASE_COMPOSE_CMD, env)
    c.run(cmd)           
    
@task(help = {
    'name': NAME_ARG_HELP,
    'env': ENV_ARG_HELP
})
def execute(c, name, env='dev'):
    """
    Docker-compose - Exec service
    """
    cmd = "{0} -f docker-compose.{1}.yml exec {2} bash".format(BASE_COMPOSE_CMD, env, name)
    c.run(cmd, pty=True)   
    
@task(help = {})
def rebuild_test_db(c, env='dev'):
    """
    Build test database
    """
    # cmd = '{0} -f docker-compose.{1}.yml exec web bash -c "RAILS_ENV=test POSTGRES_HOST=postgres bin/rake db:drop"'.format(BASE_COMPOSE_CMD, env)
    # c.run(cmd, pty=True)      
    cmd = '{0} -f docker-compose.{1}.yml exec web bash -c "RAILS_ENV=test POSTGRES_HOST=postgres bin/rake db:reset"'.format(BASE_COMPOSE_CMD, env)
    c.run(cmd, pty=True)      
    
@task(help = {})
def rspec(c, env='dev', rebuild_test_db=False):
    """
    Run rspec tests
    """
    if rebuild_test_db:
        rebuild_test_db(env)
    cmd = '{0} -f docker-compose.{1}.yml exec web bash -c "RAILS_ENV=test POSTGRES_HOST=postgres bundle exec rspec"'.format(BASE_COMPOSE_CMD, env)
    c.run(cmd, pty=True)      
    
@task(help = {})
def copy_test(c, env='dev'):
    """
    Run rspec tests
    """
    cmd1 = "docker cp ./phone_area_codes.sql crisiscleanup_postgres_1:/tmp"
    cmd2 = 'docker-compose exec postgres bash -c "cat /tmp/phone_area_codes.sql | psql -U postgres -d crisiscleanup_test"'
    c.run(cmd1, pty=True)         
    c.run(cmd2, pty=True)         
    
@task(help = {
    'path': 'Path to spec - e.g. spec/controllers/phone'
})
def rspec_specific(c, path, env='dev', rebuild_test_db=False):
    """
    Run specific rspec tests
    """
    if rebuild_test_db:
        rebuild_test_db(env)
    cmd = '{0} -f docker-compose.{1}.yml exec web bash -c "RAILS_ENV=test POSTGRES_HOST=postgres bundle exec rspec {2}"'.format(BASE_COMPOSE_CMD, env, path)
    c.run(cmd, pty=True)    

@task(help = {
})
def psql(c, env='dev'):
    """
    Docker-compose - PSQL
    """
    cmd = "{0} -f docker-compose.{1}.yml exec postgres psql -U postgres postgres".format(BASE_COMPOSE_CMD, env)
    c.run(cmd, pty=True)      
