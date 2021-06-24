-- +micrate Up
CREATE TABLE btitles (
  id bigserial PRIMARY KEY,

  author_id bigint,
  bgenre_ids int[] default '{0}' not null, -- not real database table ids
  zhseed_ids int[] default '{0}' not null, -- not real database table ids

  bhash varchar NOT NULL UNIQUE,
  bslug varchar NOT NULL UNIQUE,

  ztitle varchar not null,
  htitle varchar not null,
  vtitle varchar not null,

  ztitle_ts varchar not null,
  htitle_ts varchar not null,
  vtitle_ts varchar not null,

  bcover varchar default '' not null,
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

CREATE INDEX btitle_author_idx ON btitles (author_id);
CREATE INDEX btitle_bgenre_idx ON btitles using GIN (bgenre_ids);
CREATE INDEX btitle_zhseed_idx ON btitles using GIN (zhseed_ids);

CREATE INDEX btitle_ztitle_idx ON btitles using GIN (ztitle_ts gin_trgm_ops);
CREATE INDEX btitle_htitle_idx ON btitles using GIN (htitle_ts gin_trgm_ops);
CREATE INDEX btitle_vtitle_idx ON btitles using GIN (vtitle_ts gin_trgm_ops);

CREATE INDEX btitle_bumped_idx ON btitles (bumped);
CREATE INDEX btitle_mftime_idx ON btitles (mftime);

CREATE INDEX btitle_weight_idx ON btitles (weight);
CREATE INDEX btitle_rating_idx ON btitles (rating);
CREATE INDEX btitle_voters_idx ON btitles (voters);


-- +micrate Down
DROP TABLE IF EXISTS btitles;
