-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE bcovers (
  link text NOT NULL PRIMARY KEY,
  name text NOT NULL DEFAULT '',
  ext text NOT NULL DEFAULT '.jpg',
  --
  size int NOT NULL DEFAULT 0,
  width int NOT NULL DEFAULT 0,
  --
  wn_id int NOT NULL DEFAULT 0,
  in_use boolean NOT NULL DEFAULT 'f',
  --
  mtime int NOT NULL DEFAULT 0,
  state int NOT NULL DEFAULT 0
);

CREATE INDEX bcovers_uniq_idx ON bcovers (name);

CREATE INDEX bcovers_book_idx ON bcovers (wn_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE bcovers;
