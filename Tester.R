# Calibrate the pre-game win probability
calibrate_serve(73.33/100, TRUE, FALSE, TRUE)

# Import the sample match
sample_match <- read.csv("Finale.csv")
server <- sample_match[['server']]
point_p1 <- sample_match[['point_p1']]
point_p2 <- sample_match[['point_p2']]
p1_games <- sample_match[['p1_games']]
p2_games <- sample_match[['p2_games']]
p1_sets <- sample_match[['p1_sets']]
p2_sets <- sample_match[['p2_sets']]
p1_serve_prob <- sample_match[['p1_serve_prob']]
p2_serve_prob <- sample_match[['p2_serve_prob']]
p1_serve_points_won <- sample_match[['p1_serve_points_won']]
p1_serve_points_played <- sample_match[['p1_serve_points_played']]
p2_serve_points_won <- sample_match[['p2_serve_points_won']]
p2_serve_points_played <- sample_match[['p2_serve_points_played']]



# Perform the match-win probability predictor at each point
results <- vector("list", nrow(sample_match))

for (i in 1:nrow(sample_match)) {
  # Identify the server and returner
  if (server[i] == 1) {
    results[i] <- dynamic_in_match_win(point_p1[i], point_p2[i], p1_games[i], p2_games[i], p1_sets[i], p2_sets[i], p1_serve_prob[i], p2_serve_prob[i], p1_serve_points_won[i], p1_serve_points_played[i], p2_serve_points_won[i], p2_serve_points_played[i], FALSE, TRUE)[1]
  } else {
    results[i] <- dynamic_in_match_win(point_p2[i], point_p1[i], p2_games[i], p1_games[i], p2_sets[i], p1_sets[i], p2_serve_prob[i], p1_serve_prob[i], p2_serve_points_won[i], p2_serve_points_played[i], p1_serve_points_won[i], p1_serve_points_played[i], FALSE, TRUE)[1]
  }
  
}

results_vector <- unlist(results)

win_prob = matrix(NA, nrow = nrow(sample_match), ncol = 2)
for (i in 1:nrow(sample_match)) {
  if (server[i] == 1) {
    win_prob[i, 1] = results_vector[i]
    win_prob[i, 2] = 1 - results_vector[i]
  } else {
    win_prob[i, 1] = 1 - results_vector[i]
    win_prob[i, 2] = results_vector[i]
  }
}

write.csv(x = win_prob, file = "finals_win_prob.csv", row.names = TRUE)


# Compute the leverage
leverage <- matrix(NA, nrow=nrow(sample_match), ncol = 1)

for (i in 1:nrow(sample_match)) {
  next_server = server[i]
  # Scenario when player 1 wins
  point_a = point_p1[i]+1
  point_b = point_p2[i]
  game_a = p1_games[i]
  game_b = p2_games[i]
  set_a = p1_sets[i]
  set_b = p2_sets[i]
  server.prob = p1_serve_prob[i]
  returner.prob = p2_serve_prob[i]
  server.serve.points.won = p1_serve_points_won[i] + 1
  server.serve.points = p1_serve_points_played[i] + 1
  returner.serve.points.won = p2_serve_points_won[i]
  returner.serve.points = p2_serve_points_played[i] + 1
  
  # Check for game winners
  if (point_a - point_b >= 2) {
    if (game_a == 6 & game_b == 6) {
      if (set_a == 2 & set_b == 2) {
        if (point_a >= 10) {
          set_a = set_a + 1
          game_a = 0
          game_b = 0
          point_a = 0
          point_b = 0
          next_server = 3 - next_server
        } 
      } else {
        if (point_a >= 7) {
          set_a = set_a + 1
          game_a = 0
          game_b = 0
          point_a = 0
          point_b = 0
          next_server = 3 - next_server
        }
      }
    } else {
      if (point_a >= 4) {
        game_a = game_a + 1
        point_a = 0
        point_b = 0
        print("yes")
        print(next_server)
        next_server = 3 - next_server
        print(next_server)
        
        if (game_a == 6 & game_b <= 4) {
          set_a = set_a + 1
          game_a = 0
          game_b = 0
        }  
      }
    }
  }
  
  # Checks for server
  if (next_server == 1) {
    prob_p1_win <- dynamic_in_match_win(point_a, point_b, game_a, game_b, set_a, set_b, server.prob, returner.prob, server.serve.points.won, server.serve.points, returner.serve.points.won, returner.serve.points, FALSE, TRUE)[1]
  } else {
    prob_p1_win <- 1 - dynamic_in_match_win(point_b, point_a, game_b, game_a, set_b, set_a, returner.prob, server.prob, returner.serve.points.won, returner.serve.points, server.serve.points.won, server.serve.points, FALSE, TRUE)[1]
  }
  
  next_server = server[i]
  # Scenario when player 2 wins
  point_a = point_p1[i]
  point_b = point_p2[i]+1
  game_a = p1_games[i]
  game_b = p2_games[i]
  set_a = p1_sets[i]
  set_b = p2_sets[i]
  server.prob = p1_serve_prob[i]
  returner.prob = p2_serve_prob[i]
  server.serve.points.won = p1_serve_points_won[i]
  server.serve.points = p1_serve_points_played[i] + 1
  returner.serve.points.won = p2_serve_points_won[i] + 1
  returner.serve.points = p2_serve_points_played[i] + 1
  
  # Check for game winners
  if (point_b - point_a >= 2) {
    if (game_a == 6 & game_b == 6) {
      if (set_a == 2 & set_b == 2) {
        if (point_b >= 10) {
          set_b = set_b + 1
          game_a = 0
          game_b = 0
          point_a = 0
          point_b = 0
          next_server = 3 - next_server
        } 
      } else {
        if (point_b >= 7) {
          set_b = set_b + 1
          game_a = 0
          game_b = 0
          point_a = 0
          point_b = 0
          next_server = 3 - next_server
        }
      }
    } else {
      if (point_b >= 4) {
        game_b = game_b + 1
        point_a = 0
        point_b = 0
        next_server = 3 - next_server
        
        if (game_b == 6 & game_a <= 4) {
          set_b = set_b + 1
          game_a = 0
          game_b = 0
          point_a = 0
          point_b = 0
        }  
      }
    }
  }
  
  # Checks for server
  if (next_server == 1) {
    prob_p1_loss <- dynamic_in_match_win(point_a, point_b, game_a, game_b, set_a, set_b, server.prob, returner.prob, server.serve.points.won, server.serve.points, returner.serve.points.won, returner.serve.points, FALSE, TRUE)[1]
  } else {
    prob_p1_loss <- 1 - dynamic_in_match_win(point_b, point_a, game_b, game_a, set_b, set_a, returner.prob, server.prob, returner.serve.points.won, returner.serve.points, server.serve.points.won, server.serve.points, FALSE, TRUE)[1]
  }    
  leverage[i] <- prob_p1_win - prob_p1_loss

}

write.csv(x = leverage, file = "finals_player1_leverage.csv", row.names = TRUE)
leverage
