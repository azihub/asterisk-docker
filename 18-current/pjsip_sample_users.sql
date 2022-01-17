insert into ps_aors (id, max_contacts) values (9001, 1);
insert into ps_aors (id, max_contacts) values (9002, 1);
insert into ps_auths (id, username, auth_type, password) values (9001, 9001, 'userpass', 'XpVdgEqjaxu891');
insert into ps_auths (id, username, auth_type, password) values (9002, 9002, 'userpass', 'XpVdgEqjaxu891');

-- UDP
insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (9001, 'transport-udp', '9001', '9001', 'testing', 'all', 'opus', 'no');
insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (9002, 'transport-udp', '9002', '9002', 'testing', 'all', 'opus', 'no');

-- TCP
insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (9001, 'transport-tcp', '9001', '9001', 'testing', 'all', 'opus', 'no');
insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (9002, 'transport-tcp', '9002', '9002', 'testing', 'all', 'opus', 'no');

-- TLS
insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (9001, 'transport-tls', '9001', '9001', 'testing', 'all', 'opus', 'no');
insert into ps_endpoints (id, transport, aors, auth, context, disallow, allow, direct_media) values (9002, 'transport-tls', '9002', '9002', 'testing', 'all', 'opus', 'no');
