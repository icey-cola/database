DO $$
DECLARE
    userid TEXT;
    userid2 TEXT;
    result RECORD;
BEGIN
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';
    SELECT uid INTO userid2 FROM Users WHERE username = '东米宫';
    
    
    INSERT INTO VIP(uid,purchase_id,purchase_duration,purchase_date)
    VALUES (userid,114,'P1Y2M3D',DEFAULT);
    INSERT INTO VIP(uid,purchase_id,purchase_duration,purchase_date)
    VALUES (userid2,115,'P2Y2M2D',DEFAULT);
    
    FOR result IN 
        select * from VIP
    LOOP
        -- RAISE NOTICE 'uid: %, purchase_id: %, purchase_duration: %, purchase_date: %', result.uid, result.purchase_id, result.purchase_duration, result.purchase_date;
    END LOOP;

END $$;



