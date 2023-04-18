-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS unotifs(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  target_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  "action" smallint NOT NULL DEFAULT 0,
  object_id int NOT NULL DEFAULT 0,
  byuser_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  content text NOT NULL DEFAULT '',
  details text NOT NULL DEFAULT '',
  link_to text NOT NULL DEFAULT '',
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reached_at timestamptz
);

CREATE INDEX IF NOT EXISTS unotifs_target_idx ON unotifs(target_id, reached_at);

CREATE INDEX IF NOT EXISTS unotifs_object_idx ON unotifs("action", object_id, byuser_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS unotifs;
