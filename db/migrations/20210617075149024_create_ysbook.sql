-- +micrate Up
CREATE TABLE ysbooks (
  id bigserial PRIMARY KEY,

  btitle_id bigint,

  author varchar not null,
  ztitle varchar not null,

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

CREATE INDEX ysbook_unique_idx ON ysbooks (author, ztitle);
CREATE INDEX ysbook_btitle_idx ON ysbooks (btitle_id);
CREATE INDEX ysbook_bumped_idx ON ysbooks (bumped);


-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
