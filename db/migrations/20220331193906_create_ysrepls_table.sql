-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE ysrepls(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  yr_id bytea NOT NULL UNIQUE,
  --
  ysuser_id int NOT NULL DEFAULT 0,
  yscrit_id int NOT NULL DEFAULT 0,
  --
  ztext text compression lz4 NOT NULL DEFAULT '',
  vhtml text compression lz4 NOT NULL DEFAULT '',
  --
  info_rtime bigint NOT NULL DEFAULT 0,
  --
  like_count int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ysrepls_uniq_idx ON ysrepls(yr_id);

CREATE INDEX ysrepls_ysuser_idx ON ysrepls(ysuser_id);

CREATE INDEX ysrepls_yscrit_idx ON ysrepls(yscrit_id, created_at);

-- +micrate Down
DROP TABLE IF EXISTS ysrepls;
