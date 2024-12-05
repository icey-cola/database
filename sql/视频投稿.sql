    INSERT INTO Contribute(title, uid, username, contribute_time, contribute_result, reject_reason, contribute_category, contribute_duration, cover, is_vip)
    VALUES ('中途岛', (SELECT uid FROM Users WHERE username = '东米宫'), '东米宫', '2022-11-28 00:00:00', 0, NULL, 'movie', '00:35:00', NULL, 1);
    INSERT INTO Contribute(title, uid, username, contribute_time, contribute_result, reject_reason, contribute_category, contribute_duration, cover, is_vip)
    VALUES ('不要笑挑战', (SELECT uid FROM Users WHERE username = '东米宫'), '东米宫', '2023-12-18 00:00:00', 0, NULL, 'vlog', '00:10:00', NULL, 1);
    INSERT INTO Contribute(title, uid, username, contribute_time, contribute_result, reject_reason, contribute_category, contribute_duration, cover, is_vip)
    VALUES ('今天去春游', (SELECT uid FROM Users WHERE username = '东米宫'), '东米宫', '2023-12-19 00:00:00', 0, NULL, 'vlog', '00:12:00', NULL, 1);
    INSERT INTO Contribute(title, uid, username, contribute_time, contribute_result, reject_reason, contribute_category, contribute_duration, cover, is_vip)
    VALUES ('今天去旅游', (SELECT uid FROM Users WHERE username = 'Icey的小樱花'), 'Icey的小樱花', '2024-12-01 00:00:00', 0, NULL, 'vlog', '00:12:00', NULL, 1);