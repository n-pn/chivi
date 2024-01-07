-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE uquotas(
  vu_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  idate int NOT NULL,
  --
  privi_bonus bigint NOT NULL DEFAULT 0,
  vcoin_bonus bigint NOT NULL DEFAULT 0,
  karma_bonus bigint NOT NULL DEFAULT 0,
  --
  quota_limit bigint NOT NULL GENERATED ALWAYS AS (privi_bonus + vcoin_bonus + karma_bonus) STORED,
  quota_using bigint NOT NULL DEFAULT 0,
  --
  mtime bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (vu_id, idate)
);

CREATE INDEX uquotas_daily_idx ON uquotas(idate, quota_using);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE uquotas;
