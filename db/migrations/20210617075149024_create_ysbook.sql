-- +micrate Up
CREATE TABLE ysbooks (
  id bigserial primary key,

  cvbook_id bigint not null default 0,

  author text not null,
  ztitle text not null,

  genres text[] not null default '{}',
  bcover text not null default '',
  bintro text not null default '',

  status int not null default 0,
  shield int not null default 0 ,

  voters int not null default 0,
  rating int not null default 0,

  bumped bigint not null default 0,
  mftime bigint not null default 0,

  word_count int not null default 0,
  list_count int not null default 0,
  crit_count int not null default 0,

  root_link text not null default '',
  root_name text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX ysbook_unique_idx ON ysbooks (author, ztitle);
CREATE INDEX ysbook_cvbook_idx ON ysbooks (cvbook_id);
CREATE INDEX ysbook_bumped_idx ON ysbooks (bumped);


-- +micrate Down
DROP TABLE IF EXISTS ysbooks;
