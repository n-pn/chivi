-- +micrate Up
CREATE TABLE yslists (
  id bigserial PRIMARY KEY,

  ysuser_id bigint not null,

  zname varchar not null,
  vname varchar not null,

  zdesc text default '' not null,
  vdesc text default '' not null,

  aim_at varchar default 'male' not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  book_count int default 0 not null,
  like_count int default 0 not null,
  view_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX yslist_ysuser_idx ON yslists (ysuser_id);


-- +micrate Down
DROP TABLE IF EXISTS yslists;
