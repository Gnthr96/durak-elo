library(mvtnorm)
library(reshape2)

###
###global parameters:
###
initial_points = 1000         #initial points for every player
sigma = 200                   #assigned standard deviation to the performance of each player
K = 32                        #update weight --> how much is the last result worth?


get_losing_probs = function(players, score){
  ###
  ###takes indices or names of players and returns the probability for each player to
  ###lose in this configuration 
  ###
  if(typeof(players) == "character"){
    players = match(players, colnames(data))
  }
  n = length(players)
  SIGMA = matrix(sigma^2, nrow = n-1, ncol = n-1)
  diag(SIGMA) = 2*sigma^2
  probs = sapply(1:n, function(i) pmvnorm(upper = rep(0,n-1),
    mean = score[players[i]]-score[players[-i]], sigma = SIGMA))
  return(probs)
}

get_streaks = function(data){
  ###
  ### calculates longest winning & losing streaks as well as the current winning streak
  ###
  res = data.frame(losing_streak = rep(NA, ncol(data)), winning_streak = NA, current_winning_streak = NA)
  rownames(res) = colnames(data)
  for(i in 1:ncol(data)){#loop through all players, one at a time
    temp_hist = data[!is.na(data[,i]),i]                          #history of player i (only matches that have been played)
    temp = diff(c(0,which(diff(temp_hist)!=0),length(temp_hist)))
    temp = temp*(-1)**(0:(length(temp)-1)-temp_hist[1])
    res$losing_streak[i] = -min(temp)
    res$winning_streak[i] = max(temp)
    res$current_winning_streak[i] = temp[length(temp)]
  }
  return(pmax(res,0))
}

calculate_history = function(data){#data comes from csv-file containing one match per row, loser=1, winners = 0, rest = NA
  ###
  ### calculates elo score based on recorded results in csv file
  ###
  history = rbind(initial_points, data) #initial state + one match per row, every row contains elo-score after that match
  
  for(i in 1:nrow(data)){#loops through all matches that have been played
    players = which(!is.na(data[i,]))                                     #players in i-th match
    match = as.matrix(data[i,players])                                    #result of i-th match
    losing_probs = get_losing_probs(players, as.matrix(history[i,]))      #probability to lose based on elo-score after ((i-1)-th match)
    history[i+1,] = history[i,]                                           #elo score remains the same for those who didn´t play.
    history[i+1,players] = history[i,players] + K*(losing_probs - match)  #update elo score for participating players
  }
  
  history$match_id = 1:nrow(history)
  
  present_table = cbind(t(history[nrow(history),colnames(data)]), get_streaks(data))
  present_table$total_games = colSums(!is.na(data))
  present_table$total_losses = colSums(data, na.rm = TRUE)
  present_table$loss_ratio = present_table$total_losses/present_table$total_games
  present_table = present_table[order(as.matrix(history[nrow(history),colnames(data)]), decreasing = TRUE),]
  
  return(list("present_table" = present_table, "history" = history))
}
