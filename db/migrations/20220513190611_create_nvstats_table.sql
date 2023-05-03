-- +micrate Up
CREATE TABLE nvstats(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  nvinfo_id int NOT NULL REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  klass int NOT NULL DEFAULT 0,
  stamp int NOT NULL DEFAULT 0,
  value int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  CONSTRAINT nvstats_ukey UNIQUE (klass, stamp, nvinfo_id)
);

CREATE INDEX nvstats_nvinfo_idx ON nvstats(nvinfo_id);

CREATE INDEX nvstats_values_idx ON nvstats(klass, stamp, value);

-- +micrate Down
DROP TABLE IF EXISTS nvstats;
