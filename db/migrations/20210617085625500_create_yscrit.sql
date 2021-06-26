-- +micrate Up
CREATE TABLE yscrits (
  id bigserial PRIMARY KEY,

  btitle_id bigint,
  ysbook_id bigint not null,

  ysuser_id bigint not null,
  yslist_id bigint,

  stars int default 3 not null,

  ztext text default '' not null,
  vhtml text default '' not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  like_count int default 0 not null,
  repl_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX yscrit_btitle_idx ON yscrits (btitle_id, stars);
CREATE INDEX yscrit_ysbook_idx ON yscrits (ysbook_id, bumped);
CREATE INDEX yscrit_ysuser_idx ON yscrits (ysuser_id, created_at);
CREATE INDEX yscrit_yslist_idx ON yscrits (yslist_id, like_count);


-- +micrate Down
DROP TABLE IF EXISTS yscrits;
