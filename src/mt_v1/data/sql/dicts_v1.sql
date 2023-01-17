pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS dicts (
  id integer PRIMARY KEY,
  --
  dname varchar NOT NULL,
  --
  label varchar NOT NULL DEFAULT '', -- display name
  brief text NOT NULL DEFAULT '', -- dict brief introduction
  --
  privi integer NOT NULL DEFAULT 1, -- minimal priviledge required
  dtype integer NOT NULL DEFAULT 0, -- dict type, optional, can be extracted by dname
  --
  term_total integer NOT NULL DEFAULT 0, -- term total mean all entries in dict
  term_avail integer NOT NULL DEFAULT 0, -- all active terms in dicts
  --
  base_terms integer NOT NULL DEFAULT 0,
  temp_terms integer NOT NULL DEFAULT 0,
  user_terms integer NOT NULL DEFAULT 0,
  --
  users text NOT NULL DEFAULT '', -- all users contributed in this dicts seperated by `,`
  --
  mtime integer NOT NULL DEFAULT 0 -- latest time a term get added/updated
);

CREATE UNIQUE INDEX IF NOT EXISTS dicts_name_idx ON dicts (dname);

CREATE INDEX IF NOT EXISTS dicts_size_idx ON dicts (term_total);

CREATE INDEX IF NOT EXISTS dicts_time_idx ON dicts (mtime);
