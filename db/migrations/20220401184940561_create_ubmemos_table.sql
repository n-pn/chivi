-- +micrate Up
CREATE TABLE ubmemos (
  id bigserial primary key,

  cvuser_id bigint not null,
  nvinfo_id bigint not null,

  status int not null default 0,
  locked boolean not null default false,

  atime bigint not null default 0,
  utime bigint not null default 0,

  lr_sname text not null default '',
  lr_zseed int not null default 0,

  lr_chidx int not null default 0,
  lr_cpart int not null default 0,

  lc_title text not null default '',
  lc_uslug text not null default '',

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ubmemo_unique_idx ON ubmemos (nvinfo_id, cvuser_id);
CREATE INDEX ubmemo_cvuser_idx ON ubmemos (status, cvuser_id);
CREATE INDEX ubmemo_viewed_idx ON ubmemos (cvuser_id, atime);

-- +micrate Down
DROP TABLE IF EXISTS ubmemos;
