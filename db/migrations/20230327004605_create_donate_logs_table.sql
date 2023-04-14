-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS donate_logs(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  donor_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  amount float8 NOT NULL DEFAULT 0,
  source text NOT NULL DEFAULT '',
  --
  proof text NOT NULL DEFAULT '',
  extra text NOT NULL DEFAULT '',
  --
  state smallint NOT NULL DEFAULT 0,
  --
  verified_at timestamptz,
  verified_by int REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS donate_log_donor_idx ON donate_logs(donor_id, state);

CREATE INDEX IF NOT EXISTS donate_log_source_idx ON donate_logs(source, amount);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS donate_logs;
