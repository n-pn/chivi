-- +micrate Up
CREATE TABLE cvbooks (
  id bigserial PRIMARY KEY,

  author_id bigint default 0 not null,
  bgenre_ids int[] default '{0}' not null, -- not real database table ids
  zhseed_ids int[] default '{0}' not null, -- not real database table ids

  bhash varchar NOT NULL UNIQUE,
  bslug varchar NOT NULL UNIQUE,

  ztitle varchar not null,
  htitle varchar default '' not null,
  vtitle varchar default '' not null,

  ztitle_ts varchar default '' not null,
  htitle_ts varchar default '' not null,
  vtitle_ts varchar default '' not null,

  bcover varchar default '' not null,
  bintro varchar default '' not null,

  status int default 0 not null,
  shield int default 0 not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  weight int default 0 not null,
  voters int default 0 not null,
  rating int default 0 not null,

  cv_voters int default 0 not null,
  cv_rating int default 0 not null,
  cv_clicks int default 0 not null,

  chap_count int default 0 not null,
  list_count int default 0 not null,
  crit_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX cvbook_unique_idx ON cvbooks (author_id, ztitle);

CREATE INDEX cvbook_bgenre_idx ON cvbooks using GIN (bgenre_ids);
CREATE INDEX cvbook_zhseed_idx ON cvbooks using GIN (zhseed_ids);

CREATE INDEX cvbook_ztitle_idx ON cvbooks using GIN (ztitle_ts gin_trgm_ops);
CREATE INDEX cvbook_htitle_idx ON cvbooks using GIN (htitle_ts gin_trgm_ops);
CREATE INDEX cvbook_vtitle_idx ON cvbooks using GIN (vtitle_ts gin_trgm_ops);

CREATE INDEX cvbook_bumped_idx ON cvbooks (bumped);
CREATE INDEX cvbook_mftime_idx ON cvbooks (mftime);

CREATE INDEX cvbook_weight_idx ON cvbooks (weight);
CREATE INDEX cvbook_rating_idx ON cvbooks (rating);
CREATE INDEX cvbook_voters_idx ON cvbooks (voters);


-- +micrate Down
DROP TABLE IF EXISTS cvbooks;
