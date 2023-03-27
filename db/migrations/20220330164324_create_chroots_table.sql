-- +micrate Up
CREATE TABLE wnseeds (
  id serial PRIMARY KEY,
  nvinfo_id bigint NOT NULL DEFAULT 0,
  --
  sname varchar NOT NULL DEFAULT '',
  s_bid int NOT NULL DEFAULT 0,
  zseed int NOT NULL DEFAULT 0,
  --
  status int NOT NULL DEFAULT 0,
  shield int NOT NULL DEFAULT 0,
  --
  utime bigint NOT NULL DEFAULT 0,
  stime bigint NOT NULL DEFAULT 0,
  --
  last_sname varchar NOT NULL DEFAULT '',
  last_schid varchar NOT NULL DEFAULT '',
  chap_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX wnseeds_origin_idx ON wnseeds (sname, s_bid);

CREATE INDEX wnseeds_nvinfo_idx ON wnseeds (nvinfo_id, sname);

CREATE INDEX wnseeds_stime_idx ON wnseeds (stime);

-- +micrate Down
DROP TABLE IF EXISTS wnseedss;
