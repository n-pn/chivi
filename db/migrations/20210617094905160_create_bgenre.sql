-- +micrate Up
CREATE TABLE bgenres (
  id serial PRIMARY KEY,

  vi_name varchar NOT NULL UNIQUE,
  vi_slug varchar NOT NULL UNIQUE,

  zh_names varchar[] default '{}' NOT NULL,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);


-- +micrate Down
DROP TABLE IF EXISTS bgenres;
