pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS ptags (
  id integer PRIMARY KEY,
  -- unique
  name varchar NOT NULL DEFAULT '',
  kind integer NOT NULL DEFAULT 0,
  -- descs
  desc text NOT NULL DEFAULT '',
  note text NOT NULL DEFAULT '',
  -- filters
  lbls varchar NOT NULL DEFAULT '', -- filter by labels
  alts varchar NOT NULL DEFAULT '', -- alternative tag names
  -- counters
  rules_inp integer NOT NULL DEFAULT 0, -- rules take this ptag as input
  rules_out integer NOT NULL DEFAULT 0, -- rules take this ptag as output
  --
  uname varchar NOT NULL DEFAULT '', -- created by
  mtime bigint NOT NULL DEFAULT 0, -- created/updated at
  --
  _flag integer NOT NULL DEFAULT 0, -- mark active/inactive
);

CREATE UNIQUE INDEX IF NOT EXISTS ptags_name_idx ON ptags (name);

CREATE INDEX IF NOT EXISTS ptags_user_idx ON ptags (uname);
