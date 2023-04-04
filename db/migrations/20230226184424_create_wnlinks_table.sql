-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE wnlinks (
  id serial PRIMARY KEY,
  book_id int4 NOT NULL REFERENCES nvinfos (id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  link text NOT NULL,
  "name" text NOT NULL,
  "type" int4 NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX wnlink_name_idx ON wnlinks (type, link);

CREATE UNIQUE INDEX wnlink_book_idx ON wnlinks (book_id, link);

-- insert into wnlinks(book_id, link, name, type)
-- select distinct nvinfo_id, pub_link, pub_name, 1 from ysbooks
-- order by nvinfo_id asc;
-- insert into wnlinks(book_id, link, name, type)
-- select nvinfo_id::int, 'https://www.yousuu.com/book/' || id::text, 'yousuu', 2 from ysbooks
-- order by nvinfo_id asc;
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE wnlinks;
