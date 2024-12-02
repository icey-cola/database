DO $$
DECLARE
    userid TEXT;
    userid2 TEXT;
    result RECORD;
BEGIN
    SELECT uid INTO userid FROM Users WHERE username = 'Icey的小樱花';
    SELECT uid INTO userid2 FROM Users WHERE username = '东米宫';

    INSERT INTO Direct_message(dm_id,uid,username,friend_id,friend_username,sender_id,receiver_uid,dm_content,dm_date)
    VALUES (1,userid2,'东米宫',userid,'Icey的小樱花',userid2,userid,'v我50','2022-11-29 21:01:17');
    INSERT INTO Direct_message(dm_id,uid,username,friend_id,friend_username,sender_id,receiver_uid,dm_content,dm_date)
    VALUES (2,userid,'Icey的小樱花',userid2,'东米宫',userid2,userid,'v我50','2022-11-29 21:01:17');
    INSERT INTO Direct_message(dm_id,uid,username,friend_id,friend_username,sender_id,receiver_uid,dm_content,dm_date)
    VALUES (3,userid2,'东米宫',userid,'Icey的小樱花',userid,userid2,'遮沙避风','2022-11-29 21:02:13');
    INSERT INTO Direct_message(dm_id,uid,username,friend_id,friend_username,sender_id,receiver_uid,dm_content,dm_date)
    VALUES (4,userid,'Icey的小樱花',userid2,'东米宫',userid,userid2,'遮沙避风','2022-11-29 21:02:13');
    select * from Direct_message;
    
    FOR result IN 
        select * from Direct_message
    LOOP 
        RAISE NOTICE 'dm_id: %, uid: %, username: %, friend_id: %, friend_username: %, sender_id: %, receiver_uid: %, dm_content: %, dm_date: %', result.dm_id, result.uid, result.username, result.friend_id, result.friend_username, result.sender_id, result.receiver_uid, result.dm_content, result.dm_date;
    END LOOP;

END $$;



