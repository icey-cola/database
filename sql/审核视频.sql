UPDATE Contribute SET contribute_result = 1 WHERE contribute_id = (SELECT contribute_id FROM Contribute WHERE title = '不要笑挑战');
UPDATE Contribute SET contribute_result = 1 WHERE contribute_id = (SELECT contribute_id FROM Contribute WHERE title = '中途岛');
UPDATE Contribute SET contribute_result = 1 WHERE contribute_id = 2;
UPDATE Contribute SET contribute_result = 1 WHERE contribute_id = 3;
UPDATE Contribute SET contribute_result = 1 WHERE contribute_id = 4;
SELECT * FROM Contribute