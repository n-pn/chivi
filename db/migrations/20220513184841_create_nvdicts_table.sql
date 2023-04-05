-- +micrate Up
CREATE TABLE IF NOT EXISTS nvdicts(
  id serial PRIMARY KEY,
  nvinfo_id int NOT NULL,
  --
  dname text NOT NULL DEFAULT '',
  d_lbl text NOT NULL DEFAULT '',
  --
  dsize int NOT NULL DEFAULT 0,
  p_min int NOT NULL DEFAULT 0,
  --
  ctime bigint NOT NULL DEFAULT 0,
  utime bigint NOT NULL DEFAULT 0,
  --
  unames text[] NOT NULL DEFAULT '{}',
  themes text[] NOT NULL DEFAULT '{}',
  --
  parent_id bigint NOT NULL DEFAULT -1,
  dupped_at bigint NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvdict_unique_idx ON nvdicts(dname);

CREATE INDEX nvdict_nvinfo_idx ON nvdicts(nvinfo_id);

CREATE INDEX nvdict_parent_idx ON nvdicts(parent_id);

CREATE INDEX nvdict_unames_idx ON nvdicts USING GIN(unames);

CREATE INDEX nvdict_themes_idx ON nvdicts USING GIN(themes);

CREATE INDEX nvdict_utime_idx ON nvdicts(utime);

CREATE INDEX nvdict_dsize_idx ON nvdicts(dsize);

-- +micrate Down
DROP TABLE IF EXISTS nvdicts;
