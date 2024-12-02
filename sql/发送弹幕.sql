DO $$
DECLARE
    userid TEXT;
    videoid INTEGER;
    userid2 TEXT;
    result RECORD;
BEGIN
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';
    SELECT uid INTO userid2 FROM Users WHERE username = '东米宫';
    SELECT vid INTO videoid FROM Video WHERE title = '中途岛';

    INSERT INTO Bullet_screen(vid,uid,bullet_screen_id,bullet_screen_content,bullet_screen_date,bullet_screen_time)
    VALUES (videoid,userid2,666,'垂死病中惊坐起，阎王夸我好身体','2022-11-29 21:11:10','00:43:07');
    INSERT INTO Bullet_screen(vid,uid,bullet_screen_id,bullet_screen_content,bullet_screen_date,bullet_screen_time)
    VALUES (videoid,userid,667,'前方高能','2022-11-29 21:11:10','00:45:47');
    INSERT INTO Bullet_screen(vid,uid,bullet_screen_id,bullet_screen_content,bullet_screen_date,bullet_screen_time)
    VALUES (videoid,userid,665,'火钳刘明','2022-11-29 21:01:17','00:05:47');
    FOR result IN 
        SELECT * FROM Bullet_screen
    LOOP
        RAISE NOTICE 'Bullet Screen ID: %, Content: %', result.bullet_screen_id, result.bullet_screen_content;
    END LOOP;

END $$;