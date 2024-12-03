INSERT INTO Users (uid,username,vip,vip_deadline,u_create_date,follow_count,coin_count,follower_count,video_count,pwd)
VALUES ( uuid_generate_v4(), '东米宫',1,'2024-12-06'::date,'2022-9-11'::date,156,962,21,3,'Lzy20040301');
INSERT INTO Users (uid,username,vip,vip_deadline,u_create_date,follow_count,coin_count,follower_count,video_count,pwd)
VALUES ( uuid_generate_v4(),'Icey的小樱花',0,NULL,'2018-01-01'::date,341,1005,15,3,'037054123');
INSERT INTO Users (uid,username,vip,vip_deadline,u_create_date,follow_count,coin_count,follower_count,video_count,pwd)
VALUES ( uuid_generate_v4(),'李四',1,'2024-01-01'::date,'2018-01-01'::date,111,222,333,444,'lisi123456');
INSERT INTO Users (uid,username,vip,vip_deadline,u_create_date,follow_count,coin_count,follower_count,video_count,pwd)
VALUES ( uuid_generate_v4(),'王五',1,'2024-01-01'::date,'2018-01-01'::date,111,222,333,444,'wangwu123456');

SELECT * FROM Users