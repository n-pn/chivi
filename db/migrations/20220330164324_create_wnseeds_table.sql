-- +micrate Up
CREATE TABLE wnseeds (
  wn_id int NOT NULL REFERENCES nvinfos (id) ON UPDATE CASCADE ON DELETE CASCADE,
  sname varchar NOT NULL DEFAULT '',
  s_bid int NOT NULL DEFAULT 0,
  --
  chap_total int NOT NULL DEFAULT 0,
  chap_avail int NOT NULL DEFAULT 0,
  --
  atime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0,
  --
  rm_links text[] NOT NULL DEFAULT '{}',
  rm_stime bigint NOT NULL DEFAULT 0,
  --
  privi int2 NOT NULL DEFAULT 3,
  _flag int2 NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (wn_id, sname)
);

CREATE INDEX wnseed_orig_idx ON wnseeds (sname, s_bid);

-- +micrate Down
DROP TABLE IF EXISTS wnseeds;
