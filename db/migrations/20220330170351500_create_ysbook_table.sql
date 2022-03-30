-- +micrate Up
CREATE TABLE ysbooks (
  id bigserial primary key,

  nvinfo_id bigint not null default 0,

  btitle text not null default '',
  author text not null default '',

  voters int not null default 0,
  scores int not null default 0,

  utime bigint not null default 0,

  root_link text not null default '',
  root_name text not null default '',

  crit_count int not null default 0,
  list_count int not null default 0,

  crit_total int not null default 0,
  list_total int not null default 0,

  info_stime bigint not null default 0, -- stime: crawled at
  crit_stime bigint not null default 0,
  list_stime bigint not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX ysbook_nvinfo_idx ON ysbooks (nvinfo_id);
CREATE INDEX ysbook_atime_idx ON ysbooks (atime);


-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
