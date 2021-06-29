-- +micrate Up
CREATE TABLE cvbooks (
  id bigserial primary key,

  author_id bigint not null default 0,
  bgenre_ids int[] not null default '{0}', -- not real database table ids
  zhseed_ids int[] not null default '{0}', -- not real database table ids

  bhash text unique not null,
  bslug text unique not null,

  ztitle text not null,
  htitle text not null default '',
  vtitle text not null default '',

  ztitle_ts text not null default '',
  htitle_ts text not null default '',
  vtitle_ts text not null default '',

  bcover text not null default '',
  bintro text not null default '',

  status int not null default 0,
  shield int not null default 0,

  bumped bigint not null default 0,
  mftime bigint not null default 0,

  weight int not null default 0,
  voters int not null default 0,
  rating int not null default 0,

  cv_voters int not null default 0,
  cv_rating int not null default 0,
  cv_clicks int not null default 0,

  chap_count int not null default 0,
  list_count int not null default 0,
  crit_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
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
