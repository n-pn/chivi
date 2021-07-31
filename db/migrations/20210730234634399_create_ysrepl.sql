-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE ysrepls (
  id bigserial primary key,

  ysuser_id bigint not null default 0,
  yscrit_id bigint not null default 0,

  origin_id text not null unique,

  ztext text not null default '',
  vhtml text not null default '',

  bumped bigint not null default 0,

  like_count int not null default 0,
  repl_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX ysrepl_ysuser_idx ON ysrepls (ysuser_id);
CREATE INDEX ysrepl_yscrit_idx ON ysrepls (yscrit_id, created_at);


-- +micrate Down
DROP TABLE IF EXISTS ysrepls;
