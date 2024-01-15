CREATE TABLE edits(
  id integer PRIMARY KEY,
  --
  spec_id integer NOT NULL,
  edit_no integer NOT NULL DEFAULT 0,
  --
  zfrom integer DEFAULT 0,
  zupto integer DEFAULT 0,
  --
  expect text DEFAULT '',
  detail text DEFAULT '',
  --
  tags varchar DEFAULT '',
  prio integer DEFAULT 0,
  --
  uname varchar NOT NULL DEFAULT '',
  mtime integer NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX edits_uniq_idx ON edits(spec_id, edit_no);

CREATE INDEX edits_user_idex ON edits(uname);
