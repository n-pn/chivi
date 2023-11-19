-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE zvterms(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  --
  dict varchar NOT NULL,
  zstr varchar NOT NULL,
  cpos varchar NOT NULL DEFAULT 'X',
  --
  vstr varchar NOT NULL DEFAULT '',
  attr varchar NOT NULL DEFAULT '',
  lock smallint NOT NULL DEFAULT 1,
  --
  vu_id int REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE SET NULL,
  mtime integer NOT NULL DEFAULT 0,
  --
  _meta jsonb NOT NULL DEFAULT '{}',
  _flag smallint NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS zvterms_dict_idx ON zvterms(dict);

CREATE INDEX IF NOT EXISTS zvterms_zstr_idx ON zvterms(zstr);

CREATE INDEX IF NOT EXISTS zvterms_cpos_idx ON zvterms(cpos);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE zvterms;
