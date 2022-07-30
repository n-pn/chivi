-- +micrate Up
CREATE TABLE user_posts (
  id bigserial primary key,

  viuser_id int not null,
  cvpost_id bigint not null,

  liked boolean not null default false,

  atime bigint not null default 0,
  utime bigint not null default 0,

  last_rp_ii int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX user_post_unique_idx ON user_posts (cvpost_id, viuser_id);
CREATE INDEX user_post_cvuser_idx ON user_posts (viuser_id, liked);

-- +micrate Down
DROP TABLE IF EXISTS user_posts;
