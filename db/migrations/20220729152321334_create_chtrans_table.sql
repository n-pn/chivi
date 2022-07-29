-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE chtrans (
  id serial,

  cvuser_id bigint not null,
  nvseed_id bigint not null,

  chidx smallint not null,
  schid varchar not null,

  cpart smallint default 0 not null,
  l_id smallint not null,

  orig text,
  tran text not null,

  flag smallint default 0 not null,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

create index chtrans_cvuser_idx on chtrans(cvuser_id);
create index chtrans_nvseed_idx on chtrans(nvseed_id, chidx, flag);


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE chtrans;
