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
    
    
    INSERT INTO Follow(uid,follow_uid,follow_username,push_switch)
    VALUES (userid,userid2,'东米宫',1);
    INSERT INTO Follow(uid,follow_uid,follow_username,push_switch)
    VALUES (userid2,userid,'Icey的小樱花',1);
    
    FOR result IN 
        select * from Follow
    LOOP
        RAISE NOTICE 'uid:%,follow_uid:%,follow_username:%,push_switch:%',result.uid,result.follow_uid,result.follow_username,result.push_switch;
    END LOOP;

END $$;



