-- +micrate Up
CREATE TABLE memoirs (
  id serial UNIQUE,
  --
  viuser_id int not null,
  target_type int not null,
  target_id int not null,
  --
  liked_at bigint not null default 0,
  track_at bigint not null default 0,
  --
  viewed_at bigint not null default 0,
  tagged_at bigint not null default 0,
  --
  extra text,
  primary key(viuser_id, target_type, target_id)
);

CREATE INDEX memoirs_list_idx ON memoirs (target_id, target_type);

-- +micrate Down
DROP TABLE IF EXISTS memoirs;
