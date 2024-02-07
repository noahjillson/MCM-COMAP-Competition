# Quantifying Momentum in Tennis
This repository provides implementations of and data pertaining to the models created as a part of the Mathematics Competition in Modelling (MCM) run by the Consortium for Mathematics and its Applications (COMAP).Below provides a breif description of out model and necessary terms.

Momentum is sports matches tends to take on a multitude of definitions depending on the context of its use. In some sense, it has become a "catch-all" in sports media and is often used when teams begin to take control of the match. However, it is difficult to build models to quantify this phenomenon when it has such an elusive definition. Thus the next section of this Readme is focused on defining this sporting term.

## Leverage and Momentum
Before we can define momentum in the context of tennis matches, we will need to define the concept of leverage and some supporting notation. We will let $S_{m}$ denote the score sequence up to the $m^{\text{th}}$ point, $s_i$ be the $i^{\text{th}}$ point of the match, and $M$ be the random variable describing wether a player wins the match. With this we define leverage, denoted $\ell$, to be the difference between the match win probability that the given player wins the next point and the match win probability that the given player loses the next point. Thus, leverage is given by the following.

$$
\begin{equation}
\ell_t =   P(M=1 | s_t = 1) - P(M=1 | s_t = 0)
\end{equation}
$$

With leverage, we then define momentum to be exponentially weighted sum of leverages accross the match.

$$
\begin{equation}
\mathcal{M_t} =  \frac{\ell_t + (1-\alpha)\ell_{t-1} + (1-\alpha)^2\ell_{t-1} + \dots + (1-\alpha)^t\ell_0}{1 + (1-\alpha) + (1-\alpha)^2 + \dots + (1-\alpha)^t}
\end{equation}
$$

where $\alpha$ is a smoothing factor that determines the important with wich we consider past events.

Thus, as long as we can accurately predict the outcome of a match given then next point, we can quantify momentum. Of course, this is a whole other problem which must be solve and to which we provide yet another model described later.

## Interpreting Momentum
Using this definition of momentum results in some interesting and rather unintuitive artifacts when alayzing matches. When a match is close, every point matters and so we expect to see rallies that end in high momentum for a particular player. However, matches that are blowouts tend to have little to no momentum. At first this may seem like an inaccuracy in the model implementation, but it is in fact what we would expect given our model definition. Once a player has built an incredible lead in the match, the result of a single rally has little to no effect on the outcome of the match. Thus leverage remains small, and momentum as a function of leverage does as well.

So if momentum does not provide a way to determine who is winning the match, what exactly is it? Taking a step back, momentum can be understood as an indicator for high importance rallies in tennis matches. A moment in the match exhibiting high momentum indicates that the probability of a player winning the match is significantly changing. Over the non-differentiable function of match win probability, momentum provides an understanding of change and the rate with which it is happening.

Thus momentum tells us who is taking control of the match. Match win probability already exists as a metric to determine who is in control of the match. Making this distinction between the two is important in interpreting momentum and making good use of it.

## Results
---
![Alcaraz Vs Djokovic Momentum](figures/AvD_momentum.png "Alcaraz Vs Djokovic Momentum")
---
![Alcaraz Vs Medvedev Momentum](figures/AvM_momentum.png "Alcaraz Vs Medvedev Momentum")
---
![Sinner Vs Djokovic Momentum](figures/SvD_momentum.png "Sinner Vs Djokovic Momentum")