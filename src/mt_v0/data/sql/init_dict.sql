CREATE TABLE IF NOT EXISTS terms (
  "id" integer NOT NULL PRIMARY KEY, -- id < 0 mean deleted
  --
  "zstr" varchar NOT NULL, -- normalized chinese input
  "tags" varchar NOT NULL, -- ctb tag sort by popularity
  "mtls" varchar NOT NULL, -- translation correspoding to tags
  -- v1data
  "ptag" varchar NOT NULL DEFAULT '',
  "prio" integer NOT NULL DEFAULT 1,
  --
  "raw_tags" varchar NOT NULL DEFAULT '{}', -- tags combine from all sources
  "raw_mtls" varchar NOT NULL DEFAULT '{}', -- mtls combine from all sources
  --
  "mtime" bigint NOT NULL DEFAULT 0, -- last modification time
  "uname" varchar NOT NULL DEFAULT '', -- last modified by
  --
  "_flag" integer NOT NULL DEFAULT 0 -- convenience field for maintainment
);

CREATE INDEX IF NOT EXISTS zstr_idx ON terms ('zstr');

CREATE INDEX IF NOT EXISTS tags_idx ON terms ('tags');

CREATE INDEX IF NOT EXISTS user_idx ON terms (uname);

-- enable wal mode on default
pragma journal_mode = WAL;
