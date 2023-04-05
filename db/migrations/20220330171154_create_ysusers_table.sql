-- +micrate Up
CREATE TABLE ysusers(
  id serial PRIMARY KEY,
  yu_id int NOT NULL UNIQUE,
  --
  zname text NOT NULL,
  vname text NOT NULL,
  vslug text NOT NULL DEFAULT '',
  --
  like_count int NOT NULL DEFAULT 0,
  star_count int NOT NULL DEFAULT 0,
  --
  crit_count int NOT NULL DEFAULT 0,
  crit_total int NOT NULL DEFAULT 0,
  --
  list_count int NOT NULL DEFAULT 0,
  list_total int NOT NULL DEFAULT 0,
  --
  repl_count int NOT NULL DEFAULT 0,
  repl_total int NOT NULL DEFAULT 0,
  --
  info_rtime bigint NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ysuser_uname_idx ON ysusers(zname);

-- +micrate Down
DROP TABLE IF EXISTS ysusers;
