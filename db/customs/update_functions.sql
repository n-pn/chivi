CREATE EXTENSION IF NOT EXISTS "citext";

CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE EXTENSION IF NOT EXISTS "intarray";

CREATE EXTENSION IF NOT EXISTS "unaccent";

CREATE OR REPLACE FUNCTION scrub_name(varchar)
  RETURNS text
  AS $$
  SELECT
    lower(unaccent($1::text))
$$
LANGUAGE sql
IMMUTABLE;

CREATE OR REPLACE FUNCTION scrub_name(varchar, varchar)
  RETURNS text
  AS $$
  SELECT
    lower(unaccent($1::text)) || chr(9) || lower(unaccent($2::text))
$$
LANGUAGE sql
IMMUTABLE;

CREATE OR REPLACE FUNCTION scrub_name(text)
  RETURNS text
  AS $$
  SELECT
    lower(unaccent($1))
$$
LANGUAGE sql
IMMUTABLE;

CREATE OR REPLACE FUNCTION scrub_name(text, text)
  RETURNS text
  AS $$
  SELECT
    lower(unaccent($1)) || chr(9) || lower(unaccent($2))
$$
LANGUAGE sql
IMMUTABLE;
