-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
create table chinfos (
  id serial primary key,

  chroot_id int not null references chroots (id) on update cascade on delete cascade,
  viuser_id int references viusers (id) on update cascade on delete cascade,

  chidx smallint not null,
  schid varchar not null,

  title varchar not null default '',
  chvol varchar not null default '',

  w_count int not null default 0,
  p_count smallint not null default 0,

  changed_at timestamptz,
  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP,

  constraint chinfos_unique_key unique (chroot_id, chidx)
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

drop table chinfos;
