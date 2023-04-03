-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE ysrepls (
  id bigserial PRIMARY KEY,
  y_rid text NOT NULL,
  --
  ysuser_id bigint NOT NULL DEFAULT 0,
  yscrit_id bigint NOT NULL DEFAULT 0,
  --
  ztext text compression lz4 NOT NULL DEFAULT '',
  vhtml text compression lz4 NOT NULL DEFAULT '',
  --
  stime bigint NOT NULL DEFAULT 0,
  --
  like_count int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ysrepl_y_ridx ON ysrepls (y_rid);

CREATE INDEX ysrepl_ysuser_idx ON ysrepls (ysuser_id);

CREATE INDEX ysrepl_yscrit_idx ON ysrepls (yscrit_id, created_at);

-- +micrate Down
DROP TABLE IF EXISTS ysrepls;
