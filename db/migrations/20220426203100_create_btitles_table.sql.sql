-- +micrate Up
CREATE TABLE btitles (
  id bigserial primary key,

  zname text not null unique,
  vname text not null default '',
  hname text not null default '',

  -- vslug text not null default '',
  -- hslug text not null default '',
  __fts varchar generated always as (scrub_name(hname, vname)) stored,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX btitle_zname_idx ON btitles using GIN (zname gin_trgm_ops);
-- CREATE INDEX btitle_vslug_idx ON btitles using GIN (vslug gin_trgm_ops);
-- CREATE INDEX btitle_hslug_idx ON btitles using GIN (hslug gin_trgm_ops);

create index btitle_fuzzy_idx on btitles using GIN (__fts gin_trgm_ops);

-- +micrate Down
DROP TABLE IF EXISTS btitles;
