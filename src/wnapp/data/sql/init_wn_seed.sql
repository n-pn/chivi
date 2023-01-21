CREATE TABLE IF NOT EXISTS "seeds" (
  sname varchar NOT NULL,
  s_bid integer NOT NULL,
  --
  wn_id integer NOT NULL DEFAULT 0,
  sn_id integer NOT NULL DEFAULT 0,
  --
  chap_total integer NOT NULL DEFAULT 0,
  chap_avail integer NOT NULL DEFAULT 0,
  --
  _flag integer NOT NULL DEFAULT 0,
  _rank integer NOT NULL DEFAULT 0,
  --
  atime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0,
  rtime bigint NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (sname, s_bid)
);

CREATE INDEX IF NOT EXISTS book_idx ON seeds (wn_id, _rank);

pragma journal_mode = WAL;
