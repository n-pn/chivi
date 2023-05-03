-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE gdroots(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  kind smallint NOT NULL DEFAULT 0,
  ukey citext NOT NULL DEFAULT 0,
  --
  viuser_id int NOT NULL DEFAULT 0 REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  repl_count int NOT NULL DEFAULT 0,
  view_count int NOT NULL DEFAULT 0,
  like_count int NOT NULL DEFAULT 0,
  --
  last_seen_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_repl_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  deleted_at timestamptz,
  deleted_by int REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE UNIQUE INDEX gdroots_unique_idx ON gdroots(kind, ukey);

CREATE INDEX gdroots_viuser_idx ON gdroots(viuser_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS gdroots;
