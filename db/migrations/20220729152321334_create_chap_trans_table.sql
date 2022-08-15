-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE chap_trans (
  id serial primary key,

  viuser_id int not null references viusers (id) on delete cascade on update cascade,
  chroot_id int not null references chroots (id) on delete cascade on update cascade,

  ch_no int not null,

  part_no smallint default 0 not null,
  line_no smallint not null,

  orig text,
  tran text not null,

  flag smallint default 0 not null,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

create index chap_trans_viuser_idx on chap_trans(viuser_id);
create index chap_trans_chroot_idx on chap_trans(chroot_id, ch_no, flag);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE chap_trans;
