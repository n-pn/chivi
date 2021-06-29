-- +micrate Up
CREATE TABLE authors (
  id bigserial primary key,

  zname text unique not null,
  vname text not null,

  zname_ts text not null default '' ,
  vname_ts text not null default '' ,

  weight int not null default 0 ,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX author_zname_idx ON authors using GIN (zname_ts gin_trgm_ops);
CREATE INDEX author_vname_idx ON authors using GIN (vname_ts gin_trgm_ops);
CREATE INDEX author_weight_idx ON authors (weight);


-- +micrate Down
DROP TABLE IF EXISTS authors;
