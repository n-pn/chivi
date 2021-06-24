-- +micrate Up
CREATE TABLE ubviews (
  id bigserial PRIMARY KEY,

  btitle_id bigint not null,
  cvuser_id bigint not null,

  zseed int default 0 not null,
  znvid int default 0 not null,

  zchid int default 0 not null,
  chidx int default 0 not null,

  bumped bigint default 0 not null,

  ch_title varchar default '' not null,
  ch_label varchar default '' not null,
  ch_uslug varchar default '' not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX ubview_unique_idx ON ubviews (btitle_id, cvuser_id);
CREATE INDEX ubview_cvuser_idx ON ubviews (cvuser_id, bumped);


-- +micrate Down
DROP TABLE IF EXISTS ubviews;
