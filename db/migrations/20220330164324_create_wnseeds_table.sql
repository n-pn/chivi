-- +micrate Up
CREATE TABLE wnseeds(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  wn_id int NOT NULL REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  sname text NOT NULL DEFAULT '',
  s_bid int NOT NULL DEFAULT 0,
  --
  chap_total int NOT NULL DEFAULT 0,
  chap_avail int NOT NULL DEFAULT 0,
  --
  slink text NOT NULL DEFAULT '',
  stime bigint NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  privi smallint NOT NULL DEFAULT 3,
  _flag smallint NOT NULL DEFAULT 0,
  --
  UNIQUE (wn_id, sname)
);

-- +micrate Down
DROP TABLE IF EXISTS wnseeds;
