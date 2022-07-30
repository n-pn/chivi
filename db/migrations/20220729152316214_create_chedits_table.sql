-- +micrate Up

CREATE TABLE chedits (
  id serial,

  viuser_id int not null,
  nvseed_id bigint not null,

  chidx smallint not null,
  schid varchar not null,
  cpart smallint not null default 0,

  l_id smallint not null,
  orig text,
  edit text not null,

  flag smallint not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

create index chedits_cvuser_idx on chedits(viuser_id);
create index chedits_nvseed_idx on chedits(nvseed_id, chidx, flag);

-- +micrate Down
DROP TABLE chedits;
