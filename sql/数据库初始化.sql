DROP TABLE IF EXISTS Video CASCADE;

DROP TABLE IF EXISTS Users CASCADE;

DROP TABLE IF EXISTS Report;

DROP TABLE IF EXISTS Admins;

DROP TABLE IF EXISTS Contribute;

DROP TABLE IF EXISTS Comment_to;

DROP TABLE IF EXISTS Watch;

DROP TABLE IF EXISTS Bullet_screen;

DROP TABLE IF EXISTS Favorite;

DROP TABLE IF EXISTS Favorite_table;

DROP TABLE IF EXISTS Follow;

DROP TABLE IF EXISTS VIP;

DROP TABLE IF EXISTS Direct_message;

DROP TABLE IF EXISTS Blacklist;

DROP TABLE IF EXISTS Notices CASCADE;

DROP TABLE IF EXISTS video_category;


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
---------------------------------------------------------数据表建立----------------------------------------------------
CREATE TABLE Users (
    uid TEXT NOT NULL PRIMARY KEY,
    username VARCHAR(30),
    vip INT DEFAULT 0,
    vip_deadline TimeStamp DEFAULT NULL,
    u_create_date DATE DEFAULT CURRENT_DATE,
    follow_count INT DEFAULT 0,
    coin_count INT DEFAULT 100,
    follower_count INT DEFAULT 0,
    video_count INT DEFAULT 0,
    pwd VARCHAR(30) check (
        length(pwd) between 8
        and 30
    )
);

CREATE TABLE Video_Category(
    Category_name VARCHAR(30) NOT NULL PRIMARY KEY,
    Category_introduction VARCHAR(256)
);

CREATE TABLE Video (
    vid SERIAL NOT NULL PRIMARY KEY,
    url TEXT,
    uid TEXT REFERENCES Users(uid) ON DELETE CASCADE,
    username VARCHAR(30),
    title VARCHAR(30),
    v_create_date DATE DEFAULT CURRENT_DATE,
    category VARCHAR(30) REFERENCES Video_Category(Category_name) ON DELETE CASCADE,
    duration INTERVAL,
    comments_count INT DEFAULT 0,
    oppose_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    bullet_screen_count INT DEFAULT 0,
    insert_coin_count INT DEFAULT 0,
    cover VARCHAR(255),
    is_vip INT
);

CREATE TABLE Admins(
    mid SERIAL NOT NULL PRIMARY KEY,
    pwd VARCHAR(30) check (
        length(pwd) between 8
        and 30
    )
);

CREATE TABLE Report(
    uid TEXT references Users(uid) ON DELETE CASCADE,
    report_id SERIAL NOT NULL PRIMARY KEY,
    report_date TimeStamp DEFAULT CURRENT_TIMESTAMP,
    report_category VARCHAR(30),
    report_reason VARCHAR(255),
    report_result VARCHAR(255),
    report_vid INT references Video(vid) ON DELETE CASCADE,
    report_thread INT
);

CREATE TABLE Contribute(
    contribute_id SERIAL NOT NULL PRIMARY KEY,
    uid TEXT references Users(uid) ON DELETE CASCADE,
    title VARCHAR(30),
    username VARCHAR(30),
    contribute_time TimeStamp DEFAULT CURRENT_TIMESTAMP,
    contribute_result INT DEFAULT NULL,
    reject_reason VARCHAR(255) DEFAULT NULL,
    contribute_category VARCHAR(30) references Video_Category(Category_name) ON DELETE CASCADE,
    contribute_duration INTERVAL,
    cover VARCHAR(255),
    is_vip INT
);

CREATE TABLE Comment_to(
    vid INT references Video(vid) ON DELETE CASCADE,
    uid TEXT references Users(uid) ON DELETE CASCADE,
    username VARCHAR(30),
    thread INT,
    comment_to_thread INT,
    comment_type INT,
    comment_content VARCHAR(255),
    comment_create_date TimeStamp DEFAULT CURRENT_TIMESTAMP,
    primary key (vid, thread)
);

CREATE TABLE Watch(
    vid INT references Video(vid) ON DELETE CASCADE,
    title VARCHAR(30),
    uid TEXT references Users(uid) ON DELETE CASCADE,
    watch_time TimeStamp DEFAULT CURRENT_TIMESTAMP,
    is_like INT,
    insert_coin INT,
    progress TIME,
    primary key (vid, uid)
);

CREATE TABLE Bullet_screen(
    vid INT references Video(vid) ON DELETE CASCADE,
    uid TEXT references Users(uid) ON DELETE CASCADE,
    bullet_screen_id SERIAL NOT NULL PRIMARY KEY,
    bullet_screen_content VARCHAR(128),
    bullet_screen_date TimeStamp DEFAULT CURRENT_TIMESTAMP,
    bullet_screen_time TIME
);

CREATE TABLE Favorite(
    vid INT references Video(vid) ON DELETE CASCADE,
    title VARCHAR(30),
    uid TEXT references Users(uid),
    favorite_id SERIAL NOT NULL PRIMARY KEY,
    favorite_table_id INT,
    favorite_name VARCHAR(30),
    favorite_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Favorite_table(
    favorite_table_id SERIAL NOT NULL PRIMARY KEY,
    uid TEXT references Users(uid) ON DELETE CASCADE,
    favorite_table_name VARCHAR(30) NOT NULL UNIQUE,
    favorite_video_count INT DEFAULT 0
);

CREATE TABLE Follow(
    uid TEXT references Users(uid) ON DELETE CASCADE,
    follow_uid TEXT references Users(uid) ON DELETE CASCADE,
    follow_username VARCHAR(30),
    push_switch INT DEFAULT 1,
    primary key (uid, follow_uid)
);

CREATE TABLE VIP(
    uid TEXT references Users(uid) ON DELETE CASCADE,
    purchase_id SERIAL NOT NULL PRIMARY KEY,
    purchase_duration INTERVAL,
    purchase_date TimeStamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Direct_message(
    dm_id SERIAL NOT NULL PRIMARY KEY,
    uid TEXT references Users(uid) ON DELETE CASCADE,
    username VARCHAR(30),
    friend_id TEXT references Users(uid) ON DELETE CASCADE,
    friend_username VARCHAR(30),
    sender_id TEXT references Users(uid) ON DELETE CASCADE,
    receiver_uid TEXT references Users(uid) ON DELETE CASCADE,
    dm_content VARCHAR(255),
    dm_date TimeStamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Blacklist(
    uid TEXT references Users(uid) ON DELETE CASCADE,
    username VARCHAR(30),
    blacklist_uid TEXT references Users(uid) ON DELETE CASCADE,
    blacklist_username VARCHAR(30),
    primary key (uid, blacklist_uid)
);

CREATE TABLE Notices(
    uid TEXT references Users(uid) ON DELETE CASCADE,
    username VARCHAR(30),
    notice_date TimeStamp DEFAULT CURRENT_TIMESTAMP,
    notice_category INT,
    notice_content VARCHAR(256)
);

-- DROP FUNCTION IF EXISTS Watch_insert;

-- -- DROP trigger watch_trigger on Watch;

-- DROP FUNCTION IF EXISTS watch_func;

-- DROP FUNCTION IF EXISTS watch_update_func;

-- DROP FUNCTION IF EXISTS followfunc;

-- -- drop trigger follow_trigger on Follow;

-- -- drop trigger follow_delete_trigger on Follow;

-- DROP FUNCTION IF EXISTS follow_delete_func;

-- drop trigger dm_trigger on Direct_message;

-- DROP FUNCTION IF EXISTS dmfunc;

-- drop trigger Bullet_screen_trigger on Bullet_screen;

-- DROP FUNCTION IF EXISTS Bullet_screen_func;

-- drop trigger Bullet_screen_delete_trigger on Bullet_screen;

-- DROP FUNCTION IF EXISTS Bullet_screen_delete_func;

-- drop trigger VIP_trigger on VIP;

-- DROP FUNCTION IF EXISTS VIP_func;
-- DROP FUNCTION watch_insert(integer,integer,character varying,timestamp without time zone,integer,integer,time without time zone);
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
---触发器和存储过程
---Watch 插入函数 重复观看某一个视频则变插入为更新
create or replace function Watch_insert(Cvid integer,Cuid TEXT, Ctitle VARCHAR, 
                                        Cwatch_time TimeStamp,Cis_like integer,
                                        Cinsert_coin INT,Cprogress TIME)
 returns void AS $BODY$
begin
    insert into Watch (vid,title,uid, watch_time,is_like,insert_coin,progress)
    values(Cvid,Ctitle,Cuid, CURRENT_TIMESTAMP,Cis_like,Cinsert_coin,Cprogress)
    on conflict (uid ,vid)
    do
    update set watch_time = CURRENT_TIMESTAMP,is_like = Cis_like, progress = Cprogress;
end
$BODY$
LANGUAGE 'plpgsql' VOLATILE; 

--Watch 触发器 每插入一条观看记录就更新点赞、投币、播放量相关属性，并插入通知列表
CREATE OR REPLACE FUNCTION watch_func() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN
      if new.is_like = 1 THEN
         UPDATE Video SET like_count = like_count+1 WHERE vid = new.vid;
         INSERT INTO Notices(uid, username,notice_date,notice_category,notice_content)
         VALUES ((select Video.uid FROM Video WHERE Video.vid = new.vid),(select Video.username FROM Video WHERE Video.vid = new.vid),
                 default,3,
                 format('您的视频%s被%s点赞了',(select Video.title FROM Video WHERE Video.vid = new.vid),
                        (select Users.username FROM Users WHERE Users.uid = new.uid)));
      else 
      END IF;
      if new.insert_coin = 1 THEN
         UPDATE Video SET insert_coin_count = insert_coin_count+1 WHERE vid = new.vid;
         UPDATE Users SET coin_count = coin_count-1 WHERE uid = new.uid;
         UPDATE Users SET coin_count = coin_count+1 WHERE uid = (select uid FROM Video WHERE vid = new.vid );
         INSERT INTO Notices(uid, username,notice_date,notice_category,notice_content)
         VALUES ((select Video.uid FROM Video WHERE Video.vid = new.vid),(select Video.username FROM Video WHERE Video.vid = new.vid),
                 default,5,
                 format('您的视频%s被%s投币了',(select Video.title FROM Video WHERE Video.vid = new.vid),
                        (select Users.username FROM Users WHERE Users.uid = new.uid)));
      else 
      END IF;
                UPDATE Video SET oppose_count = oppose_count+1 WHERE vid = new.vid;
      RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER watch_trigger 
AFTER INSERT ON Watch 
FOR EACH ROW 
EXECUTE PROCEDURE watch_func();

--Watch 触发器 对于重复观看记录的更新操作，投币不能撤回，但可以更新点赞和播放量
CREATE OR REPLACE FUNCTION watch_update_func() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN
      if new.is_like = 0 THEN
         UPDATE Video SET like_count = like_count-1 WHERE vid = new.vid;
      else 
      END IF;
         UPDATE Video SET oppose_count = oppose_count+1 WHERE vid = new.vid;
      RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER watch_update_trigger 
AFTER UPDATE OF "is_like","progress" ON Watch
FOR EACH ROW 
EXECUTE PROCEDURE watch_update_func();

--Follow 触发器 每插入一条关注记录，更新粉丝数、关注数，并插入通知列表
CREATE OR REPLACE FUNCTION followfunc() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN 
        UPDATE Users SET follower_count = follower_count+1 WHERE uid = new.follow_uid;
        UPDATE Users SET follow_count = follow_count+1 WHERE uid = new.uid;
        INSERT INTO Notices(uid, username,notice_date,notice_category,notice_content)
        VALUES (new.follow_uid,
                new.follow_username,
                default,
                7,
                format('您被%s关注了',(select Users.username FROM Users WHERE Users.uid = new.uid)));
    RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER follow_trigger 
AFTER INSERT ON Follow 
FOR EACH ROW 
EXECUTE PROCEDURE followfunc();

--Follow 触发器 每次删除一条关注记录，更新粉丝数、关注数
CREATE OR REPLACE FUNCTION follow_delete_func() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN 
      UPDATE Users SET follower_count = follower_count-1 WHERE uid = old.follow_uid;
      UPDATE Users SET follow_count = follow_count-1 WHERE uid = old.uid;
   RETURN OLD;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER follow_delete_trigger 
AFTER DELETE ON Follow 
FOR EACH ROW 
EXECUTE PROCEDURE follow_delete_func();

--Direct_message 发送函数 每发送一条私信插入两条记录以应对单方面删除私信对方还可见的情况，可参照之前发的网址写
create or replace function dm_insert(uid integer, username VARCHAR(30),friend_id INT,friend_username VARCHAR(30),dm_content VARCHAR(255))
 returns void AS
$BODY$
begin
	INSERT INTO Direct_message(uid,username,friend_id,friend_username,sender_id,receiver_uid,dm_content,dm_date)
    VALUES (uid,username,friend_id,friend_username,uid,friend_id,dm_content,DEFAULT);
    INSERT INTO Direct_message(uid,username,friend_id,friend_username,sender_id,receiver_uid,dm_content,dm_date)
    VALUES (friend_id,friend_username,uid,username,uid,friend_id,dm_content,DEFAULT);

end
$BODY$
LANGUAGE 'plpgsql' VOLATILE; 

--Direct_message触发器 每插入一条私信记录会通知对方
CREATE OR REPLACE FUNCTION dmfunc() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN
   --拉黑判断
        if new.receiver_uid = (select B.uid FROM Blacklist B 
                               WHERE B.uid = new.receiver_uid AND B.blacklist_uid = new.sender_id) 
        then
            DELETE FROM Direct_message 
                WHERE dm_id = new.dm_id;
        else 
            --接收方
            if new.uid = new.receiver_uid THEN
                INSERT INTO Notices(uid, username,notice_date,notice_category,notice_content)
                VALUES (new.uid,
                        new.username,
                        default,
                        8,
                        format('您收到了%s的私信',new.friend_username));
            END IF;
        END IF;
        RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER dm_trigger 
AFTER INSERT ON Direct_message
FOR EACH ROW 
EXECUTE PROCEDURE dmfunc() ;

--Bullet_screen触发器 每插入一条弹幕，就更新视频的弹幕数
CREATE OR REPLACE FUNCTION Bullet_screen_func() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN
    UPDATE Video SET bullet_screen_count = bullet_screen_count + 1 WHERE vid = new.vid;
   RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER Bullet_screen_trigger 
AFTER INSERT ON Bullet_screen 
FOR EACH ROW 
EXECUTE PROCEDURE Bullet_screen_func();

--Bullet_screen触发器 每撤回一条弹幕，就更新视频的弹幕数
CREATE OR REPLACE FUNCTION Bullet_screen_delete_func() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN
    UPDATE Video SET bullet_screen_count = bullet_screen_count-1 WHERE vid = old.vid;
   RETURN OLD;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER Bullet_screen_delete_trigger 
AFTER DELETE ON Bullet_screen 
FOR EACH ROW 
EXECUTE PROCEDURE Bullet_screen_delete_func();

--VIP触发器 每插入一条充值记录，更新会员到期时间和是否为会员的属性
CREATE OR REPLACE FUNCTION VIP_func() 
RETURNS TRIGGER 
AS $example_table$
   BEGIN
    if (select Users.vip FROM Users WHERE Users.uid = new.uid ) = 1 THEN
        UPDATE Users SET vip_deadline = vip_deadline + new.purchase_duration WHERE uid = new.uid;
    else  
        UPDATE Users SET vip = 1 WHERE uid = new.uid;
        UPDATE Users SET vip_deadline = new.purchase_date + new.purchase_duration WHERE uid = new.uid;
    END IF;
    RETURN NEW;
   END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER VIP_trigger 
AFTER INSERT ON VIP 
FOR EACH ROW 
EXECUTE PROCEDURE VIP_func();

--VIP定时器

 --视频删除触发器 更新对应投稿状态，以及更新收藏夹中标题和观看记录中标题为'该视频已被删除'
 CREATE OR REPLACE FUNCTION video_delete()  RETURNS TRIGGER AS $$
	BEGIN 
		UPDATE Contribute SET contribute_result= -1 WHERE contribute_id=old.vid;
        UPDATE Favorite  SET  Favorite.title = '该视频已被删除' WHERE Favorite.vid=old.vid;
        UPDATE Watch  SET  Watch.title = '该视频已被删除' WHERE Watch.vid=old.vid;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

-- 投稿更新触发器 投稿通过时insert到Video表中，并给up主增加一条通知
CREATE OR REPLACE FUNCTION contribute_func()  RETURNS TRIGGER AS $$
	BEGIN 
		if(new.contribute_result = 1) then
			INSERT INTO Video( uid,username, title, v_create_date,category,duration,comments_count ,oppose_count,favorite_count,like_count,bullet_screen_count,insert_coin_count,cover,is_vip)
			VALUES(new.uid, new.username, new.title,new.contribute_time, new.contribute_category, new.contribute_duration, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, new.cover, new.is_vip);
			
			INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
			VALUES(new.uid, new.username, DEFAULT, 2, format('您的投稿%s审核通过', new.title));
		end if;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER contribute_trigger 
AFTER UPDATE OF contribute_result ON Contribute
FOR EACH ROW
EXECUTE PROCEDURE contribute_func();

-- 创建用户触发器
CREATE OR REPLACE FUNCTION create_user_func()  RETURNS TRIGGER AS $$
	DECLARE uid_temp TEXT;
	BEGIN 
		SELECT uuid_generate_v4() INTO uid_temp;
		UPDATE Users SET uid = uid_temp WHERE uid = new.uid;
		RETURN NULL;
		END; $$ 
LANGUAGE plpgsql;

CREATE TRIGGER create_user_trigger 
AFTER INSERT ON Users
FOR EACH ROW
EXECUTE PROCEDURE create_user_func();


-- 视频推送触发器 up主更新视频后，会增加其个人的视频数，并会通过系统通知自动推送给关注up主并打开推送开关的用户
CREATE OR REPLACE FUNCTION push_func()  RETURNS TRIGGER AS $$
	DECLARE i Follow%ROWTYPE;
	username_author VARCHAR(30);
	url_temp TEXT;
	BEGIN 
		SELECT username FROM Users WHERE uid = new.uid INTO username_author;
		UPDATE Video SET username = username_author WHERE vid = new.vid;

		SELECT 'https://www.example.com/video/' || uuid_generate_v4() INTO url_temp;

		UPDATE Video SET url = url_temp WHERE vid = new.vid;

		UPDATE Users
		SET video_count = video_count+1
		WHERE uid = new.uid;
		
		FOR i IN 
		SELECT * FROM Follow
		WHERE follow_uid = new.uid AND push_switch = 1
		LOOP
			INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
			VALUES(i.uid, (SELECT username FROM Users WHERE uid = i.uid), DEFAULT, 0, format('您关注的up主%s已更新', new.username));
		END LOOP;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER video_insert_trigger 
AFTER INSERT ON Video
FOR EACH ROW
EXECUTE PROCEDURE push_func();

-- 视频删除触发器 视频被举报删除后，投稿中该视频的状态改为-1（即已删除）
CREATE OR REPLACE FUNCTION video_delete()  RETURNS TRIGGER AS $$
	BEGIN 
		UPDATE Contribute SET contribute_result= -1 WHERE contribute_id=old.vid;
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER video_delete_trigger 
AFTER INSERT ON Video
FOR EACH ROW
EXECUTE PROCEDURE video_delete();

-- 收藏insert触发器	增加视频的收藏数和收藏夹的收藏视频数，并给up主发通知	
CREATE OR REPLACE FUNCTION favorite_insert_func()  RETURNS TRIGGER AS $$
	DECLARE uid_author TEXT;
		username_author VARCHAR(30);
		title_video VARCHAR(30);
		favorite_name_temp VARCHAR(30);
	BEGIN
        -- 根据vid获取视频title
        SELECT title FROM Video WHERE vid = new.vid INTO title_video;
        -- 更新favorite的title
        UPDATE Favorite SET title = title_video WHERE favorite_id = new.favorite_id;
        -- 更新favoritedate为当前日期
        UPDATE Favorite SET favorite_date = CURRENT_TIMESTAMP WHERE favorite_id = new.favorite_id;
        -- 根据favorite_table_id获取收藏夹名称
        SELECT favorite_table_name FROM Favorite_table WHERE favorite_table_id = new.favorite_table_id and uid = new.uid INTO favorite_name_temp;
        UPDATE Favorite SET favorite_name = favorite_name_temp;

		UPDATE Video 
		SET favorite_count = favorite_count+1 
		WHERE Video.vid = new.vid;
		
		UPDATE Favorite_table
		SET favorite_video_count = favorite_video_count + 1
		WHERE favorite_table_id = new.favorite_table_id;
		
		SELECT uid FROM Video WHERE vid = new.vid INTO uid_author;
		SELECT username FROM Video WHERE vid = new.vid INTO username_author;
		SELECT title FROM Video WHERE vid = new.vid INTO title_video;
		INSERT INTO Notices(uid, username, notice_date, notice_category, notice_content)
		-- VALUES((SELECT uid FROM Video WHERE vid = new.vid), (SELECT username FROM Video WHERE vid = new.vid), DEFAULT, 4, "您的视频被收藏"format('您的视频%s被%s收藏','你好','中国'););
		VALUES(uid_author, username_author, DEFAULT, 4, format('您的视频%s被%s收藏',title_video,(SELECT username FROM Users WHERE uid = new.uid)));
		RETURN NULL;
	END; $$ 
LANGUAGE plpgsql;

CREATE TRIGGER favorite_insert_trigger 
AFTER INSERT ON Favorite
FOR EACH ROW
EXECUTE PROCEDURE favorite_insert_func();

-- 收藏删除触发器  减小视频的收藏数和收藏夹的收藏视频数
CREATE OR REPLACE FUNCTION favorite_delete_func() RETURNS TRIGGER AS $$
	BEGIN
		UPDATE Video
		SET favorite_count = favorite_count - 1
		WHERE Video.vid = old.vid;
		
		UPDATE Favorite_table
		SET favorite_video_count = favorite_video_count - 1
		WHERE favorite_table_id = old.favorite_table_id;
		RETURN NULL;
	END; $$
LANGUAGE plpgsql;

CREATE TRIGGER  favorite_delete_triger
AFTER DELETE ON Favorite
FOR EACH ROW
EXECUTE PROCEDURE favorite_delete_func();

--  举报处理结果触发器 如果举报成功，删除视频或评论，给举报人、被举报人发通知；否则给举报人发通知
CREATE OR REPLACE FUNCTION report_update_func() RETURNS TRIGGER AS $$
	BEGIN
		IF new.report_result = '1' then
			if new.report_category = '0' then				
				INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
				VALUES((select uid FROM Comment_to WHERE thread = new.report_thread), (select username FROM Comment_to WHERE vid = new.report_vid), DEFAULT, 6, format('您的评论%s因举报删除', (SELECT comment_content FROM Comment_to WHERE thread=new.report_thread)));
			
				DELETE FROM Comment_to 
				WHERE Comment_to.vid = new.report_vid and Comment_to.thread = new.report_thread;
			ELSEIF new.report_category = '1' then				
				INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
				VALUES((select uid FROM Video WHERE vid = new.report_vid), (select username FROM Video WHERE vid = new.report_vid), DEFAULT, 6, format('您的视频%s因举报删除', (SELECT title FROM Video WHERE vid = new.report_vid)));
			
				DELETE FROM Video 
				WHERE Video.vid = new.report_vid;
			END IF;
			
			INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
			VALUES(new.uid,(select username FROM Users WHERE uid = new.uid), DEFAULT, 1, format('您的举报%s成功',new.report_id));
			
		ELSE 
			INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
			VALUES(new.uid, (select username FROM Users WHERE uid = new.uid), DEFAULT, 1, format('您的举报%s失败',new.report_id));
		END IF;
		RETURN NULL;
	END; $$
LANGUAGE plpgsql;

CREATE TRIGGER  report_update_triger
AFTER UPDATE OF report_result ON Report
FOR EACH ROW
EXECUTE PROCEDURE report_update_func();

drop trigger if exists report_update_triger on Report;


-- 评论insert触发器 给up主发通知，并增加视频的评论数
CREATE OR REPLACE FUNCTION comment_insert_func() RETURNS TRIGGER AS $$
	BEGIN
		UPDATE Video 
		SET comments_count = comments_count+1 
		WHERE Video.vid = new.vid;
		
		IF (new.comment_type= 0) THEN
			INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
			VALUES(new.uid, (SELECT username FROM Video WHERE vid = new.vid), DEFAULT, 9, format('您的视频%s被%s评论"%s"', (SELECT title FROM Video WHERE vid=new.vid), (SELECT username FROM Users WHERE uid=new.uid), new.comment_content));
		ELSEIF (new.comment_type = 1) THEN
			INSERT INTO notices(uid, username, notice_date, notice_category, notice_content)
			VALUES(new.uid, (SELECT username FROM Comment_to WHERE vid = new.vid AND thread=new.comment_to_thread), DEFAULT, 9, format('您的评论%s被%s评论"%s"',(SELECT comment_content FROM Comment_to WHERE thread=new.comment_to_thread), (SELECT username FROM Users WHERE uid=new.uid), new.comment_content));
		END IF;
		RETURN NULL;
	END; $$
LANGUAGE plpgsql;

CREATE TRIGGER  comment_insert_triger
AFTER INSERT ON Comment_to
FOR EACH ROW
EXECUTE PROCEDURE comment_insert_func();

-- 	减小视频的评论数
CREATE OR REPLACE FUNCTION comment_delete_func() RETURNS TRIGGER AS $$
	BEGIN
		UPDATE Video 
		SET comments_count = comments_count-1 
		WHERE Video.vid = old.vid;
		RETURN NULL;
	END; $$
LANGUAGE plpgsql;

CREATE TRIGGER  comment_delete_triger
AFTER DELETE ON Comment_to
FOR EACH ROW
EXECUTE PROCEDURE comment_delete_func();

-- 查看用户的历史记录，可以看到视频名称，观看时间和观看时长
CREATE OR REPLACE FUNCTION watched_history(
	IN u_id_param TEXT
) RETURNS TABLE(
	vid_ INT,
	video_title_ VARCHAR(30),
	watch_time_ TimeStamp,
	progress_ TIME
) AS $$
	DECLARE i Watch%ROWTYPE;
	BEGIN
		RETURN QUERY
		SELECT vid, title, watch_time, progress
		FROM Watch WHERE uid = u_id_param ORDER BY watch_time;
	END; $$
LANGUAGE plpgsql;

-- -- 	
-- CREATE OR REPLACE FUNCTION search_video(
-- 	IN v_title_param VARCHAR(30),
-- 	IN v_username_param VARCHAR(30)
-- ) RETURNS SETOF Video AS $$
-- 	BEGIN
-- 		RETURN QUERY
-- 		SELECT * FROM Video 
-- 		WHERE title = v_title_param AND username = v_username_param;
-- 	END; $$
-- LANGUAGE plpgsql;



-- 	搜索视频名称
CREATE OR REPLACE FUNCTION search_video_title(
	IN v_title_param VARCHAR(30)
) RETURNS SETOF Video AS $$
	BEGIN
		RETURN QUERY
		SELECT * FROM Video 
		WHERE title = v_title_param;
	END; $$
LANGUAGE plpgsql;

-- 	搜索up主名称
CREATE OR REPLACE FUNCTION search_video_author(
	IN v_username_param VARCHAR(30)
) RETURNS SETOF Video AS $$
	BEGIN
		RETURN QUERY
		SELECT * FROM Video 
		WHERE username = v_username_param;
	END; $$
LANGUAGE plpgsql;

--  通知列表
CREATE OR REPLACE FUNCTION notices_classify(
	IN u_id_param TEXT,
	IN notice_category_param INT
) RETURNS SETOF Notices AS $$
	BEGIN
-- 		
		IF (notice_category_param = 0) THEN
			RETURN QUERY
			SELECT * FROM Notices 
			WHERE uid = u_id_param AND notice_category = 0;
		ELSEIF (notice_category_param = 1) THEN
			RETURN QUERY
			SELECT * FROM Notices 
			WHERE uid = u_id_param AND (notice_category = 1 OR notice_category = 2 OR notice_category = 6);
		ELSEIF (notice_category_param = 2) THEN
			RETURN QUERY
			SELECT * FROM Notices 
			WHERE uid = u_id_param AND (notice_category = 3 OR notice_category = 4 OR notice_category = 5 OR notice_category = 7);
		ELSEIF (notice_category_param = 3) THEN
			RETURN QUERY
			SELECT * FROM Notices 
			WHERE uid = u_id_param AND notice_category = 9;
		ELSEIF (notice_category_param = 4) THEN
			RETURN QUERY
			SELECT * FROM Notices 
			WHERE uid = u_id_param AND notice_category = 8;
		END IF;
	END; $$
LANGUAGE plpgsql;

------热榜视图（周榜）
create view hotlist as
   select *
   from Video
   where v_create_date >= current_date - integer'7'    ----当前日期减7
   order by 
   oppose_count+bullet_screen_count+comments_count DESC,like_count+insert_coin_count+favorite_count DESC;
   
   
-----查看热榜函数，输入一个数字表示要查看最近几天的热榜     
create or replace function hotlist(ranges integer) returns setof Video 
as $$
declare
r Video%rowtype;          
begin
   for r in
   select *
   from Video
   where v_create_date >= current_date - ranges   
   order by 
   oppose_count+bullet_screen_count+comments_count DESC,like_count+insert_coin_count+favorite_count DESC
   LOOP
     return next r; 
   END LOOP;
return;
end;
$$ language plpgsql;

----周榜
select* from hotlist(7);

----查看个人作品表函数，按日期排序，输入作者id进行查询
create or replace function personal_video(Uploader VARCHAR) returns setof Video 
as $$
declare
r Video%rowtype;          
begin
   for r in
   select *
   from Video
   where username = Uploader
   order by 
   v_create_date DESC
   LOOP
     return next r; 
   END LOOP;
return;
end;
$$ language plpgsql;





-----建立索引
CREATE UNIQUE INDEX index_uid on Users (uid);
CREATE UNIQUE INDEX index_username on Users (username);
CREATE UNIQUE INDEX index_vid on Video (vid);
CREATE INDEX index_title on Video (title);
CREATE INDEX index_category on Video (category);
CREATE UNIQUE INDEX index_cid on contribute (contribute_id);
CREATE UNIQUE INDEX index_rid on report (report_id);


INSERT INTO Video_category(Category_name, Category_introduction) VALUES ('movie', '电影');
INSERT INTO Video_category(Category_name, Category_introduction) VALUES ('life', '生活');
INSERT INTO Video_category(Category_name, Category_introduction) VALUES ('vlog', '微日志');
