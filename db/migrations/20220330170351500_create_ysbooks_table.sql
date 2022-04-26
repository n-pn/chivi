-- +micrate Up
CREATE TABLE ysbooks (
  id bigserial primary key,

  nvinfo_id bigint not null default 0,

  btitle text not null default '',
  author text not null default '',

  voters int not null default 0,
  scores int not null default 0,

  -- book info

  utime bigint not null default 0,
  stime bigint not null default 0, -- stime: crawled at

  status int not null default 0,
  word_count int not null default 0,

  --  origin

  pub_link text not null default '',
  pub_name text not null default '',

  -- counters

  crit_count int not null default 0,
  list_count int not null default 0,

  crit_total int not null default 0,
  list_total int not null default 0,

  -- timestamps

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX ysbook_nvinfo_idx ON ysbooks (nvinfo_id);
CREATE INDEX ysbook_source_idx ON ysbooks (pub_name);

-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
