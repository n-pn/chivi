-- +micrate Up
CREATE TABLE ysusers (
  id bigserial PRIMARY KEY,

  zh_name varchar not null,
  vi_name varchar not null,

  like_count int default 0 not null,
  list_count int default 0 not null,
  crit_count int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX ysuser_zh_name_idx ON ysbooks (zh_name);


-- +micrate Down
DROP TABLE IF EXISTS ysusers;
