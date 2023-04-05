-- +micrate Up
CREATE TABLE nvstats(
  id serial PRIMARY KEY,
  nvinfo_id int NOT NULL,
  --
  klass int NOT NULL DEFAULT 0,
  stamp int NOT NULL DEFAULT 0,
  value int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  CONSTRAINT nvstat_unique_key UNIQUE (klass, stamp, nvinfo_id)
);

CREATE INDEX nvstat_nvinfo_idx ON nvstats(nvinfo_id);

CREATE INDEX nvstat_values_idx ON nvstats(klass, stamp, value);

-- +micrate Down
DROP TABLE IF EXISTS nvstats;
