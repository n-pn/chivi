-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE rpnodes(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  viuser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  rproot_id int NOT NULL DEFAULT REFERENCES rproots(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  touser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  torepl_id int REFERENCES rpnodes(id) ON UPDATE CASCADE ON DELETE SET NULL,
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

CREATE INDEX rpnodes_viuser_idx ON rpnodes(viuser_id);

CREATE INDEX rpnodes_tagged_idx ON rpnodes USING GIN(tagged_ids);

CREATE INDEX rpnodes_touser_idx ON rpnodes(touser_id);

CREATE INDEX rpnodes_torepl_idx ON rpnodes(torepl_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS rpnodes;