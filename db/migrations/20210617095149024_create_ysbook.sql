-- +micrate Up
CREATE TABLE ysbooks (
  id serial PRIMARY KEY,

  author varchar not null,
  btitle varchar not null,

  genres varchar[] not null,
  bintro text,
  bcover varchar(512),

  status int default 0 not null,
  shield int default 0 not null ,

  voters int default 0 not null,
  rating int default 0 not null,

  mftime bigint default 0 not null,
  bumped bigint default 0 not null,

  orig_link varchar,
  orig_name varchar,

  word_count int default 0 not null,
  list_count int default 0 not null,
  crit_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX ysbook_unique_idx ON ysbooks (author, title);

-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
