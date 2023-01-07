pragma journal_mode = WAL;
pragma synchronous = normal;
pragma temp_store = memory;
pragma mmap_size = 30000000000;

create table specs(
  id integer primary key,

  udict varchar not null default 'miscs',
  zorig varchar default '',
  ztext text not null,

  zfrom integer not null default 0,
  zupto integer not null default 0,

  expect text default '',
  detail text default '',

  tags varchar default '',
  prio integer default 0,

  status integer default 0,
  edit_count integer default 0,

  uname varchar not null default '',
  mtime integer not null default 0
);

create table edits(
  id integer primary key,

  spec_id integer not null,
  edit_no integer not null default 0,

  zfrom integer default 0,
  zupto integer default 0,

  expect text default '',
  detail text default '',

  tags varchar default '',
  prio integer default 0,

  uname varchar not null default '',
  mtime integer not null default 0
);

create table posts(
  id integer primary key,

  spec_id integer not null,
  post_no integer not null default 0,

  btext text not null,
  bhtml text default '',

  uname varchar not null default '',
  mtime integer not null default 0
);

create index specs_tags_idx on specs(tags);
create index specs_prio_idx on specs(prio);
create index specs_user_idx on specs(uname);

create unique index edits_uniq_idx on edits(spec_id, edit_no);
create index edits_user_idex on edits(uname);

create unique index posts_uniq_idx on posts(spec_id, post_no);
create index posts_user_idex on posts(uname);
