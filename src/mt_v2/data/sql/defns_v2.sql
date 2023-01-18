pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS defns (
  "id" integer PRIMARY KEY,
  --
  "dic" integer NOT NULL DEFAULT 0,
  "tab" integer NOT NULL DEFAULT 0,
  --
  "key" varchar NOT NULL, -- raw input
  "val" varchar NOT NULL, -- raw value
  --
  "ptag" integer NOT NULL DEFAULT '', -- generic postag label
  "rank" integer NOT NULL DEFAULT 3, -- priority rank for word segmentation
  --
  "uname" varchar NOT NULL DEFAULT '', -- user name
  "mtime" integer NOT NULL DEFAULT 0, -- term update time
  --
  '_ctx' varchar NOT NULL DEFAULT 0,
  --
  "_prev" integer NOT NULL DEFAULT 0,
  "_flag" integer NOT NULL DEFAULT 0 -- marking term as active or inactive
);

CREATE INDEX IF NOT EXISTS defns_scan_idx ON defns (dic, tab);

CREATE INDEX IF NOT EXISTS defns_word_idx ON defns (key);

CREATE INDEX IF NOT EXISTS defns_ptag_idx ON defns (ptag);

CREATE INDEX IF NOT EXISTS defns_user_idx ON defns (uname);
