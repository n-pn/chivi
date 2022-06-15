-- +micrate Up
CREATE TABLE nvseeds (
  id bigserial primary key,

  nvinfo_id bigint not null default 0,

  sname text not null default '',
  snvid text not null default '',
  zseed int not null default 0,

  status int not null default 0,
  shield int not null default 0,

  utime bigint not null default 0,
  stime bigint not null default 0,

  last_sname text not null default '',
  last_schid text not null default '',
  chap_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX nvseed_unique_idx ON nvseeds (sname, snvid);
CREATE INDEX nvseed_nvinfo_idx ON nvseeds (nvinfo_id, sname);
CREATE INDEX nvseed_stime_idx ON nvseeds (stime);


-- +micrate Down
DROP TABLE IF EXISTS nvseeds;
