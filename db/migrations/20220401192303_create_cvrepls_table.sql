-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE murepls(
  id serial PRIMARY KEY,
  --
  viuser_id int NOT NULL DEFAULT 0,
  thread_id int NOT NULL DEFAULT 0,
  thread_mu smallint NOT NULL DEFAULT 0::smallint,
  --
  touser_id int NOT NULL DEFAULT 0,
  torepl_id int NOT NULL DEFAULT 0,
  --
  level smallint NOT NULL DEFAULT 0,
  utime bigint NOT NULL DEFAULT 0, -- update time, change after edits
  --
  itext text NOT NULL DEFAULT '', -- text input
  ohtml text NOT NULL DEFAULT '', -- html output
  otext text NOT NULL DEFAULT '', -- text output
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

CREATE INDEX murepl_cvuser_idx ON murepls(viuser_id);

CREATE INDEX murepl_cvpost_idx ON murepls(cvpost_id, ii);

CREATE INDEX murepl_tagged_idx ON murepls USING GIN(tagged_ids);

CREATE INDEX murepl_repl_murepl_idx ON murepls(repl_murepl_id);

CREATE INDEX murepl_repl_cvuser_idx ON murepls(repl_viuser_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS murepls;
