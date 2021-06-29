-- +micrate Up
CREATE TABLE ubviews (
  id bigserial primary key,

  cvbook_id bigint not null,
  cvuser_id bigint not null,

  zseed int not null default 0,
  znvid int not null default 0,

  zchid int not null default 0,
  chidx int not null default 0,

  bumped bigint not null default 0,

  ch_title text not null default '',
  ch_label text not null default '',
  ch_uslug text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ubview_unique_idx ON ubviews (cvbook_id, cvuser_id);
CREATE INDEX ubview_cvuser_idx ON ubviews (cvuser_id, bumped);


-- +micrate Down
DROP TABLE IF EXISTS ubviews;
