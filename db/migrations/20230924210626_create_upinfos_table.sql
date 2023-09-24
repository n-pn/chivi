-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE upinfos(
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  -- linking
  viuser_id integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  wninfo_id integer REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE SET NULL,
  -- heading
  zname citext NOT NULL DEFAULT '',
  vname citext NOT NULL DEFAULT '',
  uslug varchar NOT NULL default '',
  -- introduction
  vintro text NOT NULL DEFAULT '',
  labels citext[] NOT NULL DEFAULT '{}',
  -- ordering and filtering
  mtime bigint not null default 0,
  guard smallint NOT NULL DEFAULT 0,
  -- stats
  chap_count integer NOT NULL DEFAULT 0,
  word_count integer NOT NULL DEFAULT 0,
  -- timestamps
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX upinfos_zname_idx ON upinfos USING gin(zname gin_trgm_ops) WITH (fastupdate = off);
CREATE INDEX upinfos_vname_idx ON upinfos USING gin(vname gin_trgm_ops) WITH (fastupdate = off);

CREATE INDEX upinfos_labels_idx ON upinfos USING gin(labels);

CREATE INDEX upinfos_viuser_idx ON upinfos(viuser_id);
CREATE INDEX upinfos_wninfo_idx ON upinfos(wninfo_id);

CREATE INDEX upinfos_sorted_idx ON upinfos(mtime);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE upinfos;
