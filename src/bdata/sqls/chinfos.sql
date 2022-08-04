drop table if exists chinfos;

create table chinfos (
  chidx int primary key,

  sname text not null,
  snvid text not null,
  schid text not null,

  title text default "" not null,
  chvol text default "" not null,

  w_count int default 0 not null,
  p_count int default 0 not null,

  utime bigint default 0 not null,
  uname text default "" not null
);

create index origin_idx on chinfos (schid, sname);
