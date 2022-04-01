-- +micrate Up
CREATE TABLE cvusers (
  id bigserial primary key,

  uname citext unique not null,
  email citext unique not null,
  cpass text NOT NULL,

  vcoin_avail int default 0 NOT NULL,
  vcoin_total int default 0 NOT NULL,

  privi int default 0 NOT NULL,
  privi_1_until bigint not null default '0',
  privi_2_until bigint not null default '0',
  privi_3_until bigint not null default '0',

  wtheme text not null default 'light',

  last_loggedin_at timestamptz not null default CURRENT_TIMESTAMP,
  reply_checked_at timestamptz not null default CURRENT_TIMESTAMP,
  notif_checked_at timestamptz not null default CURRENT_TIMESTAMP,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX cvuser_privi_idx ON cvusers (privi);


-- +micrate Down
DROP TABLE IF EXISTS cvusers;
