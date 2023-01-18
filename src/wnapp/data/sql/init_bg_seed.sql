pragma journal_mode = WAL;

pragma synchronous = normal;

CREATE TABLE IF NOT EXISTS "seeds" (
  sname varchar NOT NULL,
  s_bid integer NOT NULL,
  --
  wn_id integer NOT NULL DEFAULT 0,
  --
  chap_total integer NOT NULL DEFAULT 0,
  chap_avail integer NOT NULL DEFAULT 0,
  last_s_cid integer NOT NULL DEFAULT 0,
  --
  _flag integer NOT NULL DEFAULT 0,
  _prio integer NOT NULL DEFAULT 0,
  --
  mtime bigint NOT NULL DEFAULT 0,
  stime bigint NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (sname, s_bid)
);

CREATE INDEX IF NOT EXISTS book_idx ON seeds (wn_id, _prio);
