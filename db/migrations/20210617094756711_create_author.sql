-- +micrate Up
CREATE TABLE authors (
  id serial PRIMARY KEY,

  zh_name varchar not null,
  vi_name varchar not null,

  zh_slug varchar not null,
  vi_slug varchar not null,

  sorting int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX author_zh_slug_index ON authors using GIST (zh_slug gist_trgm_ops);
CREATE INDEX author_vi_slug_index ON authors using GIST (vi_slug gist_trgm_ops);


-- +micrate Down
DROP TABLE IF EXISTS authors;
