-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE chtexts (
  id serial primary key,

  chroot_id int not null references chroots (id) on update cascade on delete cascade,

  chidx smallint not null,
  schid varchar not null,

  content text[],

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP,

  constraint chtexts_unique_key unique (chroot_id, chidx)
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE chtexts;
