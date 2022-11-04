CREATE TABLE IF NOT EXISTS dicts (
  id integer PRIMARY KEY,
  name varchar NOT NULL,
  type integer NOT NULL,
  label varchar NOT NULL DEFAULT '', -- display name
  intro text NOT NULL DEFAULT '', -- dict introduction
  min_privi int NOT NULL DEFAULT 1,
  term_total int NOT NULL DEFAULT 0, -- term total mean all entries in dict
  term_count int NOT NULL DEFAULT 0, -- term count mean all undeleted entries in dict
  last_mtime int NOT NULL DEFAULT 0 -- latest time a term get added/updated
);

CREATE UNIQUE INDEX IF NOT EXISTS dicts_name_idx ON dicts (name);

CREATE INDEX IF NOT EXISTS dicts_time_idx ON dicts (last_mtime);

-- CREATE INDEX IF NOT EXISTS dicts_size_idx ON dicts (term_total);
-- CREATE INDEX IF NOT EXISTS dicts_type_idx ON dicts (type);
