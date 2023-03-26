-- +micrate Up
CREATE TABLE cvusers (
  id serial PRIMARY KEY,
  uname citext UNIQUE NOT NULL,
  email citext UNIQUE NOT NULL,
  cpass text NOT NULL,
  --
  vcoin double8 DEFAULT 0 NOT NULL,
  vcoin_total int DEFAULT 0 NOT NULL,
  --
  karma_avail int DEFAULT 0 NOT NULL,
  karma_total int DEFAULT 0 NOT NULL,
  --
  privi int DEFAULT 0 NOT NULL,
  privi_1_until bigint NOT NULL DEFAULT '0',
  privi_2_until bigint NOT NULL DEFAULT '0',
  privi_3_until bigint NOT NULL DEFAULT '0',
  --
  wtheme text NOT NULL DEFAULT 'light',
  --
  last_loggedin_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reply_checked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notif_checked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  --
  pwtemp text NOT NULL DEFAULT '',
  pwtemp_until bigint NOT NULL DEFAULT 0,
  --
  created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX cvuser_privi_idx ON cvusers (privi);

-- +micrate Down
DROP TABLE IF EXISTS cvusers;
