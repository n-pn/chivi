-- +micrate Up
CREATE TABLE zhbooks (
  id bigserial PRIMARY KEY,

  cvbook_id bigint,

  zseed int not null,
  znvid int not null,

  author varchar not null,
  btitle varchar not null,

  genres varchar[] default '{}' not null,
  bintro text,
  bcover varchar(512),

  status int default 0 not null,
  shield int default 0 not null ,

  voters int default 0 not null,
  rating int default 0 not null,

  mftime bigint default 0 not null,
  bumped bigint default 0 not null,

  chap_count int default 0 not null,
  last_schid int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX zhbook_cvbook_idx ON zhbook (cvbook_id);
CREATE INDEX zhbook_unique_idx ON zhbook (zseed, znvid);
CREATE INDEX zhbook_nvname_idx ON zhbook (author, btitle);

-- +micrate Down
DROP TABLE IF EXISTS zhbooks;
