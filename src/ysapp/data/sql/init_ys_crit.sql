-- sqlite3
-- yousuu crits info table
CREATE TABLE crits (
  id integer PRIMARY KEY,
  uuid blob NOT NULL UNIQUE,
  --
  wn_id integer NOT NULL DEFAULT 0,
  bl_id integer NOT NULL DEFAULT 0,
  --
  book_id integer NOT NULL DEFAULT 0,
  user_id integer NOT NULL DEFAULT 0,
  list_id blob,
  --
  stars integer not null default 0
  bsize integer not null default 0
  --
  ztags varchar not null default '[]',
  vtags varchar not null default '[]',
  --
  like_count int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  repl_total int NOT NULL DEFAULT 0,
  --

  mtime bigint NOT NULL DEFAULT 0,
  rtime bigint NOT NULL DEFAULT 0,
  _sort integer not null default 0
);

-- for searching
CREATE INDEX cv_wn_idx ON crits (wn_id, _sort);
CREATE INDEX cv_bl_idx ON crits (bl_id);

CREATE INDEX book_idx ON crits (book_id);
CREATE INDEX user_idx ON crits (user_id, mtime);
CREATE INDEX list_idx ON crits (list_id);

-- CREATE INDEX vtags_idx ON crits (vtags);
CREATE INDEX mtime_idx ON crits (mtime, stars);
CREATE INDEX _sort_idx ON crits (_sort, stars);
CREATE INDEX likes_idx ON crits (like_count, stars);

-- extra
pragma journal_mode = WAL;
