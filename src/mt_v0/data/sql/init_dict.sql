CREATE TABLE IF NOT EXISTS terms (
  "id" integer PRIMARY KEY,
  --
  "zstr" varchar NOT NULL,
  "tran" varchar NOT NULL,
  --
  "ctag" varchar NOT NULL DEFAULT '', -- ctb postag
  "_ord" integer NOT NULL DEFAULT 0, -- rank by popularity, lower means more popular
  --
  "tran_by" varchar NOT NULL DEFAULT '', -- origin of translation
  "ctag_by" varchar NOT NULL DEFAULT '', -- origin of postag
  --
  "_flag" integer NOT NULL DEFAULT 0 --
);

CREATE INDEX IF NOT EXISTS zstr_idx ON terms ('zstr');

CREATE INDEX IF NOT EXISTS ctag_idx ON terms (ctag);

pragma journal_mode = WAL;
