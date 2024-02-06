-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS xvcoins(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  kind smallint NOT NULL DEFAULT 0,
  --
  sender_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_name text NOT NULL DEFAULT '',
  --
  amount double precision NOT NULL DEFAULT 0,
  reason text NOT NULL DEFAULT '',
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS xvcoins_sender_idx ON xvcoins(sender_id);

CREATE INDEX IF NOT EXISTS xvcoins_target_idx ON xvcoins(target_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS xvcoins;
