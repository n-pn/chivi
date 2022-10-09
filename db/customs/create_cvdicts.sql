-- sqlite3
-- mt dict use in chivi

create table dicts (
  id integer primary key,

  dname varchar not null,
  dtype integer not null,

  label varchar not null, -- display name
  intro text, -- dict introduction

  min_privi int not null default 1,

  -- term total mean all entries in dict
  -- term count mean all undeleted entries in dict

  term_total int not null default 0,
  term_count int not null default 0,

  -- latest time a term get added/updated
  last_mtime int not null default 0
);

create unique index dicts_dname_idx on dicts (dname);
create index dicts_mtime_idx on dicts (last_mtime);
create index dicts_dtype_idx on dicts (dtype);

-------

create table terms (
  id integer primary key,
  dict_id int not null,

  -- tranlation
  key varchar not null, -- input text normalized
  key_raw varchar, -- raw input text

  val varchar not null, -- main meaning
  alt_val varchar, -- alternative meaning

  -- postag marking
  ptag varchar, -- generic postag label
  epos int not null default 0, -- mtl_pos enum value
  etag int not null default 0, -- mtl_tag enum value

  -- priority rank for word segmentation
  seg_r int not null default 2, -- user input
  seg_w int not null default 0, -- map priority rank to term weight

  -- user metadata
  uname varchar not null default "",
  mtime int not null default 0, -- term update time

  -- management
  _prev int, -- previous term
  _flag int not null default 0, -- marking term as active or inactive
  _lock int not null default 0 -- lock changing?
);

create index terms_scan_idx on terms(dict_id, _flag, uname);
create index terms_prev_idx on terms (_prev);
create index terms_mtime_idx on terms (mtime, dict_id);

create index terms_key_idx on terms (key, dict_id);
create index terms_key_raw_idx on terms (key_raw);

create index terms_val_idx on terms (val);
create index terms_alt_val_idx on terms (alt_val);

create index terms_ptag_idx on terms (ptag, dict_id);
