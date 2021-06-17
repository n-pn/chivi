// Update with your config settings.

function makeConfig(env = 'dev') {
  return {
    client: 'postgresql',
    connection: {
      database: 'chivi_' + env,
      user: 'postgres',
      password: 'postgres',
    },
    pool: {
      min: 2,
      max: 10,
    },
  }
}

module.exports = {
  development: makeConfig('dev'),
  staging: makeConfig('stag'),
  production: makeConfig('prod'),
}
