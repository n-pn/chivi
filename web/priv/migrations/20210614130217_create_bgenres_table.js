exports.up = async (knex) => {
  return await knex.schema.createTable('bgenres', (t) => {
    t.increments()

    t.string('vi_name').notNullable()
    t.string('slugify').notNullable().unique()
    t.specificType('zh_names', 'varchar[]').defaultTo('{}')

    t.timestamps(true, true)
  })
}

exports.down = async (knex) => {
  return await knex.schema.dropTable('bgenres')
}
