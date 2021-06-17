-- +micrate Up
CREATE TABLE yslists (
  id serial PRIMARY KEY,
  origin_id varchar not null unique,

  ysuser_id int not null,

  zh_name varchar not null,
  vi_name varchar not null,

  zh_desc text,
  vi_desc text,

  channel varchar default 'male' not null,

  mftime bigint default 0 not null,
  bumped bigint default 0 not null,

  like_count int default 0 not null,
  book_count int default 0 not null,
  view_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX yslist_ysuser_id_idx ON yslists (ysuser_id);

-- +micrate Down
DROP TABLE IF EXISTS yslists;
