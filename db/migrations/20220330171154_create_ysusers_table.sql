-- +micrate Up
CREATE TABLE ysusers (
  id serial primary key,
  y_uid int4 not null,

  zname text not null,
  vname text not null,

  vslug text not null default '',

  like_count int4 not null default 0,
  star_count int4 not null default 0,

  crit_count int4 not null default 0,
  crit_total int4 not null default 0,

  list_count int4 not null default 0,
  list_total int4 not null default 0,

  repl_count int4 not null default 0,
  repl_total int4 not null default 0,

  info_rtime int8 not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ysuser_y_uid_idx ON ysusers (y_uid);
CREATE INDEX ysuser_uname_idx ON ysusers (zname);

-- +micrate Down
DROP TABLE IF EXISTS ysusers;
