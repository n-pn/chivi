-- DROP TABLE IF EXISTS wnchap;
CREATE TABLE IF NOT EXISTS wnchap(
  sname varchar NOT NULL,
  sn_id integer NOT NULL,
  c_idx integer NOT NULL,
  --
  ztitle varchar NOT NULL DEFAULT '',
  zchdiv varchar NOT NULL DEFAULT '',
  vtitle varchar NOT NULL DEFAULT '',
  vchdiv varchar NOT NULL DEFAULT '',
  --
  mtime integer NOT NULL DEFAULT 0,
  cksum bytea NOT NULL DEFAULT ''::bytea,
  extra text NOT NULL DEFAULT '',
  --
  PRIMARY KEY (sname, sn_id, c_idx)
);
