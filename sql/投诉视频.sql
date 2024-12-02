DO $$
DECLARE
    result RECORD;
    videoid int;
	userid TEXT;
BEGIN  
    SELECT  vid FROM Video WHERE title = '中途岛' INTO videoid;
    SELECT uid FROM Users WHERE username = 'Icey的小樱花' INTO userid;
    -- 0为评论， 1为视频。
    INSERT INTO Report (uid,report_date, report_category, report_reason, report_result, report_vid, report_thread)
    VALUES (userid,DEFAULT, 0 , '色情', '违规', videoid, 0);

    INSERT INTO Report (uid,report_date, report_category, report_reason, report_result, report_vid, report_thread)
    VALUES (userid,DEFAULT, 1 , '色情', NULL, videoid, 0);
END $$;