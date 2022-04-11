-- +micrate Up
CREATE TABLE user_repls (
  id bigserial primary key,

  cvuser_id bigint not null,
  cvrepl_id bigint not null,

  liked boolean not null default false,

  atime bigint not null default 0,
  utime bigint not null default 0,

  last_rp_ii int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX user_repl_unique_idx ON user_repls (cvrepl_id, cvuser_id);
CREATE INDEX user_repl_cvuser_idx ON user_repls (cvuser_id, liked);

-- +micrate Down
DROP TABLE IF EXISTS user_repls;
