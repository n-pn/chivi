create table if not exists books(
  id integer PRIMARY KEY,
  cv_id integer not null default 0,

  btitle varchar NOT NULL default '',
  author varchar NOT NULL default '',

  intro text NOT NULL DEFAULT '',
  genre varchar NOT NULL DEFAULT '',
  btags varchar NOT NULL DEFAULT '',

  cover text NOT NULL DEFAULT '',
  origs text NOT NULL DEFAULT '',

  voters integer NOT NULL DEFAULT 0,
  rating integer NOT NULL DEFAULT 0,

  status integer NOT NULL DEFAULT 0,
  shield integer NOT NULL DEFAULT 0,
  
  mtime integer NOT NULL DEFAULT 0,

  word_total integer NOT NULL DEFAULT 0,
  crit_total integer NOT NULL DEFAULT 0,
  list_total integer NOT NULL DEFAULT 0,

  crit_count integer NOT NULL DEFAULT 0,
  list_count integer NOT NULL DEFAULT 0,

  cprio integer NOT NULL DEFAULT 0,
  ctime integer NOT NULL DEFAULT 0,
  stime integer NOT NULL DEFAULT 0
);

create index if not exists books_cvid_idx on books(cv_id);
create index if not exists books_name_idx on books(author, btitle);
