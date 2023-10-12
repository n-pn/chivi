-- +micrate Up
CREATE TABLE wnmemos(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  viuser_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  nvinfo_id int NOT NULL REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  status int NOT NULL DEFAULT 0,
  locked boolean NOT NULL DEFAULT FALSE,
  --
  atime bigint NOT NULL DEFAULT 0,
  utime bigint NOT NULL DEFAULT 0,
  --
  lr_sname text NOT NULL DEFAULT '',
  lr_zseed int NOT NULL DEFAULT 0,
  --
  lr_chidx int NOT NULL DEFAULT 0,
  lr_cpart int NOT NULL DEFAULT 0,
  --
  lc_title text NOT NULL DEFAULT '',
  lc_uslug text NOT NULL DEFAULT '',
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ubmemo_unique_idx ON wnmemos(nvinfo_id, viuser_id);

CREATE INDEX ubmemo_cvuser_idx ON wnmemos(status, viuser_id);

CREATE INDEX ubmemo_viewed_idx ON wnmemos(viuser_id, atime);

-- +micrate Down
DROP TABLE IF EXISTS wnmemos;
