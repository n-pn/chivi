pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS rules (
  id integer PRIMARY KEY,
  -- input
  rule varchar NOT NULL DEFAULT '', -- array of postag id seperated by ' + '
  size integer NOT NULL DEFAULT 0, -- number of items in rule input
  prio integer NOT NULL DEFAULT 5, -- rule base priority cost
  -- descs
  desc text NOT NULL DEFAULT '',
  note text NOT NULL DEFAULT '',
  -- output
  kind integer NOT NULL DEFAULT 0, -- output kind
  ptag integer NOT NULL DEFAULT 0, -- output ptag
  combine varchar NOT NULL DEFAULT '', -- output type is combine nodes
  replace varchar NOT NULL DEFAULT '', -- output type is replace nodes
  -- extras
  --
  uname varchar NOT NULL DEFAULT '', -- created by
  mtime bigint NOT NULL DEFAULT 0, -- created/updated at
  --
  _flag integer NOT NULL DEFAULT 0, -- mark active/inactive
);

CREATE UNIQUE INDEX IF NOT EXISTS rules_rule_idx ON rules (rule);

CREATE INDEX IF NOT EXISTS rules_ptag_idx ON rules (ptag);

CREATE INDEX IF NOT EXISTS rules_user_idx ON rules (uname);
