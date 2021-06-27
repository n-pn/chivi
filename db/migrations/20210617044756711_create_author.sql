-- +micrate Up
CREATE TABLE authors (
  id bigserial PRIMARY KEY,

  zname varchar not null UNIQUE,
  vname varchar not null,

  zname_ts varchar default '' not null,
  vname_ts varchar default '' not null,

  weight int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX author_zname_idx ON authors using GIN (zname_ts gin_trgm_ops);
CREATE INDEX author_vname_idx ON authors using GIN (vname_ts gin_trgm_ops);
CREATE INDEX author_weight_idx ON authors (weight);


-- +micrate Down
DROP TABLE IF EXISTS authors;
