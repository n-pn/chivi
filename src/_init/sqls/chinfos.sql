drop table if exists chinfos;

create table chinfos (
  chidx int primary key,
  schid text not null,

  title text default "" not null,
  chvol text default "" not null,

  utime bigint default 0 not null,
  uname text default "" not null,

  -- ctime bigint default 0 not null,
  -- privi int default 0 not null,

  w_count int default 0 not null,
  p_count int default 0 not null,

  o_sname text default "" not null,
  o_snvid text default "" not null,
  o_chidx int default 0 not null
);

create index schid_idx on chinfos(schid);
