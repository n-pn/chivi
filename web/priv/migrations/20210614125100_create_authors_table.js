exports.up = async (knex) => {
  await knex.schema.createTable('authors', (t) => {
    t.increments()

    t.string('zh_name').notNullable().unique()
    t.string('vi_name').notNullable()
    t.string('vi_slug').notNullable() // generated in app code
    t.integer('max_pts').notNullable().defaultTo(0)

    t.timestamps(true, true)
  })

  await knex.schema.raw(
    'CREATE INDEX ?? ON "authors" USING GIN(?? gin_trgm_ops);',
    ['authors_vi_slug_index', 'vi_slug']
  )
}

exports.down = async (knex) => {
  await knex.schema.dropTableIfExists('authors')
}
