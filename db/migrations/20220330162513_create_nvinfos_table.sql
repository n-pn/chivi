-- +micrate Up
CREATE TABLE nvinfos (
  id bigserial primary key,

  author_id int not null references authors (id) on update cascade on delete cascade,
  btitle_id int not null references btitles (id) on update cascade on delete cascade,

  ysbook_id int4 not null default 0,
  subdue_id bigint not null default 0,

  -- title

  vname varchar not null default '',
  bhash varchar unique not null,
  bslug varchar unique not null,

  -- extra

  igenres int[] not null default '{}',
  vlabels citext[] not null default '{}',

  scover varchar not null default '', -- local cover name
  bcover varchar not null default '', -- local cover name

  zintro text not null default '', -- origin book intro
  bintro text not null default '', -- book intro converted

  status int not null default 0,
  shield int not null default 0,

  atime bigint not null default 0,
  utime bigint not null default 0,

  -- stats
  weight int not null default 0,

  voters int not null default 0,
  rating int not null default 0,

  zvoters int not null default 0,
  zrating int not null default 0,

  vvoters int not null default 0,
  vrating int not null default 0,

  -- counters

  chap_count int not null default 0, -- chapter count
  word_count int not null default 0, -- chapter count

  mark_count int not null default 0,
  view_count int not null default 0,

  -- dboard

  board_bump bigint not null default 0,
  post_count int not null default 0, -- topic created

  -- timestamps

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvinfo_unique_idx ON nvinfos (btitle_id, author_id);
CREATE INDEX nvinfo_author_idx ON nvinfos (author_id);
CREATE INDEX nvinfo_yousuu_idx ON nvinfos (ysbook_id);

----

CREATE INDEX nvinfo_zseed_idx ON nvinfos using GIN (zseeds gin__int_ops);
CREATE INDEX nvinfo_genre_idx ON nvinfos using GIN (igenres gin__int_ops);
CREATE INDEX nvinfo_label_idx ON nvinfos using GIN (vlabels);

---

CREATE INDEX nvinfo_atime_idx ON nvinfos (atime);
CREATE INDEX nvinfo_utime_idx ON nvinfos (utime);
CREATE INDEX nvinfo_bump_idx ON nvinfos (board_bump);

---

CREATE INDEX nvinfo_weight_idx ON nvinfos (weight);
CREATE INDEX nvinfo_voters_idx ON nvinfos (voters);
CREATE INDEX nvinfo_rating_idx ON nvinfos (rating);


-- +micrate Down
DROP TABLE IF EXISTS nvinfos;