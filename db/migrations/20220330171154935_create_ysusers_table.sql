-- +micrate Up
CREATE TABLE ysusers (
  id serial primary key,
  y_uid int4 not null,

  zname text not null,
  vname text not null,
  vslug text not null default '',

  stime int8 not null default 0,

  like_count int4 not null default 0,
  star_count int4 not null default 0,

  crit_count int4 not null default 0,
  crit_total int4 not null default 0,

  list_count int4 not null default 0,
  list_total int4 not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ysuser_uniq_idx ON ysusers (zname);
CREATE UNIQUE INDEX ysuser_user_idx ON ysusers (y_uid);


-- +micrate Down
DROP TABLE IF EXISTS ysusers;
