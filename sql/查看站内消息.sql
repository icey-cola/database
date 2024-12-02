DO $$
DECLARE
    userid TEXT;
    result RECORD;  -- 用于存储查询结果
BEGIN
    -- 为用户 "东米宫" 获取 uid
    SELECT uid INTO userid FROM Users WHERE username = '东米宫';
	
    FOR result IN 
        SELECT * INTO result FROM notices_classify(userid, 1)
    LOOP 
        RAISE NOTICE '用户名: %, 通知日期: %, 通知内容: %', result.username, result.notice_date, result.notice_content;
    END LOOP;
END $$;
