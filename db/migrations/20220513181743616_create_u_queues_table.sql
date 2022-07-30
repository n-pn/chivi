-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE u_queues (
  id bigserial primary key,
  kind int not null default 0,

  viuser_id int not null,

  status int not null default 0,
  detail jsonb not null default '{}',

  mailing int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX uqueue_cvuser_idx ON u_queues (viuser_id, status);
CREATE INDEX uqueue_notice_idx ON u_queues (kind, mailing);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS u_queues;
