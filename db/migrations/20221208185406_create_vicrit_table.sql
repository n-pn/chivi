-- +micrate Up
CREATE TABLE vicrits (
  id serial PRIMARY KEY,
  viuser_id int NOT NULL REFERENCES viusers (id) ON UPDATE CASCADE ON DELETE CASCADE,
  nvinfo_id bigint NOT NULL REFERENCES nvinfos (id) ON UPDATE CASCADE ON DELETE CASCADE,
  vilist_id int NOT NULL,
  UNIQUE (nvinfo_id, vilist_id),
  stars int NOT NULL DEFAULT 3,
  itext text NOT NULL,
  ohtml text NOT NULL DEFAULT '',
  btags text[] NOT NULL DEFAULT '{}',
  _flag int NOT NULL DEFAULT 0,
  _sort int NOT NULL GENERATED ALWAYS AS (stars * stars * like_count + stars * repl_count) STORED,
  like_count int NOT NULL DEFAULT 0,
  repl_count int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  changed_at timestamptz
);

CREATE INDEX vicrit_viuser_idx ON vicrits (viuser_id);

CREATE INDEX vicrit_vilist_idx ON vicrits (vilist_id);

CREATE INDEX vicrit_stars_idx ON vicrits (stars);

CREATE INDEX vicrit_sorts_idx ON vicrits (_sort);

CREATE INDEX vicrit_likes_idx ON vicrits (like_count);

CREATE INDEX vicrit_btags_idx ON vicrits USING GIN (btags);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS vicrits;
