pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS chaps(
  ch_no int PRIMARY KEY,
  s_cid varchar NOT NULL,
  cpath varchar NOT NULL DEFAULT '',
  ---
  ctitle varchar NOT NULL DEFAULT '',
  subdiv varchar NOT NULL DEFAULT '',
  ---
  chlen int NOT NULL DEFAULT 0,
  xxh32 int NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS rlogs(
  total_chap int NOT NULL DEFAULT 0,
  latest_cid varchar NOT NULL DEFAULT '',
  ---
  status_str varchar NOT NULL DEFAULT '',
  update_str varchar NOT NULL DEFAULT '',
  ---
  uname varchar NOT NULL DEFAULT '',
  rtime bigint NOT NULL DEFAULT 0
);
