exports.up = async (knex) => {
  await knex.schema.createTable('authors', (t) => {
    t.increments()

    t.string('zh_name').notNullable().unique()
    t.string('vi_name').notNullable()
    t.string('slugify').notNullable() // generated in app code
    t.integer('max_pts').notNullable().defaultTo(0)

    t.timestamps(true, true)
  })

  await knex.schema.raw(
    'CREATE INDEX ?? ON "authors" USING GIN("slugify" gin_trgm_opts);',
    ['authors_slugify_index']
  )
}

exports.down = async (knex) => {
  await knex.schema.dropTableIfExists('authors')
}
