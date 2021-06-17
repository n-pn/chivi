-- +micrate Up
CREATE TABLE viuser_nvinfos (
  id serial PRIMARY KEY,

  viuser_id int not null,
  nvinfo_id int not null,

  blist varchar default 'default' not null,
  privi int default 1 not null,
  prefs jsonb default '{}'::jsonb NOT NULL,

  fav_sname varchar,
  chap_last varchar[],
  chap_mark varchar[],

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX viuser_nvinfo_unique_idx ON viuser_nvinfos (nvinfo_id, viuser_id);
CREATE INDEX viuser_nvinfo_viuser_id_idx ON viuser_nvinfos (viuser_id, blist);

-- +micrate Down
DROP TABLE IF EXISTS viuser_nvinfos;
