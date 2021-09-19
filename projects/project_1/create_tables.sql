CREATE TABLE data_607.players (
  id int NOT NULL,
  player_name varchar(100) NOT NULL,
  player_state varchar(25) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE data_607.scores (
  unique_id int AUTO_INCREMENT NOT NULL,
  tournament_id int NOT NULL,
  player_id int NOT NULL,
  number_of_games int DEFAULT NULL,
  total float DEFAULT NULL,
  expected_total float DEFAULT NULL,
  pre_score int DEFAULT NULL,
  avg_opponent_score int DEFAULT NULL,
  PRIMARY KEY (unique_id),
  FOREIGN KEY (player_id) REFERENCES players(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;