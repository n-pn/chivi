-- +micrate Up
CREATE TABLE memoirs(
  id serial UNIQUE,
  --
  viuser_id int NOT NULL,
  target_type int NOT NULL,
  target_id int NOT NULL,
  --
  liked_at bigint NOT NULL DEFAULT 0,
  track_at bigint NOT NULL DEFAULT 0,
  --
  viewed_at bigint NOT NULL DEFAULT 0,
  tagged_at bigint NOT NULL DEFAULT 0,
  --
  extra text,
  PRIMARY KEY (viuser_id, target_type, target_id)
);

CREATE INDEX memoirs_list_idx ON memoirs(target_id, target_type);

-- +micrate Down
DROP TABLE IF EXISTS memoirs;
