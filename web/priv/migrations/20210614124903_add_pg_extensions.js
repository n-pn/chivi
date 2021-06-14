exports.up = async (knex) => {
  await knex.raw('CREATE EXTENSION IF NOT EXISTS "citext";')
  await knex.raw('CREATE EXTENSION IF NOT EXISTS "pg_trgm";')
  await knex.raw('CREATE EXTENSION IF NOT EXISTS "intarray";')
}

exports.down = async (knex) => {
  await knex.raw('DROP EXTENSION IF EXISTS "citext";')
  await knex.raw('DROP EXTENSION IF EXISTS "pg_trgm";')
  await knex.raw('DROP EXTENSION IF EXISTS "intarray";')
}
