-- +micrate Up
CREATE TABLE nvinfos(
  id serial PRIMARY KEY,
  --
  author_id int NOT NULL REFERENCES authors(id) ON UPDATE CASCADE ON DELETE CASCADE,
  btitle_id int NOT NULL REFERENCES btitles(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  ysbook_id int NOT NULL DEFAULT 0,
  subdue_id int NOT NULL DEFAULT 0,
  -- title
  vname varchar NOT NULL DEFAULT '',
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

CREATE UNIQUE INDEX nvinfo_unique_idx ON nvinfos(btitle_id, author_id);

CREATE INDEX nvinfo_author_idx ON nvinfos(author_id);

CREATE INDEX nvinfo_yousuu_idx ON nvinfos(ysbook_id);

----
CREATE INDEX nvinfo_zseed_idx ON nvinfos USING GIN(zseeds gin__int_ops);

CREATE INDEX nvinfo_genre_idx ON nvinfos USING GIN(igenres gin__int_ops);

CREATE INDEX nvinfo_label_idx ON nvinfos USING GIN(vlabels);

---
CREATE INDEX nvinfo_atime_idx ON nvinfos(atime);

CREATE INDEX nvinfo_utime_idx ON nvinfos(utime);

CREATE INDEX nvinfo_bump_idx ON nvinfos(board_bump);

---
CREATE INDEX nvinfo_weight_idx ON nvinfos(weight);

CREATE INDEX nvinfo_voters_idx ON nvinfos(voters);

CREATE INDEX nvinfo_rating_idx ON nvinfos(rating);

-- +micrate Down
DROP TABLE IF EXISTS nvinfos;
