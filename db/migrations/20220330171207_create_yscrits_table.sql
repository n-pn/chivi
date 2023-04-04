-- +micrate Up
CREATE TABLE yscrits (
  yc_id text NOT NULL PRIMARY KEY,
  id serial NOT NULL,
  --
  ysbook_id int4 NOT NULL DEFAULT 0 REFERENCES ysbooks (id) ON UPDATE CASCADE ON DELETE CASCADE,
  nvinfo_id int4 NOT NULL DEFAULT 0 REFERENCES nvinfos (id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  gu_id int4 NOT NULL DEFAULT 0, -- chivi ysuser id
  yu_id int4 NOT NULL DEFAULT 0, -- original user id
  --
  yslist_id int4 NOT NULL DEFAULT 0,
  yl_id bytea NOT NULL DEFAULT ''::bytea,
  --
  stars int NOT NULL DEFAULT 3,
  _sort int GENERATED ALWAYS AS (stars * (stars * like_count + repl_count)) STORED,
  --
  ztext text compresssion lz4 NOT NULL DEFAULT '',
  vhtml text compresssion lz4 NOT NULL DEFAULT '',
  --
  ztags text[] NOT NULL DEFAULT '{}',
  vtags text[] NOT NULL DEFAULT '{}',
  --
  utime int8 NOT NULL DEFAULT 0,
  stime int8 NOT NULL DEFAULT 0,
  --
  repl_total int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  like_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX yscrit_uniq_idx ON yscrits (yc_id);

CREATE INDEX yscrit_nvinfo_idx ON yscrits (nvinfo_id, _sort);

CREATE INDEX yscrit_ysbook_idx ON yscrits (ysbook_id);

CREATE INDEX yscrit_ysuser_idx ON yscrits (ysuser_id, created_at);

CREATE INDEX yscrit_yslist_idx ON yscrits (yslist_id);

CREATE INDEX yscrit_sorted_idx ON yscrits (_sort, stars);

CREATE INDEX yscrit_update_idx ON yscrits (utime, stars);

CREATE INDEX yscrit_liked_idx ON yscrits (like_count, stars);

CREATE INDEX yscrit_vtags_idx ON yscrits USING GIN (vtags);

-- +micrate Down
DROP TABLE IF EXISTS yscrits;
