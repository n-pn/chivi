-- +micrate Up
CREATE TABLE nvstats (
  id bigserial primary key,

  nvinfo_id bigint not null,

  klass int not null default 0,
  stamp int not null default 0,
  value int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP,

  constraint nvstat_unique_key unique(klass, stamp, nvinfo_id)
);

CREATE INDEX nvstat_nvinfo_idx ON nvstats (nvinfo_id);
CREATE INDEX nvstat_values_idx ON nvstats (klass, stamp, value);

-- +micrate Down
DROP TABLE IF EXISTS nvstats;
