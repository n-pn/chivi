-- +micrate Up
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "citext";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "intarray";

-- +micrate StatementBegin
create or replace function scrub_name(varchar)
RETURNS text AS $$
  select lower(unaccent($1))
$$ LANGUAGE sql IMMUTABLE;
-- +micrate StatementEnd

-- +micrate StatementBegin
create or replace function scrub_name(varchar, varchar)
RETURNS text AS $$
  SELECT lower(unaccent($1)) || chr(9) || lower(unaccent($2))
$$ LANGUAGE sql IMMUTABLE;
-- +micrate StatementEnd

-- +micrate Down

drop function if exists scrub_name(varchar, varchar);
drop function if exists scrub_name(varchar, varchar, varchar);

DROP EXTENSION IF EXISTS "unaccent";
DROP EXTENSION IF EXISTS "citext";
DROP EXTENSION IF EXISTS "pg_trgm";
DROP EXTENSION IF EXISTS "intarray";
