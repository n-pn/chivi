-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE unlocks(
  vu_id integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  ulkey citext NOT NULL,
  --
  owner integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  zsize int NOT NULL DEFAULT 0,
  --
  real_multp smallint NOT NULL DEFAULT 0,
  user_multp smallint NOT NULL DEFAULT 0,
  owner_got int NOT NULL DEFAULT 0,
  user_lost int NOT NULL DEFAULT 0,
  --
  ctime bigint NOT NULL DEFAULT 0,
  flags int NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (vu_id, ulkey)
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE unlocks;
