alter table uvcoins rename to exch_vcoins;
alter table ukarmas rename to exch_karmas;
alter table donates rename to donate_logs;
alter table unotifs rename to u_notifs;
alter table uqueues rename to u_queues;

alter index uvcoin_sender_idx rename to exch_vcoin_sender_idx;
alter index uvcoin_receiver_idx rename to exch_vcoin_receiver_idx;

alter index ukarma_sender_idx rename to exch_karma_sender_idx;
alter index ukarma_receiver_idx rename to exch_karma_receiver_idx;

alter index donate_cvuser_idx rename to donate_log_viuser_idx;
alter index donate_ctime_idx rename to donate_log_create_idx;

alter table exch_vcoins alter column sender_id type int;
alter table exch_vcoins alter column receiver_id type int;

alter table exch_karmas alter column sender_id type int;
alter table exch_karmas alter column receiver_id type int;
