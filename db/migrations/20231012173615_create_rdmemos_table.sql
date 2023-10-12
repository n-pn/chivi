-- +micrate Up
CREATE TABLE rdmemos(
  vu_id int NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  sname varchar NOT NULL,
  sn_id varchar NOT NULL,
  --
  vname varchar NOT NULL DEFAULT '', -- book/project name
  rpath varchar NOT NULL DEFAULT '', -- path to chap list
  --
  rstate smallint NOT NULL DEFAULT 0, -- reading status
  rating smallint NOT NULL DEFAULT 0, -- book rating
  recomm smallint NOT NULL DEFAULT 0, -- reommendation/liking
  --
  view_count int NOT NULL DEFAULT 0, -- only when reading chapters
  coin_spent int NOT NULL DEFAULT 0, -- when unlock chapters
  --
  last_ch_no int NOT NULL DEFAULT 0, -- last read chap
  last_cinfo jsonb NOT NULL DEFAULT '{}', -- metadata to display
  --
  mark_ch_no int NOT NULL DEFAULT 0, -- reading chapter in sequential
  mark_cinfo jsonb NOT NULL DEFAULT '{}', -- metadata to display
  --
  prefs jsonb NOT NULL DEFAULT '{}', -- custom prerefernces
  atime bigint NOT NULL DEFAULT 0, -- last view time
  rtime bigint NOT NULL DEFAULT 0, -- last read time
  --
  PRIMARY KEY (vu_id, sname, sn_id)
);

CREATE INDEX rdmemo_rstate_idx ON rdmemos(sname, sn_id, rstate);

CREATE INDEX rdmemo_viewed_idx ON rdmemos(vu_id, rtime);

-- +micrate Down
DROP TABLE IF EXISTS rdmemos;
