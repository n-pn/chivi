-- +micrate Up
CREATE TABLE yscrits (
  id serial PRIMARY KEY,
  origin_id varchar not null unique,

  ysuser_id int not null,
  yslist_id int,
  ysbook_id int not null,

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
CREATE INDEX yscrit_ysbook_id_idx ON yscrits (ysbook_id, like_count);

-- +micrate Down
DROP TABLE IF EXISTS yscrits;
