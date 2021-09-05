CREATE TABLE `data_607`.`movie_preferences` (
  `movie_name` VARCHAR(100) NOT NULL,
  `respondent_1` INT NULL,
  `respondent_2` INT NULL,
  `respondent_3` INT NULL,
  `respondent_4` INT NULL,
  `respondent_5` INT NULL,
  PRIMARY KEY (`movie_name`));


INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Honey I Shrunk The Kids', 3,2,1,1,1);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Good Will Hunting', 4,5,4,NULL,3);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Catch Me If You Can', 3,4,5,NULL,NULL);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Freaky Friday', 3,1,2,5,4);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Lord Of The Rings 2', 1,1,5,1,3);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Harry Potter 1', 5,1,2,5,3);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('Black Widow', NULL,NULL,NULL,NULL,NULL);

INSERT INTO data_607.movie_preferences (
movie_name, respondent_1, respondent_2, respondent_3, respondent_4, respondent_5) VALUES ('1917', 5,NULL,5,NULL,3);
