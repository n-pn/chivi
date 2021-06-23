-- +micrate Up
CREATE TABLE cvbooks (
  id bigserial PRIMARY KEY,

  ysbook_id bigint,

  author_id bigint,
  btitle_id bigint,

  bgenre_ids int[], -- not real database table ids
  zhseed_ids int[], -- not real database table ids

  bhash varchar NOT NULL UNIQUE,
  bslug varchar NOT NULL UNIQUE,

  author varchar[] NOT NULL,
  btitle varchar[] NOT NULL,

  bcover varchar default 'blank.png' not null,
  bintro varchar default '' not null,

  status int default 0 not null,
  shield int default 0 not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  weight int default 0 not null,
  voters int default 0 not null,
  rating int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX cvbook_ysbook_id_idx ON cvbooks (ysbook_id);

CREATE INDEX cvbook_author_id_idx ON cvbooks (author_id);
CREATE INDEX cvbook_btitle_id_idx ON cvbooks (btitle_id);

CREATE INDEX cvbook_bgenre_ids_idx ON cvbooks using GIN (bgenre_ids);
CREATE INDEX cvbook_zhseed_ids_idx ON cvbooks using GIN (zhseed_ids);

CREATE INDEX cvbook_bumped_idx ON cvbooks (bumped, shield);
CREATE INDEX cvbook_mftime_idx ON cvbooks (mftime, shield);

CREATE INDEX cvbook_weight_idx ON cvbooks (weight);
CREATE INDEX cvbook_rating_idx ON cvbooks (rating);
CREATE INDEX cvbook_voters_idx ON cvbooks (voters);


-- +micrate Down
DROP TABLE IF EXISTS nvinfos;
