-- +micrate Up
CREATE TABLE vilists(
  id serial PRIMARY KEY,
  viuser_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  title text NOT NULL,
  tslug text NOT NULL DEFAULT '',
  --
  dtext text NOT NULL, -- description input
  dhtml text NOT NULL DEFAULT '', -- description html
  --
  klass varchar NOT NULL DEFAULT 'male',
  --
  covers varchar[] NOT NULL DEFAULT '{}',
  genres varchar[] NOT NULL DEFAULT '{}',
  --
  _flag int NOT NULL DEFAULT 0,
  _sort int NOT NULL DEFAULT 0,
  _bump int NOT NULL DEFAULT 0,
  --
  book_count int NOT NULL DEFAULT 0,
  like_count int NOT NULL DEFAULT 0,
  star_count int NOT NULL DEFAULT 0,
  view_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX vilist_viuser_idx ON vilists(viuser_id);

CREATE INDEX vilist_search_idx ON vilists USING GIN(tslug gin_trgm_ops);

CREATE INDEX vilist_sorts_idx ON vilists(_sort);

CREATE INDEX vilist_bumps_idx ON vilists(_bump);

CREATE INDEX vilist_stars_idx ON vilists(star_count);

CREATE INDEX vilist_likes_idx ON vilists(like_count);

CREATE INDEX vilist_views_idx ON vilists(view_count);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS vilist;
