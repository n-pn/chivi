pragma journal_mode = WAL;

pragma synchronous = normal;

CREATE TABLE IF NOT EXISTS seeds (
  s_bid integer NOT NULL,
  sname varchar NOT NULL,
  --
  stype integer NOT NULL DEFAULT 0,
  _flag integer NOT NULL DEFAULT 0,
  --
  chap_total integer DEFAULT 0,
  chap_avail integer DEFAULT 0,
  --
  feed_sname varchar DEFAULT 0,
  feed_s_bid integer DEFAULT 0,
  feed_s_cid integer DEFAULT 0,
  feed_stime bigint DEFAULT 0,
  --
  atime bigint DEFAULT 0,
  mtime bigint DEFAULT 0,
  --
  PRIMARY KEY (s_bid, sname)
);
