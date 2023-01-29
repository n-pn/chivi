CREATE TABLE IF NOT EXISTS "seeds" (
  wn_id integer NOT NULL,
  sname varchar NOT NULL,
  s_bid integer NOT NULL,
  --
  chap_total integer NOT NULL DEFAULT 0,
  chap_avail integer NOT NULL DEFAULT 0,
  --
  atime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0,
  --
  rm_links varchar DEFAULT '[]',
  rm_stime bigint NOT NULL DEFAULT 0,
  --
  privi integer NOT NULL DEFAULT 3,
  _flag integer NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (wn_id, sname)
);

-- create indexes
CREATE INDEX IF NOT EXISTS seed_idx ON seeds (sname, s_bid);

-- enable wal mode for sqlite3
pragma journal_mode = WAL;
