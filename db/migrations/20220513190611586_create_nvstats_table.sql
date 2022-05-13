-- +micrate Up
CREATE TABLE nvstats (
  id bigserial primary key,

  nvinfo_id bigint not null,
  kind int not null default 0,

  info_views int not null default 0,
  text_views int not null default 0,
  chat_views int not null default 0,

  voters int not null default 0,
  scored int not null default 0,

  weight int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX nvstat_nvinfo_idx ON nvstats (nvinfo_id, kind);
CREATE INDEX nvstat_weight_idx ON nvstats (kind, weight);

-- +micrate Down
DROP TABLE IF EXISTS nvstats;
