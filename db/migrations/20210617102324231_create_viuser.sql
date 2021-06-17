-- +micrate Up
CREATE TABLE "viusers" (
  id serial PRIMARY KEY,

  uname citext NOT NULL UNIQUE,
  email citext NOT NULL UNIQUE,
  cpass varchar NOT NULL,

  privi int default 0 NOT NULL,
  karma int default 0 NOT NULL,

  prefs jsonb default '{}'::jsonb NOT NULL,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);


-- +micrate Down
DROP TABLE IF EXISTS "viusers";
