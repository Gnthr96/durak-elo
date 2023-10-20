# Durak - Elo computation
## What is the idea behind the Elo calculation?
The idea, applied to chess is taken from here: https://gwern.net/doc/statistics/order/comparison/1978-elo-theratingofchessplayerspastandpresent.pdf
This is also helpful, although maybe a bit overkill: https://www.microsoft.com/en-us/research/wp-content/uploads/2007/01/NIPS2006_0688.pdf


We decode the result of a match by assigning 1 to the loser and 0 to the winner(s)/non-loser(s). After every match, we update every player's score according to the formula
          new_score = old_score + K*(expected_result - result),
where we fix K = 32. The expected result is equal to the losing probability, i.e. some value between 0 and 1. Therefore a loser (result = 1) decreases his score and a winner (result = 0) increases his score.



To compute the expected result, we assume that player i's performance is described by a normal distribution X_i around his Elo-score mu_i, independent of all other players. The standard deviation is fixed at sigma = 200.

The probability for player i to lose in a match against n opponents is now determined by the probability that his performance is lower than that of all other players, i.e. X_i < X_j for all participating players j = 1, ..., n.

We can also express that event as X_i - X_j < 0 for all j= 1, ..., n. We know that X_i - X_j is normally distributed with mean m_i = mu_i - mu_j and variance 2*sigma^2. Furthermore, Cov(X_i - X_j, X_i - X_k) = sigma^2 for all j /= k.

Thus, we can calculate the losing probability as F(0,0,...,0), where F is the cdf of a n-dimensional multivariate normal distribution with mean m and covariance matrix S. S is a matrix with diagonal entries 2*sigma^2 and all other entries sigma^2.
