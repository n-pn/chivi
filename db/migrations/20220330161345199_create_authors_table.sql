-- +micrate Up
CREATE TABLE authors (
  id serial primary key,

  zname varchar not null unique,

  vname varchar not null default '',
  vslug varchar not null default '',

  vdesc text not null default '',
  book_count int not null default 0,

  _sort int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX author_zname_idx ON authors using GIN (zname gin_trgm_ops);
CREATE INDEX author_vslug_idx ON authors using GIN (vslug gin_trgm_ops);
CREATE INDEX author_order_idx ON authors (_sort);


-- +micrate Down
DROP TABLE IF EXISTS authors;
