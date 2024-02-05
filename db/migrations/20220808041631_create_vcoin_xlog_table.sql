-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS vcoin_xlogs(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  kind smallint NOT NULL DEFAULT 0,
  --
  sender_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_name text NOT NULL DEFAULT '',
  --
  amount int NOT NULL DEFAULT 0,
  reason text NOT NULL DEFAULT '',
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS vcoin_xlogs_sender_idx ON vcoin_xlogs(sender_id);

CREATE INDEX IF NOT EXISTS vcoin_xlogs_target_idx ON vcoin_xlogs(target_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS vcoin_xlogs;
