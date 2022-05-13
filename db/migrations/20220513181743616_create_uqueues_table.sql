-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE uqueues (
  id bigserial primary key,
  kind int not null default 0,

  cvuser_id bigint not null,

  status int not null default 0,
  detail jsonb not null default '{}',

  mailing int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX uqueue_cvuser_idx ON uqueues (cvuser_id, status);
CREATE INDEX uqueue_notice_idx ON uqueues (kind, mailing);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS uqueues;
