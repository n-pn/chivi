-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE chlinks (
  id serial primary key,

  chroot_id int not null references chroots (id) on update cascade on delete cascade,
  ch_no smallint not null,

  orig_chroot_id int not null references chroots (id) on update cascade on delete cascade,
  orig_ch_no smallint not null,

  constraint chlinks_unique_key unique (chroot_id, ch_no)
);

create index chlinks_origin_idx on chlinks(orig_chroot_id, orig_ch_no);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE chlinks;
