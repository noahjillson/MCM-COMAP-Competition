#' Calibrates Serve Probabilities
#'
#' This function calculates the player expected probability of winning a point on serve given their match win prediction.
#'
#' @param win Numeric value between 0 and 1 that is the player's expected win percentage
#' @param atp Logical indicating whether the match is for the ATP or WTA
#' @param bestof3 Logical indicating whether the match is a best of 3 (TRUE) or best of 5 (FALSE) format
#' @param bestof3 Logical indicating whether the match has an advantage final set or not
#'
#' @export
calibrate_serve <- function(win, atp = TRUE, bestof3 = TRUE, advantage = TRUE){

	# Dependent function that calculates match win from iid model
	match_win <- function(p, q){
		in_match_win(0, 0, 0, 0, 0, 0, server = p, returner = q, bestof3 = bestof3, advantage = advantage)$server_win
	}
	
	if(win < .5 & atp){
		f <- function(p) match_win(p, 1 - (p - .25)) - (1 - win)
		result <- tryCatch(uniroot(f, interval = c(0.5, 1))$root, error = function(x) NA)
	c(1 - (result - .25), result)
	}
	else if (win >= 0.5 & atp){
		f <- function(p) match_win(p, 1 - (p - .25))  - win
		result <- tryCatch(uniroot(f, interval = c(0.5, 1))$root, error = function(x) NA)
	c(result, 1 - (result - .25))
	}	
	else if(win < .5 & !atp)	{
		f <- function(p) match_win(p, 1 - (p - .15))  - (1 - win)
		result <- tryCatch(uniroot(f, interval = c(0.5, 1))$root, error = function(x) NA)
	c(1 - (result - .15), result)
	}
	else{
		f <- function(p) match_win(p, 1 - (p - .15))  - win
		result <- tryCatch(uniroot(f, interval = c(0.5, 1))$root, error = function(x) NA)
	c(result, 1 - (result - .15))
	}
}