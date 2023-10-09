-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS qtran_xlogs(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  viuser_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  input_hash int NOT NULL DEFAULT 0,
  char_count int NOT NULL DEFAULT 0,
  point_cost int NOT NULL DEFAULT 0,
  --
  wn_dic int NOT NULL DEFAULT 0,
  --
  mt_ver smallint NOT NULL DEFAULT 1,
  cv_ner boolean NOT NULL DEFAULT 'f',
  ts_sdk boolean NOT NULL DEFAULT 'f',
  ts_acc boolean NOT NULL DEFAULT 'f',
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS qtran_xlogs_viuser_idx ON qtran_xlogs(viuser_id, input_hash);

CREATE INDEX IF NOT EXISTS qtran_xlogs_wninfo_idx ON qtran_xlogs(wn_dic);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS qtran_xlogs;
