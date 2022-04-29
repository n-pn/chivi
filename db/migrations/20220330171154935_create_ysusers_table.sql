-- +micrate Up
CREATE TABLE ysusers (
  id bigserial primary key,
  origin_id int not null,

  zname text not null,
  vname text not null,
  vslug text not null default '',

  stime bigint not null default 0,

  like_count int not null default 0,
  star_count int not null default 0,

  crit_count int not null default 0,
  crit_total int not null default 0,

  list_count int not null default 0,
  list_total int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ysuser_unique_idx ON ysusers (zname);
CREATE UNIQUE INDEX ysuser_origin_idx ON ysusers (origin_id);


-- +micrate Down
DROP TABLE IF EXISTS ysusers;
