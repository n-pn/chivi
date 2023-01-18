CREATE TABLE IF NOT EXISTS chaps (
  ch_no integer PRIMARY KEY,
  s_cid integer NOT NULL,
  --
  title varchar NOT NULL DEFAULT '',
  chdiv varchar NOT NULL DEFAULT '',
  --
  c_len integer NOT NULL DEFAULT 0,
  p_len integer NOT NULL DEFAULT 0,
  --
  mtime integer NOT NULL DEFAULT 0,
  uname varchar NOT NULL DEFAULT '',
  --
  _path varchar NOT NULL DEFAULT '',
  _flag smallint NOT NULL DEFAULT 0
);

pragma journal_mode = WAL;
