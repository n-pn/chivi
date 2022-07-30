-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE donates (
  id bigserial primary key,

  viuser_id int not null,

  amount int not null default 0,
  medium text not null default '',

  ctime bigint not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX donate_cvuser_idx ON donates (viuser_id);
CREATE INDEX donate_ctime_idx ON donates (ctime, medium);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS donates;
