-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE murepls(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  viuser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  muhead_id int NOT NULL DEFAULT REFERENCES muheads(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  touser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  torepl_id int REFERENCES murepls(id) ON UPDATE CASCADE ON DELETE SET NULL,
  --
  level smallint NOT NULL DEFAULT 0,
  utime bigint NOT NULL DEFAULT 0, -- update time, change after edits
  --
  itext text NOT NULL DEFAULT '', -- text input
  ohtml text NOT NULL DEFAULT '', -- html output
  --
  like_count int NOT NULL DEFAULT 0, -- like count
  repl_count int NOT NULL DEFAULT 0, -- like count
  --
  gift_vcoin int NOT NULL DEFAULT 0, -- karma given by users to this post
  tagged_ids int[] NOT NULL DEFAULT '{}', -- tagged cvuser ids
  --
  deleted_at timestamptz,
  deleted_by int REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE SET NULL,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX murepls_viuser_idx ON murepls(viuser_id);

CREATE INDEX murepls_tagged_idx ON murepls USING GIN(tagged_ids);

CREATE INDEX murepls_touser_idx ON murepls(touser_id);

CREATE INDEX murepls_torepl_idx ON murepls(torepl_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS murepls;
