-- +micrate Up
CREATE EXTENSION IF NOT EXISTS "citext";

CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE EXTENSION IF NOT EXISTS "intarray";

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- +micrate StatementBegin
CREATE OR REPLACE FUNCTION scrub_name(varchar)
  RETURNS text
  AS $$
  SELECT
    lower(unaccent($1))
$$
LANGUAGE sql
IMMUTABLE;

-- +micrate StatementEnd
-- +micrate StatementBegin
CREATE OR REPLACE FUNCTION scrub_name(varchar, varchar)
  RETURNS text
  AS $$
  SELECT
    lower(unaccent($1)) || chr(9) || lower(unaccent($2))
$$
LANGUAGE sql
IMMUTABLE;

-- +micrate StatementEnd
-- +micrate Down
DROP FUNCTION IF EXISTS scrub_name(varchar, varchar);

DROP FUNCTION IF EXISTS scrub_name(varchar, varchar, varchar);

DROP EXTENSION IF EXISTS "citext";

DROP EXTENSION IF EXISTS "pg_trgm";

DROP EXTENSION IF EXISTS "intarray";

DROP EXTENSION IF EXISTS "unaccent";
