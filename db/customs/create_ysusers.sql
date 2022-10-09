-- sqlite3
-- yousuu users info table

create table users (
  id integer primary key,

  zname varchar not null,
  vname varchar not null default '',
  uslug varchar not null default '',

  like_count int not null default 0,
  star_count int not null default 0,

  -- total means real value in yousuu
  -- count means all item existed in chivi

  list_total int not null default 0,
  list_count int not null default 0,

  crit_total int not null default 0,
  crit_count int not null default 0,

  repl_total int not null default 0,
  repl_count int not null default 0,

  -- last `crawled initialized at` timestamps
  list_rtime int not null default 0,
  crit_rtime int not null default 0,
  repl_rtime int not null default 0,

  created_at int not null default 0,
  updated_at int not null default 0
);

-- for searching
create index zname_index on ysusers (zname);
create index liked_index on ysusers (like_count);

-- for crawling
create index list_rtime on ysusers (list_rtime);
create index crit_rtime on ysusers (crit_rtime);
create index repl_rtime on ysusers (repl_rtime);
