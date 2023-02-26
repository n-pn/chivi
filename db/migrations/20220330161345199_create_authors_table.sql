-- +micrate Up
CREATE TABLE authors (
  id serial primary key,

  zname varchar not null unique,
  vname varchar not null default '',

  vdesc text not null default '',
  book_count int not null default 0,

  __fts varchar generated always as (scrub_name(vname)) stored,
  -- _sort int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX author_zname_idx ON authors using GIN (zname gin_trgm_ops);
-- CREATE INDEX author_vslug_idx ON authors using GIN (vslug gin_trgm_ops);
-- CREATE INDEX author_order_idx ON authors (_sort);

create index author_fuzzy_idx on authors using GIN (__fts gin_trgm_ops);

-- +micrate Down
DROP TABLE IF EXISTS authors;
