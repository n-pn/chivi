-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dtopics(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  viuser_id int NOT NULL DEFAULT REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  nvinfo_id int NOT NULL DEFAULT 0,
  --
  ptype int NOT NULL DEFAULT 0,
  stars int NOT NULL DEFAULT 3,
  --
  labels text[] NOT NULL DEFAULT '{}',
  lslugs text[] NOT NULL DEFAULT '{}',
  --
  title text NOT NULL DEFAULT '',
  tslug text NOT NULL DEFAULT '',
  brief text NOT NULL DEFAULT '',
  --
  state int NOT NULL DEFAULT 0, -- states: public, sticky, deleted....
  utime bigint NOT NULL DEFAULT 0, -- update when new post created
  --
  _sort int NOT NULL DEFAULT 0,
  _bump int NOT NULL DEFAULT 0,
  --
  repl_count int NOT NULL DEFAULT 0, -- post count
  like_count int NOT NULL DEFAULT 0, -- like count
  view_count int NOT NULL DEFAULT 0, -- view count
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX cvpost_cvuser_idx ON cvposts(viuser_id);

CREATE INDEX cvpost_nvinfo_idx ON cvposts(nvinfo_id);

CREATE INDEX cvpost_stars_idx ON cvposts(stars);

CREATE INDEX cvpost_sorts_idx ON cvposts(_sort);

CREATE INDEX cvpost_number_idx ON cvposts(ii);

CREATE INDEX cvpost_label_idx ON cvposts USING GIN(lslugs);

CREATE INDEX cvpost_uslug_idx ON cvposts USING GIN(tslug gin_trgm_ops);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS cvposts;
