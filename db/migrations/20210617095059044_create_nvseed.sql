-- +micrate Up
CREATE TABLE nvseeds (
  id serial PRIMARY KEY,

  nvinfo_id int,

  sname int not null,
  snvid int not null,

  status int default 0 not null,
  shield int default 0 not null ,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  chap_count int default 0 not null,
  last_schid int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX nvseed_nvinfo_id_idx ON nvseeds (nvinfo_id);
CREATE INDEX nvseed_unique_idx ON nvseeds (sname, snvid);

-- +micrate Down
DROP TABLE IF EXISTS nvseeds;
