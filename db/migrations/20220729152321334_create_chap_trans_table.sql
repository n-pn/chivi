-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE chap_trans (
  id serial primary key,

  viuser_id int not null,
  chroot_id int not null,

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

create index chap_trans_viuser_idx on chap_trans(viuser_id);
create index chap_trans_chroot_idx on chap_trans(chroot_id, chidx, flag);


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE chap_trans;
