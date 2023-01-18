pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS terms (
  "id" integer PRIMARY KEY,
  "dic" int NOT NULL DEFAULT 0,
  --
  "key" varchar NOT NULL, -- input text normalized
  "val" varchar NOT NULL, -- main meaning
  --
  "etag" integer NOT NULL DEFAULT 0,
  "epos" integer NOT NULL DEFAULT 0,
  --
  "cost" integer NOT NULL DEFAULT 0,
  --
  "_lock" integer NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS terms_uniq_idx ON terms (dic, etag, key);