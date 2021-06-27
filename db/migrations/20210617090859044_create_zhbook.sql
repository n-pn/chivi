-- +micrate Up
CREATE TABLE zhbooks (
  id bigserial PRIMARY KEY,

  btitle_id bigint default 0 not null,

  zseed int default 0 not null,
  znvid int default 0 not null,

  author varchar default '' not null,
  ztitle varchar default '' not null,

  genres varchar[] default '{}' not null,
  bcover varchar default '' not null,
  bintro text default '' not null,

  status int default 0 not null,
  shield int default 0 not null ,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  chap_count int default 0 not null,
  last_zchid int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX zhbook_btitle_idx ON zhbooks (btitle_id);
CREATE INDEX zhbook_unique_idx ON zhbooks (zseed, znvid);
CREATE INDEX zhbook_nvname_idx ON zhbooks (author, ztitle);
CREATE INDEX zhbook_bumped_idx ON zhbooks (bumped);


-- +micrate Down
DROP TABLE IF EXISTS zhbooks;
