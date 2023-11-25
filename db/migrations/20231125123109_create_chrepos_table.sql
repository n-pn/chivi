-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE IF NOT EXISTS chrepos(
  sroot varchar NOT NULL PRIMARY KEY,
  owner int NOT NULL DEFAULT -1 REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  stype smallint NOT NULL DEFAULT 0,
  sn_id int NOT NULL DEFAULT -1,
  --
  vname varchar NOT NULL DEFAULT '',
  zname varchar NOT NULL DEFAULT '',
  wn_id int NOT NULL DEFAULT -1,
  --
  chmax int NOT NULL DEFAULT 0,
  avail int NOT NULL DEFAULT 0,
  --
  plock smallint NOT NULL DEFAULT 0,
  gifts smallint NOT NULL DEFAULT 1,
  multp smallint NOT NULL DEFAULT 4,
  --
  view_count int NOT NULL DEFAULT 0,
  like_count int NOT NULL DEFAULT 0,
  star_count int NOT NULL DEFAULT 0,
  --
  mtime bigint NOT NULL DEFAULT 0,
  rtime bigint NOT NULL DEFAULT 0,
  _flag smallint NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS chrepos_owner_idx ON chrepos("owner");

CREATE INDEX IF NOT EXISTS chrepos_stype_idx ON chrepos("stype", "sn_id");

CREATE INDEX IF NOT EXISTS chrepos_wn_id_idx ON chrepos("wn_id");

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS chrepos;
