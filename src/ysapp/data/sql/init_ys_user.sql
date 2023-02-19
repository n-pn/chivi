-- sqlite3
-- yousuu users info table
CREATE TABLE users (
  id integer PRIMARY KEY,
  --
  zname varchar NOT NULL,
  avatar varchar NOT NULL DEFAULT '',
  --
  vname varchar NOT NULL DEFAULT '',
  uslug varchar NOT NULL DEFAULT '',
  --
  like_count int NOT NULL DEFAULT 0,
  star_count int NOT NULL DEFAULT 0,
  --
  -- total means real value in yousuu
  -- count means all item existed in chivi
  -- for booklists
  list_total int NOT NULL DEFAULT 0,
  list_count int NOT NULL DEFAULT 0,
  -- for reviews
  crit_total int NOT NULL DEFAULT 0,
  crit_count int NOT NULL DEFAULT 0,
  -- for comments
  repl_total int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  --
  -- last `crawled initialized at` timestamps
  list_rtime int NOT NULL DEFAULT 0,
  crit_rtime int NOT NULL DEFAULT 0,
  repl_rtime int NOT NULL DEFAULT 0,
  --
  rtime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0
);

-- for searching
CREATE INDEX zname_index ON users (zname);

CREATE INDEX liked_index ON users (like_count);

-- for crawling
CREATE INDEX list_rtime ON users (list_rtime);

CREATE INDEX crit_rtime ON users (crit_rtime);

CREATE INDEX repl_rtime ON users (repl_rtime);

-- extra
pragma journal_mode = WAL;
