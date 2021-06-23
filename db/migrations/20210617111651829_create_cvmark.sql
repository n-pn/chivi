-- +micrate Up
CREATE TABLE cvmarks (
  id bigserial PRIMARY KEY,

  cvuser_id bigint not null,
  cvbook_id bigint not null,

  blist varchar default '' not null,

  last_view varchar[],
  viewed_at bigint default 0 not null,

  chap_mark varchar[],
  marked_at bigint default 0 not null,

  fav_zseed int,

  privi int default 0 not null,
  prefs jsonb default '{}'::jsonb NOT NULL,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX cvmark_unique_idx ON cvmarks (cvbook_id, cvuser_id);
CREATE INDEX cvmark_cvuser_idx ON cvmarks (cvuser_id, blist);

-- +micrate Down
DROP TABLE IF EXISTS cvmarks;
