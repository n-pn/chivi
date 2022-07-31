-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
create table chinfos (
  id serial,
  chroot_id int not null,
  viuser_id int,

  chidx smallint not null,
  schid varchar not null,

  title varchar not null default '';
  chvol varchar not null default '';

  parts text[][],

  w_count int not null default 0,
  p_count smallint not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP,

constraint fk_viuser_chinfo
      foreign key(viuser_id)
      references viusers(id)
      on update cascade
      on delete set null,

  constraint fk_chroot_chinfo
      foreign key(chroot_id)
      references chroots(id)
      on update cascade
      on delete cascade
);

create unique index chinfo_unique_idx chinfos(chroot_id, chidx);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

drop table chinfos;
