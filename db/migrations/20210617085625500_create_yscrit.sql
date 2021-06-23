-- +micrate Up
CREATE TABLE yscrits (
  id bigserial PRIMARY KEY,

  ysuser_id bigint not null,
  yslist_id bigint,
  ysbook_id bigint not null,

  starred int default 3 not null,

  zh_text text default '' not null,
  vi_html text default '' not null,

  mftime bigint default 0 not null,
  bumped bigint default 0 not null,

  like_count int default 0 not null,
  repl_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX yscrit_ysuser_id_idx ON yscrits (ysuser_id);
CREATE INDEX yscrit_yslist_id_idx ON yscrits (yslist_id);
CREATE INDEX yscrit_ysbook_id_idx ON yscrits (ysbook_id, starred);

-- +micrate Down
DROP TABLE IF EXISTS yscrits;
