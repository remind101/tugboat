var spawn  = require('child_process').spawn,
    extend = require('./lib/extend'),
    env    = require('./lib/env').parse(process.argv),
    proc   = spawn('deploy', null, {stdio: 'inherit', env: extend(env, process.env)})
