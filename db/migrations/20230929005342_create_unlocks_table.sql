-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE unlocks(
  ulkey citext NOT NULL,
  vu_id integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  owner integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  zsize int NOT NULL DEFAULT 0,
  multp int NOT NULL DEFAULT 0,
  vcoin int NOT NULL DEFAULT 0,
  --
  ctime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0,
  flags int NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (vu_id, ulkey)
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE unlocks;
