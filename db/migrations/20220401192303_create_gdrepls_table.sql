-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE gdrepls(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  viuser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  gdroot_id int NOT NULL DEFAULT REFERENCES gdroots(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  touser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  torepl_id int REFERENCES gdrepls(id) ON UPDATE CASCADE ON DELETE SET NULL,
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

CREATE INDEX gdrepls_viuser_idx ON gdrepls(viuser_id);

CREATE INDEX gdrepls_tagged_idx ON gdrepls USING GIN(tagged_ids);

CREATE INDEX gdrepls_touser_idx ON gdrepls(touser_id);

CREATE INDEX gdrepls_torepl_idx ON gdrepls(torepl_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS gdrepls;
