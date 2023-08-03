-- +micrate Up
CREATE TABLE wninfos(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  ysbook_id int NOT NULL DEFAULT 0,
  subdue_id int NOT NULL DEFAULT 0,
  --
  author_zh varchar NOT NULL DEFAULT '',
  author_vi varchar NOT NULL DEFAULT '',
  --
  btitle_zh varchar NOT NULL DEFAULT '',
  btitle_vi varchar NOT NULL DEFAULT '',
  btitle_hv varchar NOT NULL DEFAULT '',
  --
  bslug varchar UNIQUE NOT NULL,
  -- extra
  igenres int[] NOT NULL DEFAULT '{}',
  vlabels citext[] NOT NULL DEFAULT '{}',
  --
  scover varchar NOT NULL DEFAULT '', -- local cover name
  bcover varchar NOT NULL DEFAULT '', -- local cover name
  --
  zintro text NOT NULL DEFAULT '', -- origin book intro
  bintro text NOT NULL DEFAULT '', -- book intro converted
  --
  status int NOT NULL DEFAULT 0,
  shield int NOT NULL DEFAULT 0,
  --
  atime bigint NOT NULL DEFAULT 0,
  utime bigint NOT NULL DEFAULT 0,
  -- stats
  weight int NOT NULL DEFAULT 0,
  voters int NOT NULL DEFAULT 0,
  rating int NOT NULL DEFAULT 0,
  --
  zvoters int NOT NULL DEFAULT 0,
  zrating int NOT NULL DEFAULT 0,
  --
  vvoters int NOT NULL DEFAULT 0,
  vrating int NOT NULL DEFAULT 0,
  -- counters
  chap_count int NOT NULL DEFAULT 0, -- chapter count
  word_count int NOT NULL DEFAULT 0, -- chapter count
  --
  mark_count int NOT NULL DEFAULT 0,
  view_count int NOT NULL DEFAULT 0,
  -- dboard
  board_bump bigint NOT NULL DEFAULT 0,
  post_count int NOT NULL DEFAULT 0, -- topic created
  -- timestamps
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX wninfo_yousuu_idx ON wninfos(ysbook_id);

CREATE UNIQUE INDEX wninfo_unique_idx ON wninfos(author_zh, btitle_zh);

----
CREATE INDEX wninfo_genre_idx ON wninfos USING GIN(igenres gin__int_ops);

CREATE INDEX wninfo_label_idx ON wninfos USING GIN(vlabels);

---
CREATE INDEX wninfo_atime_idx ON wninfos(atime);

CREATE INDEX wninfo_utime_idx ON wninfos(utime);

---
CREATE INDEX wninfo_weight_idx ON wninfos(weight);

CREATE INDEX wninfo_voters_idx ON wninfos(voters);

CREATE INDEX wninfo_rating_idx ON wninfos(rating);

-- +micrate Down
DROP TABLE IF EXISTS wninfos;
