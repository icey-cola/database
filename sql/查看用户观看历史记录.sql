DO $$
DECLARE
    userid TEXT;
    userid2 TEXT;
    result RECORD;
BEGIN
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';

    
    
    FOR result IN 
        SELECT * FROM watched_history(userid)
    LOOP 
        RAISE NOTICE 'vid: %, video_title: %, watch_time: %, progress: %', result.vid_, result.video_title_, result.watch_time_, result.progress_;
    END LOOP;

END $$;