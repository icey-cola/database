DO $$
DECLARE
    result RECORD;
BEGIN  
    FOR result IN 
        SELECT * FROM search_video_author('东米宫')
    LOOP 
        RAISE NOTICE 'title: %, author: %', result.title, result.username;
    END LOOP;

END $$;