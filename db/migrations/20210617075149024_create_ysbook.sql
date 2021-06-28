-- +micrate Up
CREATE TABLE ysbooks (
  id bigserial PRIMARY KEY,

  cvbook_id bigint default 0 not null,

  author varchar not null,
  ztitle varchar not null,

  genres varchar[] default '{}' not null,
  bcover varchar(512) default '' not null,
  bintro text default '' not null,

  status int default 0 not null,
  shield int default 0 not null ,

  voters int default 0 not null,
  rating int default 0 not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  word_count int default 0 not null,
  list_count int default 0 not null,
  crit_count int default 0 not null,

  root_link varchar default '' not null,
  root_name varchar default '' not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX ysbook_unique_idx ON ysbooks (author, ztitle);
CREATE INDEX ysbook_cvbook_idx ON ysbooks (cvbook_id);
CREATE INDEX ysbook_bumped_idx ON ysbooks (bumped);


-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
