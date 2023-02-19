CREATE TABLE IF NOT EXISTS books (
  id integer PRIMARY KEY,
  cv_id integer NOT NULL DEFAULT 0,
  --
  btitle varchar NOT NULL DEFAULT '',
  author varchar NOT NULL DEFAULT '',
  --
  intro text NOT NULL DEFAULT '',
  genre varchar NOT NULL DEFAULT '',
  btags varchar NOT NULL DEFAULT '',
  --
  cover text NOT NULL DEFAULT '',
  origs text NOT NULL DEFAULT '',
  --
  voters integer NOT NULL DEFAULT 0,
  rating integer NOT NULL DEFAULT 0,
  --
  shield integer NOT NULL DEFAULT 0,
  --
  status integer NOT NULL DEFAULT 0,
  udtime bigint NOT NULL DEFAULT 0, -- origign book updated at
  --
  word_total integer NOT NULL DEFAULT 0,
  crit_total integer NOT NULL DEFAULT 0,
  list_total integer NOT NULL DEFAULT 0,
  --
  crit_count integer NOT NULL DEFAULT 0,
  list_count integer NOT NULL DEFAULT 0,
  --
  rprio integer NOT NULL DEFAULT 0, -- recrawl priority
  rtime bigint NOT NULL DEFAULT 0, -- recrawled at
  --
  stime bigint NOT NULL DEFAULT 0 -- sycn time
);

CREATE INDEX IF NOT EXISTS cvid_idx ON books (cv_id);

CREATE INDEX IF NOT EXISTS name_idx ON books (author, btitle);
