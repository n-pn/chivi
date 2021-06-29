-- +micrate Up
CREATE TABLE yslists (
  id bigserial primary key,

  ysuser_id bigint not null,

  zname text not null,
  vname text not null,

  zdesc text not null default '',
  vdesc text not null default '',

  aim_at text not null default 'male',

  bumped bigint not null default 0,
  mftime bigint not null default 0,

  book_count int not null default 0,
  like_count int not null default 0,
  view_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX yslist_ysuser_idx ON yslists (ysuser_id);


-- +micrate Down
DROP TABLE IF EXISTS yslists;
