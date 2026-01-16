TRUNCATE TABLE bronze_customers;

INSERT INTO bronze_customers
(customer_id, customer_name, customer_phone, customer_email, source_system, ingest_batch_id)
VALUES
-- CUST-001..010 (shopify / batch_001)
('CUST-001','alex johnson','(415) 555-1001','alex.johnson@example.com','shopify','cust_batch_001'),
('CUST-002','Maria Lopez','415-555-1002','maria.lopez@example.com','shopify','cust_batch_001'),
('CUST-003','JAMES SMITH',NULL,'james.smith@example.com','shopify','cust_batch_001'),
('CUST-004','Emily davis','(212)555-1004',NULL,'shopify','cust_batch_001'),
('CUST-005','michael Brown','2125551005','michael.brown@example.com','shopify','cust_batch_001'),
('CUST-006','Sarah Wilson',NULL,NULL,'shopify','cust_batch_001'),
('CUST-007','daniel martinez','(310) 555-1007','daniel.martinez@example.com','shopify','cust_batch_001'),
('CUST-008','Olivia Anderson','310-555-1008','olivia.anderson@example.com','shopify','cust_batch_001'),
('CUST-009','DAVID TAYLOR','(646)555-1009','david.taylor@example.com','shopify','cust_batch_001'),
('CUST-010','Sophia thomas','6465551010',NULL,'shopify','cust_batch_001'),

-- CUST-011..020 (amazon / batch_002)
('CUST-011','chris moore','(206)555-1011','chris.moore@example.com','amazon','cust_batch_002'),
('CUST-012','Emma Jackson',NULL,'emma.jackson@example.com','amazon','cust_batch_002'),
('CUST-013','MATTHEW WHITE','206-555-1013',NULL,'amazon','cust_batch_002'),
('CUST-014','ava harris','(503) 555-1014','ava.harris@example.com','amazon','cust_batch_002'),
('CUST-015','Joshua Martin','5035551015','joshua.martin@example.com','amazon','cust_batch_002'),
('CUST-016','mia thompson',NULL,NULL,'amazon','cust_batch_002'),
('CUST-017','Andrew Garcia','(408)555-1017','andrew.garcia@example.com','amazon','cust_batch_002'),
('CUST-018','isabella Martinez','408-555-1018','isabella.martinez@example.com','amazon','cust_batch_002'),
('CUST-019','RYAN ROBINSON','(702) 555-1019',NULL,'amazon','cust_batch_002'),
('CUST-020','Charlotte Clark','7025551020','charlotte.clark@example.com','amazon','cust_batch_002'),

-- CUST-021..030 (web / batch_003)
('CUST-021','brandon rodriguez','(312)555-1021','brandon.rodriguez@example.com','web','cust_batch_003'),
('CUST-022','Amelia Lewis',NULL,NULL,'web','cust_batch_003'),
('CUST-023','justin lee','312-555-1023','justin.lee@example.com','web','cust_batch_003'),
('CUST-024','HARPER WALKER','(213) 555-1024','harper.walker@example.com','web','cust_batch_003'),
('CUST-025','kevin hall','2135551025',NULL,'web','cust_batch_003'),
('CUST-026','Ella Allen',NULL,'ella.allen@example.com','web','cust_batch_003'),
('CUST-027','aaron young','(646)555-1027','aaron.young@example.com','web','cust_batch_003'),
('CUST-028','Lily hernandez','646-555-1028','lily.hernandez@example.com','web','cust_batch_003'),
('CUST-029','NATHAN KING','(718)555-1029',NULL,'web','cust_batch_003'),
('CUST-030','Grace Wright','7185551030','grace.wright@example.com','web','cust_batch_003'),

-- CUST-031..040 (shopify / batch_004)
('CUST-031','jason lopez','(415)555-1031','jason.lopez@example.com','shopify','cust_batch_004'),
('CUST-032','Chloe Scott',NULL,NULL,'shopify','cust_batch_004'),
('CUST-033','BRIAN GREEN','415-555-1033','brian.green@example.com','shopify','cust_batch_004'),
('CUST-034','zoe adams','(212) 555-1034','zoe.adams@example.com','shopify','cust_batch_004'),
('CUST-035','Eric Baker','2125551035',NULL,'shopify','cust_batch_004'),
('CUST-036','hannah nelson',NULL,'hannah.nelson@example.com','shopify','cust_batch_004'),
('CUST-037','KYLE CARTER','(310)555-1037','kyle.carter@example.com','shopify','cust_batch_004'),
('CUST-038','aria mitchell','310-555-1038',NULL,'shopify','cust_batch_004'),
('CUST-039','Sean Perez','(646) 555-1039','sean.perez@example.com','shopify','cust_batch_004'),
('CUST-040','nora roberts','6465551040',NULL,'shopify','cust_batch_004'),

-- CUST-041..050 (amazon / batch_005)
('CUST-041','victor turner','(206)555-1041','victor.turner@example.com','amazon','cust_batch_005'),
('CUST-042','Layla Phillips',NULL,'layla.phillips@example.com','amazon','cust_batch_005'),
('CUST-043','ETHAN CAMPBELL','206-555-1043',NULL,'amazon','cust_batch_005'),
('CUST-044','penelope parker','(503)555-1044','penelope.parker@example.com','amazon','cust_batch_005'),
('CUST-045','Dylan Evans','5035551045',NULL,'amazon','cust_batch_005'),
('CUST-046','riley edwards',NULL,NULL,'amazon','cust_batch_005'),
('CUST-047','LOGAN COLLINS','(408)555-1047','logan.collins@example.com','amazon','cust_batch_005'),
('CUST-048','Lucy Stewart','408-555-1048','lucy.stewart@example.com','amazon','cust_batch_005'),
('CUST-049','owen sanchez','(702)555-1049',NULL,'amazon','cust_batch_005'),
('CUST-050','Avery Morris','7025551050','avery.morris@example.com','amazon','cust_batch_005'),

-- CUST-051..060 (web / batch_006)
('CUST-051','ian rogers','(312)555-1051','ian.rogers@example.com','web','cust_batch_006'),
('CUST-052','Scarlett Reed',NULL,NULL,'web','cust_batch_006'),
('CUST-053','NOAH COOK','312-555-1053','noah.cook@example.com','web','cust_batch_006'),
('CUST-054','victoria morgan','(213)555-1054','victoria.morgan@example.com','web','cust_batch_006'),
('CUST-055','Lucas Bell','2135551055',NULL,'web','cust_batch_006'),
('CUST-056','madison murphy',NULL,'madison.murphy@example.com','web','cust_batch_006'),
('CUST-057','ADAM BAILEY','(646)555-1057','adam.bailey@example.com','web','cust_batch_006'),
('CUST-058','sofia rivera','646-555-1058',NULL,'web','cust_batch_006'),
('CUST-059','Tyler Cooper','(718)555-1059','tyler.cooper@example.com','web','cust_batch_006'),
('CUST-060','camila richardson','7185551060',NULL,'web','cust_batch_006'),

-- CUST-061..070 (shopify / batch_007)
('CUST-061','jordan cox','(415)555-1061','jordan.cox@example.com','shopify','cust_batch_007'),
('CUST-062','Brooklyn Howard',NULL,'brooklyn.howard@example.com','shopify','cust_batch_007'),
('CUST-063','CHRISTIAN WARD','415-555-1063',NULL,'shopify','cust_batch_007'),
('CUST-064','paisley torres','(212)555-1064','paisley.torres@example.com','shopify','cust_batch_007'),
('CUST-065','Evan Peterson','2125551065',NULL,'shopify','cust_batch_007'),
('CUST-066','audrey gray',NULL,NULL,'shopify','cust_batch_007'),
('CUST-067','CONNOR RAMIREZ','(310)555-1067','connor.ramirez@example.com','shopify','cust_batch_007'),
('CUST-068','bella james','310-555-1068','bella.james@example.com','shopify','cust_batch_007'),
('CUST-069','Zachary Watson','(646)555-1069',NULL,'shopify','cust_batch_007'),
('CUST-070','naomi brooks','6465551070',NULL,'shopify','cust_batch_007'),

-- CUST-071..080 (amazon / batch_008)
('CUST-071','anthony kelly','(206)555-1071','anthony.kelly@example.com','amazon','cust_batch_008'),
('CUST-072','Leah Sanders',NULL,'leah.sanders@example.com','amazon','cust_batch_008'),
('CUST-073','BENJAMIN PRICE','206-555-1073',NULL,'amazon','cust_batch_008'),
('CUST-074','violet bennett','(503)555-1074','violet.bennett@example.com','amazon','cust_batch_008'),
('CUST-075','Jonathan Wood','5035551075',NULL,'amazon','cust_batch_008'),
('CUST-076','stella barnes',NULL,'stella.barnes@example.com','amazon','cust_batch_008'),
('CUST-077','CALEB ROSS','(408)555-1077','caleb.ross@example.com','amazon','cust_batch_008'),
('CUST-078','hazel henderson','408-555-1078',NULL,'amazon','cust_batch_008'),
('CUST-079','Patrick Coleman','(702)555-1079','patrick.coleman@example.com','amazon','cust_batch_008'),
('CUST-080','willow jenkins','7025551080',NULL,'amazon','cust_batch_008'),

-- CUST-081..090 (web / batch_009)
('CUST-081','jeremy perry','(312)555-1081','jeremy.perry@example.com','web','cust_batch_009'),
('CUST-082','Luna Powell',NULL,'luna.powell@example.com','web','cust_batch_009'),
('CUST-083','AUSTIN LONG','312-555-1083',NULL,'web','cust_batch_009'),
('CUST-084','savannah patterson','(213)555-1084','savannah.patterson@example.com','web','cust_batch_009'),
('CUST-085','Blake Hughes','2135551085',NULL,'web','cust_batch_009'),
('CUST-086','claire flores',NULL,'claire.flores@example.com','web','cust_batch_009'),
('CUST-087','HENRY WASHINGTON','(646)555-1087','henry.washington@example.com','web','cust_batch_009'),
('CUST-088','aurora butler','646-555-1088',NULL,'web','cust_batch_009'),
('CUST-089','Miles Simmons','(718)555-1089','miles.simmons@example.com','web','cust_batch_009'),
('CUST-090','piper foster','7185551090',NULL,'web','cust_batch_009'),

-- CUST-091..100 (shopify / batch_010)
('CUST-091','robert gonzales','(415)555-1091','robert.gonzales@example.com','shopify','cust_batch_010'),
('CUST-092','Ruby Bryant',NULL,'ruby.bryant@example.com','shopify','cust_batch_010'),
('CUST-093','STEVEN ALEXANDER','415-555-1093',NULL,'shopify','cust_batch_010'),
('CUST-094','mila russell','(212)555-1094','mila.russell@example.com','shopify','cust_batch_010'),
('CUST-095','Paul Griffin','2125551095',NULL,'shopify','cust_batch_010'),
('CUST-096','elena diaz',NULL,'elena.diaz@example.com','shopify','cust_batch_010'),
('CUST-097','MARK HAYES','(310)555-1097','mark.hayes@example.com','shopify','cust_batch_010'),
('CUST-098','ivy myers','310-555-1098',NULL,'shopify','cust_batch_010'),
('CUST-099','Trevor Ford','(646)555-1099','trevor.ford@example.com','shopify','cust_batch_010'),
('CUST-100','kinsley hamilton','6465551100',NULL,'shopify','cust_batch_010'),

-- CUST-101 (web / batch_011)
('CUST-101','LEO FISHER',NULL,'leo.fisher@example.com','web','cust_batch_011'),

-- Additional test customers with missing data for rejection testing
(NULL,'test customer one','(555) 555-2001','test.one@example.com','shopify','cust_batch_reject'),
('CUST-102',NULL,'(555) 555-2002','test.two@example.com','amazon','cust_batch_reject'),
('CUST-103','test customer three','(555) 555-2003','test.three@example.com',NULL,'cust_batch_reject'),
(NULL,NULL,'(555) 555-2004','test.four@example.com','web','cust_batch_reject'),
('CUST-104','test customer five','(555) 555-2005','test.five@example.com',NULL,'cust_batch_reject');
