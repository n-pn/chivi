-- +micrate Up
CREATE TABLE yscrits (
  id bigserial primary key,
  origin_id text not null,

  ysbook_id bigint not null default 0,
  nvinfo_id bigint not null default 0,

  ysuser_id bigint not null default 0,
  yslist_id bigint not null default 0,

  stars int not null default 3,
  _sort int not null default 0,

  ztext text not null default '',
  vhtml text not null default '',

  ztags text[] not null default '{}',
  vtags text[] not null default '{}',

  utime bigint not null default 0,
  stime bigint not null default 0,

  repl_total int not null default 0,
  repl_count int not null default 0,
  like_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX yscrit_origin_idx ON yscrits (origin_id);

CREATE INDEX yscrit_nvinfo_idx ON yscrits (nvinfo_id, _sort);
CREATE INDEX yscrit_ysbook_idx ON yscrits (ysbook_id);
CREATE INDEX yscrit_ysuser_idx ON yscrits (ysuser_id, created_at);
CREATE INDEX yscrit_yslist_idx ON yscrits (yslist_id);

CREATE INDEX yscrit_sorted_idx ON yscrits (_sort, stars);
CREATE INDEX yscrit_update_idx ON yscrits (utime, nvinfo_id);

CREATE INDEX yscrit_vtags_idx ON yscrits USING GIN(vtags);

-- +micrate Down
DROP TABLE IF EXISTS yscrits;
