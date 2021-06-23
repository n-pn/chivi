-- +micrate Up
CREATE TABLE ysbooks (
  id bigserial PRIMARY KEY,

  cvbook_id bigint,

  author varchar not null,
  btitle varchar not null,

  genres varchar[] not null,
  bintro text,
  bcover varchar(512),

  status int default 0 not null,
  shield int default 0 not null ,

  voters int default 0 not null,
  rating int default 0 not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  word_count int default 0 not null,
  list_count int default 0 not null,
  crit_count int default 0 not null,

  root_link varchar,
  root_name varchar,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

-- no need to be unique since `id` is already unique for each ysbook
CREATE INDEX ysbook_unique_idx ON ysbooks (author, btitle);
CREATE INDEX ysbook_cvbook_idx ON ysbooks (cvbook_id);

-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
