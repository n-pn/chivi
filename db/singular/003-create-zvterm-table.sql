DROP TABLE IF EXISTS zvterm;

CREATE TABLE IF NOT EXISTS zvterm(
  d_id int NOT NULL DEFAULT 0,
  ipos smallint NOT NULL DEFAULT 0,
  zstr text NOT NULL,
  --
  cpos text NOT NULL DEFAULT 'X',
  vstr text NOT NULL DEFAULT '',
  attr text NOT NULL DEFAULT '',
  --
  toks int[] NOT NULL DEFAULT '{}',
  ners text[] NOT NULL DEFAULT '{}',
  segr smallint NOT NULL DEFAULT 2,
  posr smallint NOT NULL DEFAULT 2,
  --
  uname text NOT NULL DEFAULT '',
  mtime int NOT NULL DEFAULT 0,
  plock smallint NOT NULL DEFAULT 1,
  --
  PRIMARY KEY (d_id, ipos, zstr)
);

CREATE INDEX IF NOT EXISTS zvterm_zstr_idx ON zvterm(zstr);

CREATE INDEX IF NOT EXISTS zvterm_time_idx ON zvterm(mtime);
