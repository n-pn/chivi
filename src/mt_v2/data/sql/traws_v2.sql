pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS traws (
  "id" integer PRIMARY KEY,
  --
  "d_id" integer NOT NULL DEFAULT 0,
  "dname" varchar NOT NULL DEFAULT '',
  --
  "key" varchar NOT NULL, -- raw input
  "val" varchar NOT NULL, -- raw value
  --
  "ptag" varchar NOT NULL DEFAULT '', -- generic postag label
  "rank" integer NOT NULL DEFAULT 3, -- priority rank for word segmentation
  --
  "uname" varchar NOT NULL DEFAULT '', -- user name
  "mtime" integer NOT NULL DEFAULT 0, -- term update time
  --
  "_flag" integer NOT NULL DEFAULT 0 -- marking term as active or inactive
);

CREATE INDEX IF NOT EXISTS terms_word_idx ON traws ('key');

CREATE INDEX IF NOT EXISTS traws_scan_idx ON traws (d_id);

CREATE INDEX IF NOT EXISTS traws_ptag_idx ON traws (ptag);

CREATE INDEX IF NOT EXISTS traws_user_idx ON traws (uname);
