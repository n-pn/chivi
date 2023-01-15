pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS terms (
  "id" integer PRIMARY KEY,
  "dic" int NOT NULL DEFAULT 0,
  --
  "key" varchar NOT NULL, -- input text normalized
  "val" varchar NOT NULL, -- main meaning
  --
  "ptag" integer NOT NULL DEFAULT 0,
  "attr" integer NOT NULL DEFAULT 0,
  "wght" integer NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS terms_uniq_idx ON terms (dic, ptag, key);
