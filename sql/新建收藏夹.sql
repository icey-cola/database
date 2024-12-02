DO $$
DECLARE
    userid TEXT;
BEGIN
    -- 为用户 "东米宫" 获取 uid
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';

    INSERT INTO Favorite_table(uid, favorite_table_name, favorite_video_count)
    VALUES (userid, '默认收藏夹', DEFAULT);

END $$;

select * from Favorite_table;