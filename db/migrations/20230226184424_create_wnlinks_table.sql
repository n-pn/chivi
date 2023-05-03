-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE wnlinks(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  book_id int NOT NULL REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  "link" text NOT NULL,
  "name" text NOT NULL,
  "type" int NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX wnlink_name_idx ON wnlinks(type, link);

CREATE UNIQUE INDEX wnlink_book_idx ON wnlinks(book_id, link);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE wnlinks;
