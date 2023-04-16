-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE muheads(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  urn citext NOT NULL UNIQUE,
  --
  dboard_id int NOT NULL DEFAULT 0,
  viuser_id int NOT NULL DEFAULT 0 REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE CASCADE,
  --
  _type text NOT NULL DEFAULT '',
  _name text NOT NULL DEFAULT '',
  _link text NOT NULL DEFAULT '',
  _desc text NOT NULL DEFAULT '',
  --
  repl_count int NOT NULL DEFAULT 0, -- like count
  member_ids int[] NOT NULL DEFAULT '{}', -- people participated in this thread
  --
  last_seen_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_repl_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  deleted_at timestamptz,
  deleted_by int REFERENCES viusers(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX muheads_viuser_idx ON muheads(viuser_id);

CREATE INDEX muheads_member_idx ON muheads USING GIN(member_ids);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS muheads;
