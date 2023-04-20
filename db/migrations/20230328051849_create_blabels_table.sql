-- +micrate Up
CREATE TABLE blabels(
  "name" citext NOT NULL,
  "type" smallint NOT NULL DEFAULT 0,
  "slug" text NOT NULL DEFAULT '',
  "alts" citext[] NOT NULL DEFAULT '{}',
  --
  book_count int NOT NULL DEFAULT 0,
  view_count int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  PRIMARY KEY ("name", "type")
);

CREATE INDEX blabels_type_idx ON blabels("type", "book_count");

CREATE INDEX blabels_alts_idx ON blabels USING GIN(alts);

-- +micrate Down
DROP TABLE IF EXISTS blabels;
