pragma journal_mode = WAL;

pragma synchronous = normal;

CREATE TABLE specs(
  id integer PRIMARY KEY,
  --
  udict varchar NOT NULL DEFAULT '',
  ud_id integer NOT NULL DEFAULT 0,
  --
  zorig varchar DEFAULT '',
  ztext text NOT NULL,
  --
  zfrom integer NOT NULL DEFAULT 0,
  zupto integer NOT NULL DEFAULT 0,
  --
  expect text DEFAULT '',
  detail text DEFAULT '',
  --
  tags varchar DEFAULT '',
  prio integer DEFAULT 0,
  --
  edit_count integer DEFAULT 0,
  repl_count integer DEFAULT 0,
  --
  _flag integer DEFAULT 0,
  --
  uname varchar NOT NULL DEFAULT '',
  mtime integer NOT NULL DEFAULT 0
);

CREATE INDEX specs_tags_idx ON specs(tags);

CREATE INDEX specs_prio_idx ON specs(prio);

CREATE INDEX specs_user_idx ON specs(uname);
