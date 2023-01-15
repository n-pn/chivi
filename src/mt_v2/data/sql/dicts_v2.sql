pragma journal_mode = WAL;

CREATE TABLE IF NOT EXISTS dicts (
  id integer PRIMARY KEY,
  --
  dname varchar NOT NULL,
  --
  label varchar NOT NULL DEFAULT '', -- display name
  brief text NOT NULL DEFAULT '', -- dict brief introduction
  --
  privi int NOT NULL DEFAULT 1, -- minimal priviledge required
  dtype integer NOT NULL DEFAULT 0, -- dict type, optional, can be extracted by dname
  --
  term_total int NOT NULL DEFAULT 0, -- term total mean all entries in dict
  term_avail int NOT NULL DEFAULT 0, -- all active terms in dicts
  --
  base_terms int NOT NULL DEFAULT 0,
  temp_terms int NOT NULL DEFAULT 0,
  user_terms int NOT NULL DEFAULT 0,
  --
  users text NOT NULL DEFAULT '', -- all users contributed in this dicts seperated by `,`
  --
  mtime int NOT NULL DEFAULT 0 -- latest time a term get added/updated
);

CREATE UNIQUE INDEX IF NOT EXISTS dicts_name_idx ON dicts (dname);

CREATE INDEX IF NOT EXISTS dicts_size_idx ON dicts (term_total);

CREATE INDEX IF NOT EXISTS dicts_time_idx ON dicts (mtime);
