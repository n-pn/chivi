-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE cvrepls(
  id serial PRIMARY KEY,
  --
  viuser_id int NOT NULL DEFAULT 0,
  cvpost_id int NOT NULL DEFAULT 0,
  --
  tagged_ids int[] NOT NULL DEFAULT '{}', -- tagged cvuser ids
  --
  repl_cvrepl_id int NOT NULL DEFAULT 0,
  repl_cvuser_id int NOT NULL DEFAULT 0,
  --
  input text NOT NULL DEFAULT '', -- text input
  ohtml text NOT NULL DEFAULT '', -- html output
  otext text NOT NULL DEFAULT '', -- text output
  --
  state int NOT NULL DEFAULT 0, -- states: public, deleted...
  utime bigint NOT NULL DEFAULT 0, -- update time, change after edits
  --
  edit_count int NOT NULL DEFAULT 0, -- edit count
  like_count int NOT NULL DEFAULT 0, -- like count
  repl_count int NOT NULL DEFAULT 0, -- like count
  --
  coins int NOT NULL DEFAULT 0, -- karma given by users to this post
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX cvrepl_cvuser_idx ON cvrepls(viuser_id);

CREATE INDEX cvrepl_cvpost_idx ON cvrepls(cvpost_id, ii);

CREATE INDEX cvrepl_tagged_idx ON cvrepls USING GIN(tagged_ids);

CREATE INDEX cvrepl_repl_cvrepl_idx ON cvrepls(repl_cvrepl_id);

CREATE INDEX cvrepl_repl_cvuser_idx ON cvrepls(repl_viuser_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS cvrepls;
