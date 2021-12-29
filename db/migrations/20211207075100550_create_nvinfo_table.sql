-- +micrate Up
CREATE TABLE nvinfos (
  id bigserial primary key,

  author_id bigint not null default 0,
  subdue_id bigint,

  zseed_ids int[] not null default '{}', -- not real database table ids
  genre_ids int[] not null default '{}', -- not real database table ids
  labels text[] not null default '{}',

  bhash text unique not null,
  bslug text unique not null,

  zname text not null,
  hname text not null default '',
  vname text not null default '',

  hslug text not null default '',
  vslug text not null default '',

  cover text not null default '',
  intro text not null default '',

  status int not null default 0,
  shield int not null default 0,

  atime bigint not null default 0,
  utime bigint not null default 0,

  -- stats

  weight int not null default 0,
  voters int not null default 0,
  rating int not null default 0,

  cv_voters int not null default 0,
  ys_voters int not null default 0,

  cv_scores int not null default 0,
  ys_scores int not null default 0,

  cv_utime int not null default 0,
  ys_utime int not null default 0,

  -- counters

  cvcrit_count int not null default 0,
  yscrit_count int not null default 0,

  cvlist_count int not null default 0,
  yslist_count int not null default 0,

  total_clicks int not null default 0,
  dtopic_count int not null default 0,
  ubmemo_count int not null default 0,

  cv_chap_count int not null default 0,
  ys_word_count int not null default 0,

  -- links

  ys_snvid int,
  pub_link text not null default '',
  pub_name text not null default '',

  -- timestamps

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvinfo_unique_idx ON nvinfos (author_id, zname);

CREATE INDEX nvinfo_zname_idx ON nvinfos using GIN (zname gin_trgm_ops);
CREATE INDEX nvinfo_hname_idx ON nvinfos using GIN (hslug gin_trgm_ops);
CREATE INDEX nvinfo_vname_idx ON nvinfos using GIN (vslug gin_trgm_ops);

CREATE INDEX nvinfo_zseed_idx ON nvinfos using GIN (zseed_ids);
CREATE INDEX nvinfo_genre_idx ON nvinfos using GIN (genre_ids);
CREATE INDEX nvinfo_label_idx ON nvinfos using GIN (labels);

CREATE INDEX nvinfo_atime_idx ON nvinfos (atime);
CREATE INDEX nvinfo_utime_idx ON nvinfos (utime);

CREATE INDEX nvinfo_weight_idx ON nvinfos (weight);
CREATE INDEX nvinfo_voters_idx ON nvinfos (voters);
CREATE INDEX nvinfo_rating_idx ON nvinfos (rating);

CREATE INDEX nvinfo_yousuu_idx ON nvinfos (ys_snvid);

-- +micrate Down
DROP TABLE IF EXISTS nvinfos;
