-- +micrate Up
CREATE TABLE cvbooks (
  id bigserial PRIMARY KEY,

  author varchar default '' not null,
  vtitle varchar default '' not null,

  genres varchar[] default '{}' not null,
  bcover varchar default '' not null,
  bintro text default '' not null,

  status int default 0 not null,
  shield int default 0 not null,

  voters int default 0 not null,
  rating int default 0 not null,

  bumped bigint default 0 not null,
  mftime bigint default 0 not null,

  list_count int default 0 not null,
  crit_count int default 0 not null,
  chap_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX cvbook_bumped_idx ON cvbooks (bumped);

-- +micrate Down
DROP TABLE IF EXISTS cvbooks;
