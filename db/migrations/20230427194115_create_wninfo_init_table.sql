-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE wninfo_init(
  id int PRIMARY KEY REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  yb_id int NOT NULL DEFAULT 0,
  tb_id int NOT NULL DEFAULT 0,
  --
  zintro text compression lz4 NOT NULL DEFAULT '',
  zintro_by text NOT NULL DEFAULT '',
  --
  zcover text NOT NULL DEFAULT '',
  zcover_by text NOT NULL DEFAULT '',
  --
  genres text[] NOT NULL DEFAULT '{}',
  labels text[] NOT NULL DEFAULT '{}',
  tagged_by text NOT NULL DEFAULT '',
  --
  orig_links text[] NULL DEFAULT '{}',
  seed_links text[] NULL DEFAULT '{}',
  -- yousuu stats
  yvoters int NOT NULL DEFAULT 0,
  yrating int NOT NULL DEFAULT 0,
  -- tuishujun stats
  tvoters int NOT NULL DEFAULT 0,
  trating int NOT NULL DEFAULT 0,
  -- chivi stats
  vvoters int NOT NULL DEFAULT 0,
  vrating int NOT NULL DEFAULT 0
);

CREATE INDEX wninfo_init_yb_id_idx ON wninfo_init(yb_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE wninfo_init;
