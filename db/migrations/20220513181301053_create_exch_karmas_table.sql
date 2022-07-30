-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE exch_karmas (
  id bigserial primary key,
  kind int not null default 0,

  receiver_id bigint not null,
  sender_id bigint not null default 0,

  amount int not null default 0,
  reason text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX exch_karma_receiver_idx ON exch_karmas (receiver_id, kind);
CREATE INDEX exch_karma_sender_idx ON exch_karmas (kind, sender_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS exch_karmas;
