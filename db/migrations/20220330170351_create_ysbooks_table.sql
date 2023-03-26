-- +micrate Up
CREATE TABLE ysbooks (
  id serial primary key,
  nvinfo_id int4 not null default 0,

  btitle text not null default '',
  author text not null default '',

  voters int4 not null default 0,
  rating int4 not null default 0,

  -- book info

  cover text not null default '',
  intro text not null default '',

  genre text not null default '',
  btags text[] not null default '{}',

  shield int4 not null default 0,
  status int4 not null default 0,

  book_mtime int8 not null default 0,
  info_rtime int8 not null default 0,

  word_count int4 not null default 0,

  crit_count int4 not null default 0,
  list_count int4 not null default 0,

  crit_total int4 not null default 0,
  list_total int4 not null default 0,

  sources text[] not null default '{}',

  -- timestamps

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX ysbook_nvinfo_idx ON ysbooks (nvinfo_id);

-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
