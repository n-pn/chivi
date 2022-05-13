-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE uvcoins (
  id bigserial primary key,
  kind int not null default 0,

  sender_id bigint not null,
  receiver_id bigint not null default 0,

  amount int not null default 0,
  reason text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX uvcoin_sender_idx ON uvcoins (sender_id, kind);
CREATE INDEX uvcoin_receiver_idx ON uvcoins (kind, receiver_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS uvcoins;
