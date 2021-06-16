exports.up = async (knex) => {
  return await knex.schema.createTable('nvseeds', (t) => {
    t.increments()
    t.integer('nvinfo_id').index()

    t.string('sname').notNullable()
    t.string('snvid').notNullable()

    t.integer('chap_count').notNullable().defaultTo(0)
    t.string('last_schid').notNullable().defaultTo('')

    t.timestamp('changed_at')
    t.timestamp('checked_at')

    t.integer('status').notNullable().defaultTo(0)
    t.integer('shield').notNullable().defaultTo(0)

    t.timestamps(true, true)

    t.index(['sname', 'snvid'])
  })
}

exports.down = async (knex) => {
  return await knex.schema.dropTable('nvseeds')
}
