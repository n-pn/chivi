-- +micrate Up
CREATE TABLE yscrits (
  id bigserial primary key,
  origin_id text not null,

  ysbook_id bigint not null default 0,
  nvinfo_id bigint not null default 0,

  v_uid int4 not null default 0, -- chivi ysuser id
  y_uid int4 not null default 0, -- original user id

  yslist_id bigint not null default 0,
  y_lid text not null default '',

  stars int not null default 3,
  _sort int generated always as (stars * (stars * like_count + repl_count)) stored,

  b_len int not null default - 1,
  -- ztext text not null default '',
  -- vhtml text not null default '',

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
CREATE INDEX yscrit_update_idx ON yscrits (utime, stars);
CREATE INDEX yscrit_liked_idx ON yscrits (like_count, stars);
CREATE INDEX yscrit_vtags_idx ON yscrits USING GIN(vtags);

-- +micrate Down
DROP TABLE IF EXISTS yscrits;
