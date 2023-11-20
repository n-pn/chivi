-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE uprivis(
  vu_id int NOT NULL PRIMARY KEY REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  p_now smallint NOT NULL DEFAULT -1,
  p_exp bigint NOT NULL DEFAULT 0,
  --
  exp_a bigint[] NOT NULL DEFAULT '{0, 0, 0, 0}',
  --
  mtime bigint NOT NULL DEFAULT 0
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE uprivis;
