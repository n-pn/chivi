-- +micrate Up
CREATE TABLE nvinfos (
  id serial PRIMARY KEY,

  author_id int,
  btitle_id int,

  bgenre_ids int[],
  nvseed_ids int[],

  bhash varchar NOT NULL UNIQUE,
  bslug varchar NOT NULL UNIQUE,

  author varchar[] NOT NULL,
  btitle varchar[] NOT NULL,

  bgenres varchar[],
  nvseeds varchar[],

  bcover varchar default 'blank.png' not null,
  bintro varchar default '' not null,

  status int default 0 not null,
  shield int default 0 not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  weight int default 0 not null,
  voters int default 0 not null,
  rating int default 0 not null,

  vi_voters int default 0 not null,
  vi_rating int default 0 not null,

  ys_voters int default 0 not null,
  ys_rating int default 0 not null,

  ysbook_id int,
  ys_mftime bigint,

  orig_link varchar,
  orig_name varchar,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX nvinfo_author_id_idx ON nvinfos (author_id);
CREATE INDEX nvinfo_btitle_id_idx ON nvinfos (btitle_id);

CREATE INDEX nvinfo_bgenre_ids_idx ON nvinfos using GIN (bgenre_ids gin__int_ops);
CREATE INDEX nvinfo_nvseed_ids_idx ON nvinfos using GIN (nvseed_ids gin__int_ops);

CREATE INDEX nvinfo_bumped_idx ON nvinfos (bumped, shield);
CREATE INDEX nvinfo_mftime_idx ON nvinfos (mftime, shield);

CREATE INDEX nvinfo_weight_idx ON nvinfos (weight);
CREATE INDEX nvinfo_rating_idx ON nvinfos (rating);
CREATE INDEX nvinfo_voters_idx ON nvinfos (voters);

CREATE INDEX nvinfo_ysbook_id_idx ON nvinfos (ysbook_id);

-- +micrate Down
DROP TABLE IF EXISTS nvinfos;
