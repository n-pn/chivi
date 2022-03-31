-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
-- +micrate Up
CREATE TABLE nvinfos (
  id bigserial primary key,

  author_id bigint not null default 0,
  btitle_id bigint not null default 0,

  ysbook_id bigint not null default 0,
  subdue_id bigint not null default 0,

  -- unique identity

  bhash text unique not null,
  bslug text unique not null,

  -- extra

  zseeds int[] not null default '{}',
  genres int[] not null default '{}',
  labels text[] not null default '{}',

  scover text not null default '', -- source cover url
  bcover text not null default '', -- local cover name

  zintro text not null default '', -- book intro in chinese
  vintro text not null default '', -- book intro converted

  status int not null default 0,
  shield int not null default 0,

  atime bigint not null default 0,
  utime bigint not null default 0,

  -- stats

  voters int not null default 0,
  rating int not null default 0,
  weight int not null default 0,

  -- counters

  chap_count int not null default 0, -- chapter count
  word_count int not null default 0, -- chapter count

  star_count int not null default 0,
  view_count int not null default 0,

  -- cvuser stats
  crit_count int not null default 0, -- review created
  list_count int not null default 0, --

  -- origin

  pub_link text not null default '',
  pub_name text not null default '',

  -- dboard

  board_bump bigint not null default 0,
  post_count int not null default 0, -- topic created

  -- timestamps

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvinfo_unique_idx ON nvinfos (author_id, btitle_id);

----

CREATE INDEX nvinfo_zseed_idx ON nvinfos using GIN (zseeds gin__int_ops);
CREATE INDEX nvinfo_genre_idx ON nvinfos using GIN (genres gin__int_ops);
CREATE INDEX nvinfo_label_idx ON nvinfos using GIN (labels);

---

CREATE INDEX nvinfo_atime_idx ON nvinfos (atime);
CREATE INDEX nvinfo_utime_idx ON nvinfos (utime);

CREATE INDEX nvinfo_bump_idx ON nvinfos (board_bump);

---

CREATE INDEX nvinfo_weight_idx ON nvinfos (weight);
CREATE INDEX nvinfo_voters_idx ON nvinfos (voters);
CREATE INDEX nvinfo_rating_idx ON nvinfos (rating);

---

CREATE INDEX nvinfo_yousuu_idx ON nvinfos (ysbook_id);

-- +micrate Down
DROP TABLE IF EXISTS nvinfos;
