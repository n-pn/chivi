-- +micrate Up
CREATE TABLE if not exists nvdicts (
  id bigserial primary key,

  nvinfo_id bigint not null,

  dname text not null default '',
  d_lbl text not null default '',

  dsize int not null default 0,
  p_min int not null default 0,

  ctime bigint not null default 0,
  utime bigint not null default 0,

  unames text[] not null default '{}',
  themes text[] not null default '{}',

  parent_id bigint not null default -1,
  dupped_at bigint not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvdict_unique_idx ON nvdicts (dname);

CREATE INDEX nvdict_nvinfo_idx ON nvdicts (nvinfo_id);
CREATE INDEX nvdict_parent_idx ON nvdicts (parent_id);

CREATE INDEX nvdict_unames_idx ON nvdicts USING GIN (unames);
CREATE INDEX nvdict_themes_idx ON nvdicts USING GIN (themes);

CREATE INDEX nvdict_utime_idx ON nvdicts (utime);
CREATE INDEX nvdict_dsize_idx ON nvdicts (dsize);

-- +micrate Down
DROP TABLE IF EXISTS nvdicts;
