-- +micrate Up
CREATE TABLE yscrits(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  yc_id bytea NOT NULL UNIQUE,
  --
  ysbook_id int NOT NULL DEFAULT 0 REFERENCES ysbooks(id) ON UPDATE CASCADE ON DELETE CASCADE,
  nvinfo_id int NOT NULL DEFAULT 0 REFERENCES nvinfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  ysuser_id int NOT NULL DEFAULT 0,
  --
  yl_id bytea NOT NULL DEFAULT ''::bytea,
  yslist_id int NOT NULL DEFAULT 0,
  --
  stars int NOT NULL DEFAULT 3,
  _sort int GENERATED ALWAYS AS (stars *(stars * like_count + repl_count)) STORED,
  --
  ztext text compresssion lz4 NOT NULL DEFAULT '',
  vhtml text compresssion lz4 NOT NULL DEFAULT '',
  --
  ztags text[] NOT NULL DEFAULT '{}' ::text[],
  vtags text[] NOT NULL DEFAULT '{}' ::text[],
  --
  utime bigint NOT NULL DEFAULT 0,
  info_rtime bigint NOT NULL DEFAULT 0,
  --
  repl_total int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  like_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX yscrit_nvinfo_idx ON yscrits(nvinfo_id, _sort);

CREATE INDEX yscrit_ysbook_idx ON yscrits(ysbook_id);

CREATE INDEX yscrit_ysuser_idx ON yscrits(ysuser_id, created_at);

CREATE INDEX yscrit_yslist_idx ON yscrits(yslist_id);

CREATE INDEX yscrit_sorted_idx ON yscrits(_sort, stars);

CREATE INDEX yscrit_update_idx ON yscrits(utime, stars);

CREATE INDEX yscrit_liked_idx ON yscrits(like_count, stars);

CREATE INDEX yscrit_vtags_idx ON yscrits USING GIN(vtags);

-- +micrate Down
DROP TABLE IF EXISTS yscrits;
