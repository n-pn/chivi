SELECT
  setval(pg_get_serial_sequence('vcoin_xlogs', 'id'), coalesce(MAX(id), 1))
FROM
  vcoin_xlogs;
