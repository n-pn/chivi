-- +micrate Up
CREATE TABLE ysbooks (
  id serial PRIMARY KEY,
  nvinfo_id int4 NOT NULL DEFAULT 0 REFERENCES nvinfos (id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  btitle text NOT NULL DEFAULT '',
  author text NOT NULL DEFAULT '',
  --
  voters int4 NOT NULL DEFAULT 0,
  rating int4 NOT NULL DEFAULT 0,
  -- book info
  cover text NOT NULL DEFAULT '',
  intro text NOT NULL DEFAULT '',
  genre text NOT NULL DEFAULT '',
  btags text[] NOT NULL DEFAULT '{}',
  --
  shield int4 NOT NULL DEFAULT 0,
  status int4 NOT NULL DEFAULT 0,
  sources text[] NOT NULL DEFAULT '{}',
  --
  book_mtime int8 NOT NULL DEFAULT 0,
  info_rtime int8 NOT NULL DEFAULT 0,
  --
  word_count int4 NOT NULL DEFAULT 0,
  --
  crit_count int4 NOT NULL DEFAULT 0,
  list_count int4 NOT NULL DEFAULT 0,
  --
  crit_total int4 NOT NULL DEFAULT 0,
  list_total int4 NOT NULL DEFAULT 0,
  -- timestamps
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ysbook_wn_id_idx ON ysbooks (nvinfo_id);

-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
