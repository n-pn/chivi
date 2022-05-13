-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE cvusers ADD COLUMN karma_total int not null default 0;
ALTER TABLE cvusers ADD COLUMN karma_avail int not null default 0;

CREATE TABLE ukarmas (
  id bigserial primary key,
  kind int not null default 0,

  receiver_id bigint not null,
  sender_id bigint not null default 0,

  amount int not null default 0,
  reason text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX ukarma_receiver_idx ON ukarmas (receiver_id, kind);
CREATE INDEX ukarma_sender_idx ON ukarmas (kind, sender_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS ukarmas;

ALTER TABLE cvusers DROP COLUMN karma_total;
ALTER TABLE cvusers DROP COLUMN karma_avail;
