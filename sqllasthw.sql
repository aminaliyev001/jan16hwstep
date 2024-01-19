--EN : Similarly with posts. When an evaluation of the post is made, 
--it is necessary to recalculate the rating of the post and the rating of the user who wrote this post.

ALTER PROC task3
@idpost  INT,
@iduser  INT,
@rating	 INT
AS BEGIN
	BEGIN TRAN tr1
		INSERT INTO PostRating (IdPost, IdUser, Mark) VALUES (@idpost, @iduser, @rating)
		IF(@@ERROR != 0)
			BEGIN
				PRINT('ERROR')
				ROLLBACK TRAN tr1
			END
		ELSE
			BEGIN
				PRINT('inserted successfully ()')
				UPDATE Posts SET Rating = (SELECT CAST(SUM(PostRating.Mark) AS FLOAT) / COUNT(PostRating.Mark) FROM PostRating WHERE PostRating.IdPost = @idpost AND PostRating.IdUser = @iduser)
				WHERE Posts.Id = @idpost
				IF(@@ERROR != 0)
					BEGIN 
						PRINT('ERROR')
						ROLLBACK TRAN tr1
					END
				ELSE 
					BEGIN 
						UPDATE Users SET Users.Rating = (
						SELECT CAST(SUM(Mark) AS FLOAT) / COUNT(Mark)
						FROM (SELECT P.Mark FROM PostRating P WHERE P.IdUser = @iduser UNION ALL 
						SELECT C.Mark FROM CommentRating C WHERE C.IdUser = @iduser
						) AS CR )		
						WHERE Users.Id = @iduser
						IF(@@ERROR != 0)
							BEGIN
								PRINT('error in the updating the user rating (')
								ROLLBACK TRAN tr1
							END
						ELSE 
							BEGIN
								PRINT('hamisi icra olundu...')
								COMMIT TRAN tr1
							END
					END
			END
			
	END

EXEC task3 2,2,7

			