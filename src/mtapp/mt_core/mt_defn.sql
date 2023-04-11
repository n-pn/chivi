pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS defns(
  "d_id" int NOT NULL,
  "zstr" varchar NOT NULL,
  --
  "vstr" varchar NOT NULL DEFAULT '',
  "_ver" smallint NOT NULL DEFAULT 0,
  -- postag and entity
  "upos" varchar NOT NULL DEFAULT '',
  "xpos" varchar NOT NULL DEFAULT '',
  "feat" varchar NOT NULL DEFAULT '',
  -- version and format
  "_fmt" smallint NOT NULL DEFAULT 0,
  "_wsr" smallint NOT NULL DEFAULT 2,
  -- user data
  "mtime" int NOT NULL DEFAULT 0,
  "uname" varchar NOT NULL DEFAULT '',
  "_flag" smallint NOT NULL DEFAULT 0,
  --
  PRIMARY KEY ("zstr", "d_id")
);

CREATE INDEX IF NOT EXISTS dict_idx ON defns("d_id", "_ver");
