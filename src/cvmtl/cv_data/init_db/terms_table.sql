CREATE TABLE IF NOT EXISTS terms (
  "id" integer PRIMARY KEY,
  "dic" int NOT NULL DEFAULT 0,
  "key" varchar NOT NULL, -- input text normalized
  "raw" varchar, -- raw input text
  "val" varchar NOT NULL, -- main meaning
  "alt" varchar, -- alternative meaning
  "ptag" varchar, -- generic postag label
  "wseg" int NOT NULL DEFAULT 2, -- priority rank for word segmentation
  "user" varchar NOT NULL DEFAULT '', -- user name
  "time" int NOT NULL DEFAULT 0, -- term update time
  "flag" int NOT NULL DEFAULT 0 -- marking term as active or inactive
);

CREATE INDEX IF NOT EXISTS terms_scan_idx ON terms (dic, flag);

CREATE INDEX IF NOT EXISTS terms_time_idx ON terms (time, dic);

CREATE INDEX IF NOT EXISTS terms_user_idx ON terms (user);

CREATE INDEX IF NOT EXISTS terms_key_idx ON terms (key, dic);

CREATE INDEX IF NOT EXISTS terms_val_idx ON terms (val);

CREATE INDEX IF NOT EXISTS terms_alt_idx ON terms (alt);

CREATE INDEX IF NOT EXISTS terms_tag_idx ON terms (ptag, dic);

CREATE INDEX IF NOT EXISTS terms_seg_idx ON terms (wseg);
