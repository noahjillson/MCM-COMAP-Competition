#' Dynamic Match Win Prediction
#'
#' This function calculates the match win prediction for matches in progress based on the current score and the in-match server performance
#'
#' @param point_a Numeric game points won by current server at start of point
#' @param point_b Numeric game points won by current returner at start of point
#' @param game_a Numeric games won by current server in the current set
#' @param game_b Numeric games won by current returner in the current set
#' @param set_a Numeric sets won by current server
#' @param set_b Numeric sets won by current returner
#' @param server.prob Numeric serve win prob of current server
#' @param return.prob Numeric serve win prob of current returner
#' @param server.serve.points.won Numeric total service points won in match up to current point
#' @param server.serve.points Numeric total service points played in match up to current point
#' @param returner.serve.points.won Numeric total service points won in match up to current point
#' @param returner.serve.points  Numeric total service points played in match up to current point
#' @param bestof3 Logical indicator if best-of-3 match (TRUE) or best-of-5 (FALSE)
#' @param advantage Logical if advantage set match (TRUE) or tiebreak match (FALSE)
#'
#' @export
dynamic_in_match_win <- function (point_a, point_b, game_a, game_b, set_a, set_b, server.prob, returner.prob, server.serve.points.won, server.serve.points, returner.serve.points.won, returner.serve.points, bestof3 = TRUE, advantage = TRUE) 
{
		
		match_win <- function (point_a, point_b, game_a, game_b, set_a, set_b, server.prob, returner.prob, bestof3 = TRUE, advantage = TRUE) 
	{
		
		# Fixes for out of bounds scores
		iid_player_probs_lookup <- function(pa, pb, advantage){
		
			pa <- max(c(pa, 0.5))
			pb <- max(c(pb, 0.5))
		
			pa <- min(c(pa, 0.99))
			pb <- min(c(pb, 0.99))
				
			p1 <- as.character(round(pa, 2))
			p2 <- as.character(round(pb, 2))
			
			id1 <- paste(p1, p2, sep = ":")
			id2 <- paste(p2, p1, sep = ":")
				
			gameA_mat <- regular_game_matrices[[p1]]
			gameB_mat <- regular_game_matrices[[p2]]
			
			tbgameA_mat <- tiebreak_game_matrices[[id1]]
			tbgameB_mat <- tiebreak_game_matrices[[id2]]
			
			settbgameA_mat <- set_win_tiebreak[[id1]]
			settbgameB_mat <- set_win_tiebreak[[id2]]
			
			setadvgameA_mat <- set_win_advantage[[id1]]
			setadvgameB_mat <- set_win_advantage[[id2]]
			
			MA <- advantage_matches[[id1]]
			MB <- advantage_matches[[id2]]
			
		
		list(A = list(game = gameA_mat, tiebreak = tbgameA_mat, set_tiebreak = settbgameA_mat, set_advantage = setadvgameA_mat, match = MA), 
			B = list(game = gameB_mat, tiebreak = tbgameB_mat, set_tiebreak = settbgameB_mat, set_advantage = setadvgameB_mat, match = MB)
			)
		}
		
	    matrices <- iid_player_probs_lookup(server.prob, returner.prob, advantage)
	    
	    serving_player <- 1
	    returning_player <- 2
	    
	    max.sets <- ifelse(bestof3, 3, 5)
	    
	    
	    is.tiebreak <- (game_a == 6 & game_b == 6 & advantage & set_a + 
	        set_b + 1 != max.sets) | (game_a == 6 & game_b == 6 & 
	        !advantage)
	    
	      
	    invalid.score <- FALSE
	    playera.won <- FALSE
	    playerb.won <- FALSE
	    
	    # Boundary cases for points
	    if(!is.tiebreak){
	    	if(point_a >= 3 & point_b >= 3){
	    		if(point_a == point_b){
	    			point_a <- 3
	    			point_b <- 3
	    		}	
		    	else if(point_a > point_b){
	    			point_a <- 3
	    			point_b <- 2
	    		}
	    		else{
	    			point_a <- 2
	    			point_b <- 3
	    		}
	    	}    	
	    	if((point_a >= 4 & point_b < 3) | (point_b >= 4 & point_a < 3))
	    		invalid.score <- TRUE
	    } 
	    else{
	     	if(point_a >= 6 & point_b >= 6){
	    		if(point_a == point_b){
	    			point_a <- 6
	    			point_b <- 6
	    		}	
		    	else if(point_a > point_b){
	    			point_a <- 6
	    			point_b <- 5
	    		}
	    		else{
	    			point_a <- 5
	    			point_b <- 6
	    		}
	    	}    	
	    	if((point_a >= 7 & point_b < 6) | (point_b >= 7 & point_a < 6))
	    		invalid.score <- TRUE   	
	    }
	    
	    
	    # Boundary cases for game
	    if(set_a + set_b + 1 == max.sets & advantage){
	    	if(game_a >= 5 & game_b >= 5){
	    		if(game_a == game_b){
	    			game_a <- 5
	    			game_b <- 5
	    		}
	    		else if(game_a > game_b){
	    			game_a <- 5
	    			game_b <- 4
	    		}
	    		else{
	     			game_a <- 4
	    			game_b <- 5   			
	    		}
	    	}	
	    	if((game_a >= 6 & game_b <= 4) | (game_b >= 6 & game_a <= 4))
	    		invalid.score <- TRUE
	    }   
	    else{	
	    	if((game_a >= 6 & game_b <= 4) | (game_b >= 6 & game_a <= 4))
	    		invalid.score <- TRUE    	
	    } 
	    
	    # Boundary for sets
	    if(bestof3){
	    	
	    	if(set_a >= 2 & set_b >= 2)
	    		invalid.score <- TRUE
	    	
	    	if(set_a == 2 & set_b <= 1)
	    		playera.won <- TRUE
		    	
		    	if(set_b == 2 & set_a <= 1)
		    		playerb.won <- TRUE	    		
	    		
	    }
	    else{
	     	if(set_a >= 3 & set_b >= 3)
	    		invalid.score <- TRUE  
		    	
	    		if(set_a == 3 & set_b <= 2)
	    			playera.won <- TRUE
		    	
		    	if(set_b == 3 & set_a <= 2)
		    		playerb.won <- TRUE	     	 	
	    }
	    
	    
	    if(playera.won)
	    		return(1)
	    
	    if(playerb.won)
	    		return(0)
	    
	    if(invalid.score)
	   	 	return(NA)
	    
	    else{
	    
		    if (max.sets == 3) {
		        matrices[[1]]$match <- matrices[[1]]$match[2:nrow(matrices[[1]]$match), 
		            2:nrow(matrices[[1]]$match)]
		        matrices[[2]]$match <- matrices[[2]]$match[2:nrow(matrices[[2]]$match), 
		            2:nrow(matrices[[2]]$match)]
		    }
		    win_loss <- function(win_game = TRUE, win_set = TRUE, point_a, 
		        point_b, game_a, game_b, set_a, set_b, max.sets = 3, 
		        advantage, is.tiebreak, serving_player, returning_player, 
		        matrices) {
		        winning_game <- function(point_a, point_b, win_game, 
		            is.tiebreak, matrices) {
		            if (is.tiebreak & win_game) {
		                if (point_a + point_b%%4 %in% c(0, 3)) 
		                  part1 <- matrices[[serving_player]]$tiebreak[(point_a + 
		                    1), (point_b + 1)]
		                else part1 <- 1 - matrices[[returning_player]]$tiebreak[(point_b + 
		                  1), (point_a + 1)]
		            }
		            else if (!is.tiebreak & win_game) 
		                part1 <- matrices[[serving_player]]$game[(point_a + 
		                  1), (point_b + 1)]
		            else if (is.tiebreak & !win_game) {
		                if (point_a + point_b%%4 %in% c(0, 3)) 
		                  part1 <- 1 - matrices[[serving_player]]$tiebreak[(point_a + 
		                    1), (point_b + 1)]
		                else part1 <- matrices[[returning_player]]$tiebreak[(point_b + 
		                  1), (point_a + 1)]
		            }
		            else part1 <- 1 - matrices[[serving_player]]$game[(point_a + 
		                1), (point_b + 1)]
		            part1
		        }
		        winning_set <- function(game_a, game_b, win_set, is.tiebreak, 
		            advantage, matrices, returning_player, max.sets) {
		            if (is.tiebreak) {
		                part2 <- 1
		            }
		            else if (win_set) {
		                if (!advantage | advantage & set_a + set_b + 
		                  1 != max.sets) 
		                  part2 <- 1 - matrices[[returning_player]]$set_tiebreak[(game_b + 
		                    1), (game_a + 1)]
		                else part2 <- 1 - matrices[[returning_player]]$set_advantage[(game_b + 
		                  1), (game_a + 1)]
		            }
		            else {
		                if (!advantage | advantage & set_a + set_b + 
		                  1 != max.sets) 
		                  part2 <- matrices[[returning_player]]$set_tiebreak[(game_b + 
		                    1), (game_a + 1)]
		                else part2 <- matrices[[returning_player]]$set_advantage[(game_b + 
		                  1), (game_a + 1)]
		            }
		            part2
		        }
		        winning_match <- function(set_a, set_b, max.sets, serving_player) {
		            if (max.sets == 3 & set_a >= 2 & set_b <= 1 | max.sets == 
		                5 & set_a >= 3 & set_b <= 2) 
		                part3 <- 1
		            else if (max.sets == 3 & set_b >= 2 & set_a <= 1 | 
		                max.sets == 5 & set_b >= 3 & set_a <= 2) 
		                part3 <- 0
		            else part3 <- matrices[[serving_player]]$match[(set_a + 
		                1), (set_b + 1)]
		            part3
		        }
		        part1 <- winning_game(point_a = point_a, point_b = point_b, 
		            win_game = win_game, is.tiebreak = is.tiebreak, matrices = matrices)
		        if (win_game & win_set & game_a == 6 & game_b <= 5) {
		            part2 <- 1
		            part3 <- winning_match(set_a = set_a + 1, set_b = set_b, 
		                max.sets = max.sets, serving_player = serving_player)
		        }
		        else if (win_game & !win_set & game_a == 6 & game_b <= 
		            5) {
		            part2 <- 0
		            part3 <- 0
		        }
		        else if (!win_game & win_set & game_b == 6 & game_a <= 
		            5) {
		            part2 <- 0
		            part3 <- 0
		        }
		        else if (!win_game & !win_set & game_b == 6 & game_a <= 
		            5) {
		            part2 <- 1
		            part3 <- winning_match(set_a = set_a, set_b = set_b + 
		                1, max.sets = max.sets, serving_player = serving_player)
		        }
		        else if (win_game) {
		            part2 <- winning_set(game_a = game_a + 1, game_b = game_b, 
		                win_set = win_set, is.tiebreak = is.tiebreak, 
		                advantage = advantage, matrices = matrices, returning_player = returning_player, 
		                max.sets = max.sets)
		            if (win_set) 
		                part3 <- winning_match(set_a = set_a + 1, set_b = set_b, 
		                  max.sets = max.sets, serving_player = serving_player)
		            else part3 <- winning_match(set_a = set_a, set_b = set_b + 
		                1, max.sets = max.sets, serving_player = serving_player)
		        }
		        else {
		            part2 <- winning_set(game_a = game_a, game_b = game_b + 
		                1, win_set = win_set, is.tiebreak = is.tiebreak, 
		                advantage = advantage, matrices = matrices, returning_player = returning_player, 
		                max.sets = max.sets)
		            if (win_set) 
		                part3 <- winning_match(set_a = set_a + 1, set_b = set_b, 
		                  max.sets = max.sets, serving_player = serving_player)
		            else part3 <- winning_match(set_a = set_a, set_b = set_b + 
		                1, max.sets = max.sets, serving_player = serving_player)
		        }
		        part1 * part2 * part3
		    }
		    if (is.tiebreak) {
		        type1 <- win_loss(TRUE, TRUE, point_a, point_b, game_a, 
		            game_b, set_a, set_b, max.sets = max.sets, serving_player = serving_player, 
		            returning_player = returning_player, matrices = matrices, 
		            advantage = advantage, is.tiebreak = TRUE)
		        type3 <- win_loss(FALSE, FALSE, point_a, point_b, game_a, 
		            game_b, set_a, set_b, max.sets = max.sets, serving_player = serving_player, 
		            returning_player = returning_player, matrices = matrices, 
		            advantage = advantage, is.tiebreak = TRUE)
		        type1 + type3
		    }
		    else {
		        type1 <- win_loss(TRUE, TRUE, point_a, point_b, game_a, 
		            game_b, set_a, set_b, max.sets = max.sets, serving_player = serving_player, 
		            returning_player = returning_player, matrices = matrices, 
		            advantage = advantage, is.tiebreak = is.tiebreak)
		        type3 <- win_loss(TRUE, FALSE, point_a, point_b, game_a, 
		            game_b, set_a, set_b, max.sets = max.sets, serving_player = serving_player, 
		            returning_player = returning_player, matrices = matrices, 
		            advantage = advantage, is.tiebreak = is.tiebreak)
		        type2 <- win_loss(FALSE, TRUE, point_a, point_b, game_a, 
		            game_b, set_a, set_b, max.sets = max.sets, serving_player = serving_player, 
		            returning_player = returning_player, matrices = matrices, 
		            advantage = advantage, is.tiebreak = is.tiebreak)
		        type4 <- win_loss(FALSE, FALSE, point_a, point_b, game_a, 
		            game_b, set_a, set_b, max.sets = max.sets, serving_player = serving_player, 
		            returning_player = returning_player, matrices = matrices, 
		            advantage = advantage, is.tiebreak = is.tiebreak)
		        type1 + type2 + type3 + type4
		    }
	  }
	}

	update_score <- function(pointa, pointb, gamea, gameb, seta, setb, advantage, bestof3){
		
		tiebreak.set <- !advantage | (seta + setb + 1) != ifelse(bestof3, 3, 5)
		
		is.tiebreak <- (gamea + gameb) == 12 & (!advantage | (seta + setb + 1) != ifelse(bestof3, 3, 5))
		
		serve.changed <- FALSE
		
		is.game.won <- function(pointa, pointb, is.tiebreak){
			
			if(is.tiebreak)
				pointa >= 7 & pointb <= 5
			else
				pointa >= 4 & pointb <= 2
		}
		
		is.set.won <- function(gamea, gameb, tiebreak.set){
			
			if(tiebreak.set)
				gamea == 6 & gameb <= 4 | gamea == 7 & gameb <= 6 
			else
				gamea == 6 & gameb <= 4 | gamea == 7 & gameb <= 5
		}
		
			
		if(is.game.won(pointa, pointb, is.tiebreak)){
			pointa <- 0
			pointb <- 0
			gamea <- gamea + 1
			serve.changed <- TRUE
		}
		
		if(pointa == 7 & pointb == 6 & is.tiebreak){
			pointa <- 6
			pointb <- 5
		}

		if(pointa == 6 & pointb == 7 & is.tiebreak){
			pointa <- 5
			pointb <- 6
		}

		if(pointa == 4 & pointb == 3 & !is.tiebreak){
			pointa <- 3
			pointb <- 2
		}

		if(pointa == 3 & pointb == 4 & !is.tiebreak){
			pointa <- 2
			pointb <- 3
		}
						
		if(is.game.won(pointb, pointa, is.tiebreak)){
			pointa <- 0
			pointb <- 0
			gameb <- gameb + 1
			serve.changed <- TRUE
		}
		
			
		if(is.set.won(gamea, gameb, tiebreak.set)){
			gamea <- 0
			gameb <- 0
			seta <- seta + 1
		}
			
		if(is.set.won(gameb, gamea, tiebreak.set)){
			gamea <- 0
			gameb <- 0
			setb <- setb + 1
		}	
		
		
		data.frame(
			pointa = pointa, 
			pointb = pointb, 
			gamea = gamea, 
			gameb = gameb, 
			seta = seta,
			setb = setb,
			serve.changed = serve.changed
		)
	}

	assign.weight <- function(points){
		 if(points > 30){
				W <- 50 / (50 + points)
			}
		else{		
				W <- (50 + (30 - points)) / (50 + (30 - points) + points)	
			}
		W
	}

		W <- assign.weight(server.serve.points)
		
		if(server.serve.points != 0){
			W1 <- assign.weight(server.serve.points + 1)
			server.prob1 <- W1 * server.prob + (1 - W1) * (server.serve.points.won + 1) /(server.serve.points + 1)

			W0 <- assign.weight(server.serve.points + 1)
			server.prob0 <- W0 * server.prob + (1 - W0) * (server.serve.points.won + 0) /(server.serve.points + 1)

			server.prob <- W * server.prob + (1 - W) * server.serve.points.won/server.serve.points
		}
		else{
			server.prob1 <- server.prob0 <- server.prob	
		}
	
		W <- assign.weight(returner.serve.points)
			
		if(returner.serve.points != 0)
			returner.prob <- W * returner.prob + (1 - W) * returner.serve.points.won/returner.serve.points


	
	win <- match_win(
		point_a,
		point_b,
		game_a,
		game_b,
		set_a,
		set_b,
		server.prob,
		returner.prob,
		bestof3,
		advantage
		)

data.frame(
	server_win = win, 
	serve_updating = server.prob
	)
}