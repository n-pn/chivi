-- +micrate Up
CREATE TABLE yscrit(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  yc_id bytea NOT NULL UNIQUE,
  yl_id bytea,
  --
  ysbook_id int NOT NULL DEFAULT 0 REFERENCES ysbooks(id) ON UPDATE CASCADE ON DELETE CASCADE,
  nvinfo_id int NOT NULL DEFAULT 0 REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  ysuser_id int NOT NULL DEFAULT 0 REFERENCES ysusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  yslist_id int,
  --
  stars int NOT NULL DEFAULT 3,
  _sort int GENERATED ALWAYS AS (stars *(stars * like_count + repl_count)) STORED,
  --
  ztext text compresssion lz4 NOT NULL DEFAULT '',
  vhtml text compresssion lz4 NOT NULL DEFAULT '',
  vi_mt text compresssion lz4,
  vi_bd text compresssion lz4,
  en_bd text compresssion lz4,
  en_dl text compresssion lz4,
  --
  ztags text[] NOT NULL DEFAULT '{}' ::text[],
  vtags text[] NOT NULL DEFAULT '{}' ::text[],
  --
  info_rtime bigint NOT NULL DEFAULT 0,
  --
  repl_total int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  like_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX yscrit_nvinfo_idx ON yscrit(nvinfo_id);

CREATE INDEX yscrit_ysbook_idx ON yscrit(ysbook_id);

CREATE INDEX yscrit_ysuser_idx ON yscrit(ysuser_id);

CREATE INDEX yscrit_yslist_idx ON yscrit(yslist_id);

CREATE INDEX yscrit_rating_idx ON yscrit(stars);

CREATE INDEX yscrit_update_idx ON yscrit(updated_at);

CREATE INDEX yscrit_liked_idx ON yscrit(like_count);

CREATE INDEX yscrit_vtags_idx ON yscrit USING GIN(vtags);

-- +micrate Down
DROP TABLE IF EXISTS yscrit;
