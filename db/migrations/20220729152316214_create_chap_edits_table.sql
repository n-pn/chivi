-- +micrate Up

CREATE TABLE chap_edits (
  id serial,

  viuser_id int not null,
  chroot_id int not null,

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

create index chap_edits_viuser_idx on chap_edits(viuser_id);
create index chap_edits_chroot_idx on chap_edits(chroot_id, chidx, flag);

-- +micrate Down
DROP TABLE chap_edits;
