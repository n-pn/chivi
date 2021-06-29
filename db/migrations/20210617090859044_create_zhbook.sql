-- +micrate Up
CREATE TABLE zhbooks (
  id bigserial primary key,

  cvbook_id bigint not null default 0,

  zseed int not null default 0,
  znvid int not null default 0,

  status int not null default 0,
  shield int not null  default 0,

  bumped bigint not null default 0,
  mftime bigint not null default 0,

  chap_count int not null default 0,
  last_zchid int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX zhbook_cvbook_idx ON zhbooks (cvbook_id);
CREATE INDEX zhbook_unique_idx ON zhbooks (zseed, znvid);
CREATE INDEX zhbook_nvname_idx ON zhbooks (author, ztitle);
CREATE INDEX zhbook_bumped_idx ON zhbooks (bumped);


-- +micrate Down
DROP TABLE IF EXISTS zhbooks;
