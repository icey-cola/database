DO $$
DECLARE
    userid TEXT;
    videoid INTEGER;
    author_id TEXT;
    result RECORD;
BEGIN
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';
    SELECT vid INTO videoid FROM Video WHERE title = '中途岛';
    SELECT  Watch_insert(videoid,userid,'中途岛','2024-11-29 11:11:00'::timestamp,1,1,'00:23:07'::time) INTO result;
    RAISE NOTICE 'Notices Classify Result: %', result;
END $$;

SELECT * FROM Watch;