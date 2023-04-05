-- +micrate Up
CREATE TABLE blabels(
  "name" citext PRIMARY KEY,
  "slug" text NOT NULL DEFAULT '',
  "type" int NOT NULL DEFAULT 0,
  --
  book_count int NOT NULL DEFAULT 0,
  view_count int NOT NULL DEFAULT 0,
  --
  atime bigint NOT NULL DEFAULT 0,
  mtime bigint NOT NULL DEFAULT 0
);

CREATE INDEX blabel_type_idx ON blabels("type", "book_count");

-- +micrate Down
DROP TABLE IF EXISTS blabels;
