DO $$
DECLARE
    userid TEXT;
    videoid INTEGER;
    author_id TEXT;
    result RECORD;
BEGIN
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';
    SELECT vid INTO videoid FROM Video WHERE title = '中途岛';
    SELECT uid INTO author_id FROM Users WHERE username = '东米宫';

    INSERT INTO Comment_to (vid,uid,username,thread,comment_to_thread ,comment_type ,comment_content,comment_create_date)
    VALUES (videoid,userid,'Icey的小樱花',1,NULL, 0,'最喜欢的一集，小时候看哭了',DEFAULT);
    INSERT INTO Comment_to (vid,uid,username,thread,comment_content,comment_create_date)
    VALUES (videoid,author_id,'东米宫',6,'楼上说的对',DEFAULT);

END $$;

SELECT * FROM Comment_to;