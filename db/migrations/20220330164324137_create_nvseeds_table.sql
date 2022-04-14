-- +micrate Up
CREATE TABLE nvseeds (
  id bigserial primary key,
  uid bigint not null default 0,

  nvinfo_id bigint not null default 0,

  zseed int not null default 0,
  sname text not null default '',
  snvid text not null default '',

  status int not null default 0,
  shield int not null  default 0,

  utime bigint not null default 0,
  stime bigint not null default 0,
  ftime bigint not null default 0,

  chap_count int not null default 0,
  last_schid text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvseed_unique_idx ON nvseeds (zseed, snvid);
CREATE INDEX nvseed_autogen_idx ON nvseeds (uid);
CREATE INDEX nvseed_nvinfo_idx ON nvseeds (nvinfo_id);
CREATE INDEX nvseed_stime_idx ON nvseeds (stime);


-- +micrate Down
DROP TABLE IF EXISTS nvseeds;
