-- +micrate Up
CREATE TABLE chroots (
  id serial primary key,

  nvinfo_id bigint not null default 0,

  sname varchar not null default '',
  s_bid int not null default 0,
  zseed int not null default 0,

  status int not null default 0,
  shield int not null default 0,

  utime bigint not null default 0,
  stime bigint not null default 0,

  last_sname varchar not null default '',
  last_schid varchar not null default '',
  chap_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX chroot_origin_idx ON chroots (sname, s_bid);
CREATE INDEX chroot_nvinfo_idx ON chroots (nvinfo_id, sname);
CREATE INDEX chroot_stime_idx ON chroots (stime);


-- +micrate Down
DROP TABLE IF EXISTS chroots;
