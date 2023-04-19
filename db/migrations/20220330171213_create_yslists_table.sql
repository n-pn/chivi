-- +micrate Up
CREATE TABLE yslists(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  yl_id bytea NOT NULL UNIQUE,
  --
  ysuser_id int NOT NULL DEFAULT REFERENCES ysusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  zname text NOT NULL,
  vname text NOT NULL,
  vslug text NOT NULL DEFAULT '-',
  --
  zdesc text NOT NULL DEFAULT '',
  vdesc text NOT NULL DEFAULT '',
  --
  klass text NOT NULL DEFAULT 'male',
  --
  covers text[] NOT NULL DEFAULT '{}' ::text[],
  genres text[] NOT NULL DEFAULT '{}' ::text[],
  --
  utime bigint NOT NULL DEFAULT 0,
  stime bigint NOT NULL DEFAULT 0,
  --
  _bump int NOT NULL DEFAULT 0,
  _sort int NOT NULL DEFAULT 0,
  --
  book_count int NOT NULL DEFAULT 0,
  book_total int NOT NULL DEFAULT 0,
  --
  like_count int NOT NULL DEFAULT 0,
  view_count int NOT NULL DEFAULT 0,
  star_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX yslists_uniq_idx ON yslists(yl_id);

CREATE INDEX yslists_ysuser_idx ON yslists(ysuser_id);

CREATE INDEX yslists_search_idx ON yslists USING GIN(vslug gin_trgm_ops);

CREATE INDEX yslists_update_idx ON yslists(utime);

CREATE INDEX yslists_viewed_idx ON yslists(view_count);

CREATE INDEX yslists_ranked_idx ON yslists(like_count);

-- +micrate Down
DROP TABLE IF EXISTS yslists;
