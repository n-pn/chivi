-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE virepls(
  id serial PRIMARY KEY,
  --
  viuser_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  vicrit_id int NOT NULL REFERENCES vicrits(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  itext text NOT NULL DEFAULT '', -- text input
  ohtml text NOT NULL DEFAULT '', -- html output
  --
  _flag int NOT NULL DEFAULT 0, -- states: public, deleted...
  _sort int NOT NULL DEFAULT 0,
  --
  like_count int NOT NULL DEFAULT 0, -- like count
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  changed_at timestamptz
);

CREATE INDEX virepl_cvuser_idx ON virepls(viuser_id);

CREATE INDEX virepl_vicrit_idx ON virepls(vicrit_id, _sort);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS virepls;
