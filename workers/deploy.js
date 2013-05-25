var spawn   = require('child_process').spawn,
    extend  = require('./lib/extend'),
    payload = require('./lib/payload'),
    env     = extend(payload.env, process.env),
    proc    = spawn('deploy', null, {stdio: 'inherit', env: env})
