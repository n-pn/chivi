-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE rmstems(
  sname varchar NOT NULL,
  sn_id varchar NOT NULL,
  --
  rtype smallint not null default 1,
  rlink varchar NOT NULL DEFAULT '',
  rtime bigint NOT NULL DEFAULT 0,
  --
  btitle_zh varchar NOT NULL DEFAULT '',
  author_zh varchar NOT NULL DEFAULT '',
  btitle_vi varchar NOT NULL DEFAULT '',
  author_vi varchar NOT NULL DEFAULT '',
  --
  _btitle_ts_ varchar GENERATED ALWAYS AS (scrub_name(btitle_zh, btitle_vi)) STORED,
  _author_ts_ varchar GENERATED ALWAYS AS (scrub_name(author_zh, author_vi)) STORED,
  --
  cover_rm varchar NOT NULL DEFAULT '',
  cover_cv varchar NOT NULL DEFAULT '',
  intro_zh text NOT NULL DEFAULT '',
  intro_vi text NOT NULL DEFAULT '',
  genre_zh varchar NOT NULL DEFAULT '',
  genre_vi varchar NOT NULL DEFAULT '',
  --
  status_str varchar NOT NULL DEFAULT 0,
  status_int smallint NOT NULL DEFAULT 0,
  update_str varchar NOT NULL DEFAULT 0,
  update_int bigint NOT NULL DEFAULT 0,
  --
  chap_count int NOT NULL DEFAULT 0,
  chap_avail int NOT NULL DEFAULT 0,
  latest_cid varchar NOT NULL DEFAULT '',
  --
  wn_id int NOT NULL DEFAULT 0,
  stime bigint NOT NULL DEFAULT 0,
  _flag smallint NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (sname, sn_id)
);

CREATE INDEX rmstems_btitle_ts_idx ON rmstems USING GIN(_btitle_ts_ gin_trgm_ops);

CREATE INDEX rmstems_author_ts_idx ON rmstems USING GIN(_author_ts_ gin_trgm_ops);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE rmstems;
