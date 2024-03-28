-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE zvdefns(
  id int GENERATED ALWAYS AS IDENTITY,
  --
  dict varchar NOT NULL,
  zstr varchar NOT NULL,
  cpos varchar NOT NULL,
  --
  vstr varchar NOT NULL DEFAULT '',
  attr varchar NOT NULL DEFAULT '',
  rank smallint NOT NULL DEFAULT 1,
  --
  _user varchar NOT NULL DEFAULT '',
  _time integer NOT NULL DEFAULT 0,
  _lock smallint NOT NULL DEFAULT 0,
  --
  PRIMARY KEY (dict, zstr, cpos)
);

CREATE INDEX IF NOT EXISTS zvdefns_zstr_idx ON zvdefns(zstr);

CREATE INDEX IF NOT EXISTS zvdefns_vstr_idx ON zvdefns(vstr);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE zvdefns;
