-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE upstems(
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  -- ordering and filtering
  sname varchar NOT NULL DEFAULT '',
  -- linking
  owner integer NOT NULL REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  wn_id integer REFERENCES wninfos(id) ON UPDATE CASCADE ON DELETE SET NULL,
  guard smallint NOT NULL DEFAULT 0,
  -- heading
  zname citext NOT NULL DEFAULT '',
  vname citext NOT NULL DEFAULT '',
  -- introduction
  zintro text NOT NULL DEFAULT '',
  vintro text NOT NULL DEFAULT '',
  --
  labels text[] NOT NULL DEFAULT '{}',
  -- control
  mtime bigint NOT NULL DEFAULT 0,
  atime bigint NOT NULL DEFAULT 0,
  --
  chap_count integer NOT NULL DEFAULT 0,
  word_count integer NOT NULL DEFAULT 0,
  -- timestamps
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX upstems_zname_idx ON upstems USING gin(zname gin_trgm_ops) WITH (fastupdate = OFF);

CREATE INDEX upstems_vname_idx ON upstems USING gin(vname gin_trgm_ops) WITH (fastupdate = OFF);

CREATE INDEX upstems_labels_idx ON upstems USING gin(labels);

CREATE INDEX upstems_viuser_idx ON upstems(viuser_id);

CREATE INDEX upstems_wninfo_idx ON upstems(wninfo_id);

CREATE INDEX upstems_sorted_idx ON upstems(mtime);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE upstems;
