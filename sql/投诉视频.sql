-- 0为评论， 1为视频。
INSERT INTO Report (uid,report_date, report_category, report_reason, report_result, report_vid, report_thread)
VALUES ((SELECT uid FROM Users WHERE username = 'TommyGong'),DEFAULT, '评论' , '色情', NULL, (SELECT vid FROM Video WHERE title = '中途岛'), 0);

INSERT INTO Report (uid,report_date, report_category, report_reason, report_result, report_vid, report_thread)
VALUES ((SELECT uid FROM Users WHERE username = 'Icey的小樱花'),DEFAULT, '视频' , '色情', NULL, (SELECT vid FROM Video WHERE title = '中途岛'), 0);