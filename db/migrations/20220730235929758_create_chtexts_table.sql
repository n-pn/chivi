-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE chtexts (
  chinfo_id int not null primary key references chinfos (id) on update cascade on delete cascade,

  content text[],

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE chtexts;
