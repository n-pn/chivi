-- +micrate Up
CREATE TABLE viusers(
  id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  uname citext UNIQUE NOT NULL,
  email citext UNIQUE NOT NULL,
  cpass text NOT NULL,
  --
  vcoin double8 DEFAULT 0 NOT NULL,
  --
  point int DEFAULT 0 NOT NULL,
  karma int DEFAULT 0 NOT NULL,
  --
  privi int DEFAULT 0 NOT NULL,
  privi_until bigint[] NOT NULL DEFAULT '{0, 0, 0}' ::bigint[],
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

CREATE INDEX viuser_privi_idx ON viusers(privi);

-- +micrate Down
DROP TABLE IF EXISTS viusers;
