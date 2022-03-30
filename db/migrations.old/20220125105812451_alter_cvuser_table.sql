-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE cvusers RENAME COLUMN karma TO vcoin_total;
ALTER TABLE cvusers ADD COLUMN IF NOT EXISTS vcoin_avail int not null default '0';
ALTER TABLE cvusers DROP COLUMN privi_until;

ALTER TABLE cvusers ADD COLUMN privi_1_until bigint not null default '0';
ALTER TABLE cvusers ADD COLUMN privi_2_until bigint not null default '0';
ALTER TABLE cvusers ADD COLUMN privi_3_until bigint not null default '0';

ALTER TABLE cvusers ADD COLUMN last_loggedin_at timestamptz not null default CURRENT_TIMESTAMP;
ALTER TABLE cvusers ADD COLUMN reply_checked_at timestamptz not null default CURRENT_TIMESTAMP;
ALTER TABLE cvusers ADD COLUMN notif_checked_at timestamptz not null default CURRENT_TIMESTAMP;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE cvusers RENAME COLUMN vcoin_total TO karma;
ALTER TABLE cvusers DROP COLUMN IF EXISTS vcoin_avail;
ALTER TABLE cvusers ADD COLUMN privi_until time;

ALTER TABLE cvusers DROP COLUMN IF EXISTS privi_1_until;
ALTER TABLE cvusers DROP COLUMN IF EXISTS privi_2_until;
ALTER TABLE cvusers DROP COLUMN IF EXISTS privi_3_until;

ALTER TABLE cvusers DROP COLUMN IF EXISTS last_loggedin_at;
ALTER TABLE cvusers DROP COLUMN IF EXISTS reply_checked_at;
ALTER TABLE cvusers DROP COLUMN IF EXISTS notif_checked_at;
