-- +micrate Up
CREATE TABLE rdmemos(
  vu_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  sname varchar NOT NULL,
  sn_id int NOT NULL,
  --
  vname varchar NOT NULL DEFAULT '', -- book/project name
  rpath varchar NOT NULL DEFAULT '', -- path to chap list
  --
  rd_track smallint NOT NULL DEFAULT 0, -- reommendation/liking
  rd_state smallint NOT NULL DEFAULT 0, -- reading status
  rd_stars smallint NOT NULL DEFAULT 0, -- book rating
  --
  view_count int NOT NULL DEFAULT 0, -- only when reading chapters
  coin_spent int NOT NULL DEFAULT 0, -- when unlock chapters
  --
  prefs jsonb NOT NULL DEFAULT '{}', -- custom prerefernces
  atime bigint NOT NULL DEFAULT 0, -- last view time
  rtime bigint NOT NULL DEFAULT 0, -- last read time
  --
  PRIMARY KEY (vu_id, sname, sn_id)
);

CREATE INDEX rdmemo_rstate_idx ON rdmemos(sname, sn_id, rd_state);

CREATE INDEX rdmemo_viewed_idx ON rdmemos(vu_id, rtime);

-- +micrate Down
DROP TABLE IF EXISTS rdmemos;
