-- +micrate Up
CREATE TABLE btitles (
  id bigserial primary key,

  zname text unique not null,

  hname text not null default '',
  vname text not null default '',

  hslug text not null default '',
  vslug text not null default '',

  _sort int not null default 0,
  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX btitle_zname_idx ON btitles using GIN (zname gin_trgm_ops);
CREATE INDEX btitle_vslug_idx ON btitles using GIN (vslug gin_trgm_ops);
CREATE INDEX btitle_order_idx ON btitles (_sort);


-- +micrate Down
DROP TABLE IF EXISTS btitles;
