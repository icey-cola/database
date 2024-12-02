DO $$
DECLARE
    userid TEXT;
    videoid INTEGER;
BEGIN
    -- 为用户 "东米宫" 获取 uid
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';
    SELECT vid INTO videoid FROM Video WHERE title = '中途岛';
    INSERT INTO Favorite(vid,uid,favorite_table_id)
    VALUES (videoid,userid,1);

END $$;

select * from Favorite;