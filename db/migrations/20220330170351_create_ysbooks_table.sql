-- +micrate Up
CREATE TABLE ysbooks(
  id int NOT NULL PRIMARY KEY,
  nvinfo_id int NOT NULL DEFAULT 0 REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  btitle text NOT NULL DEFAULT '',
  author text NOT NULL DEFAULT '',
  --
  voters int NOT NULL DEFAULT 0,
  rating int NOT NULL DEFAULT 0,
  -- book info
  cover text NOT NULL DEFAULT '',
  intro text compression lz4 NOT NULL DEFAULT '',
  genre text NOT NULL DEFAULT '',
  btags text[] NOT NULL DEFAULT '{}' ::text[],
  --
  shield int NOT NULL DEFAULT 0,
  status int NOT NULL DEFAULT 0,
  sources text[] NOT NULL DEFAULT '{}' ::text[],
  --
  book_mtime int8 NOT NULL DEFAULT 0,
  info_rtime int8 NOT NULL DEFAULT 0,
  --
  word_count int NOT NULL DEFAULT 0,
  --
  crit_count int NOT NULL DEFAULT 0,
  list_count int NOT NULL DEFAULT 0,
  --
  crit_total int NOT NULL DEFAULT 0,
  list_total int NOT NULL DEFAULT 0,
  -- timestamps
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ysbooks_wninfos_idx ON ysbooks(nvinfo_id);

-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
