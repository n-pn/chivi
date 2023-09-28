-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE unlocks(
  vu_id integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  ulkey citext NOT NULL,
  --
  zsize int not null default 0,
  multp int not null default 0,
  vcoin int not null default 0,
  --
  ctime bigint not null default 0,
  mtime bigint NOT NULL DEFAULT 0,
  flags int NOT NULL DEFAULT 0,
  --
  PRIMARY KEY(vu_id, ulkey)
  );

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE unlocks;
