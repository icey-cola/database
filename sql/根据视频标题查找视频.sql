DO $$
DECLARE
    result RECORD;
BEGIN  
    FOR result IN 
        SELECT * FROM search_video_title('中途岛')
    LOOP 
        RAISE NOTICE 'title: %, author: %', result.title, result.username;
    END LOOP;

END $$;