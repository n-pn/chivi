-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS unotifs(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  viuser_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  content text NOT NULL DEFAULT '',
  details text NOT NULL DEFAULT '',
  link_to text NOT NULL DEFAULT '',
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reached_at timestamptz
);

CREATE INDEX IF NOT EXISTS unotifs_viuser_idx ON unotifs(viuser_id, reached_at);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS unotifs;
