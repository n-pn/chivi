-- +micrate Up
CREATE TABLE ysusers (
  id bigserial PRIMARY KEY,

  zname varchar not null UNIQUE,
  vname varchar not null,

  like_count int default 0 not null,
  list_count int default 0 not null,
  crit_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);


-- +micrate Down
DROP TABLE IF EXISTS ysusers;
