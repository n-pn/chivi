-- +micrate Up
CREATE TABLE cvusers (
  id bigserial primary key,

  uname citext unique not null,
  email citext unique not null,
  cpass text NOT NULL,

  karma int default 0 NOT NULL,

  privi int default 0 NOT NULL,
  privi_until timestamptz,

  prefs jsonb default '{}'::jsonb NOT NULL,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX cvuser_privi_idx ON cvusers (privi);


-- +micrate Down
DROP TABLE IF EXISTS cvusers;
