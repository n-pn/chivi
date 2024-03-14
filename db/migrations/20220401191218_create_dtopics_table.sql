-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dtopics(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  viuser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  title text NOT NULL DEFAULT '',
  tslug text NOT NULL DEFAULT '',
  ptype smallint NOT ulll DEFAULT 0,
  --
  ibody text NOT NULL DEFAULT '',
  itype smallint NOT NULL DEFAULT 0,
  bhtml text NOT NULL DEFAULT '',
  bdesc text NOT NULL DEFAULT '',
  --
  htags text[] NOT NULL DEFAULT '{}',
  _flag int NOT NULL DEFAULT 0,
  --
  repl_count int NOT NULL DEFAULT 0, -- post count
  view_count int NOT NULL DEFAULT 0, -- view count
  like_count int NOT NULL DEFAULT 0, -- like count
  --
  ctime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0,
  rtime bigint NOT NULL DEFAULT 0,
  atime bigint NOT NULL DEFAULT 0
);

CREATE INDEX dtopic_cvuser_idx ON dtopics(viuser_id);

CREATE INDEX dtopic_nvinfo_idx ON dtopics(nvinfo_id);

CREATE INDEX dtopic_stars_idx ON dtopics(stars);

CREATE INDEX dtopic_sorts_idx ON dtopics(_sort);

CREATE INDEX dtopic_number_idx ON dtopics(ii);

CREATE INDEX dtopic_htag_idx ON dtopics USING GIN(htags);

CREATE INDEX dtopic_slug_idx ON dtopics USING GIN(tslug gin_trgm_ops);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS dtopics;
