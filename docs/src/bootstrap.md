
# Parametric bootstrap for linear mixed-effects models

Julia is well-suited to implementing bootstrapping and other simulation-based methods for statistical models.
The `parametricbootstrap` function in the [MixedModels package](https://github.com/dmbates/MixedModels.jl) provides
an efficient parametric bootstrap for linear mixed-effects models.

## The parametric bootstrap

[Bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) is a family of procedures
for generating sample values of a statistic, allowing for visualization of the distribution of the
statistic or for inference from this sample of values.

A _parametric bootstrap_ is used with a parametric model, `m`, that has been fitted to data.
The procedure is to simulate `n` response vectors from `m` using the estimated parameter values
and refit `m` to these responses in turn, accumulating the statistics of interest at each iteration.

The parameters of a `LinearMixedModel` object are the fixed-effects
parameters, `β`, the standard deviation, `σ`, of the per-observation noise, and the covariance
parameter, `θ`, that defines the variance-covariance matrices of the random effects.

For example, a simple linear mixed-effects model for the `Dyestuff` data in the [`lme4`](http://github.com/lme4/lme4)
package for [`R`](https://www.r-project.org) is fit by

````julia
using DataFrames, Gadfly, MixedModels, Random, RData
testdir = normpath(joinpath(dirname(pathof(MixedModels)), "..", "test"));
const dat = Dict(Symbol(k)=>v for (k,v) in load(joinpath(testdir, "dat.rda")));
````



````julia
ds = names!(dat[:Dyestuff], [:Batch, :Yield])  # the Dyestuff data
m1 = fit!(LinearMixedModel(@formula(Yield ~ 1 + (1 | Batch)), ds))
````


````
Linear mixed model fit by maximum likelihood
 Yield ~ 1 + (1 | Batch)
   logLik   -2 logLik     AIC        BIC    
 -163.66353  327.32706  333.32706  337.53065

Variance components:
              Column    Variance  Std.Dev. 
 Batch    (Intercept)  1388.3334 37.260347
 Residual              2451.2500 49.510100
 Number of obs: 30; levels of grouping factors: 6

  Fixed-effects parameters:
──────────────────────────────────────────────────
             Estimate  Std.Error  z value  P(>|z|)
──────────────────────────────────────────────────
(Intercept)    1527.5    17.6946   86.326   <1e-99
──────────────────────────────────────────────────
````





To bootstrap the model parameters, we first initialize a random number generator

````julia
rng = MersenneTwister(1234321);
````





then create a bootstrap sample

````julia
samp = parametricbootstrap(rng, 100_000, m1, (:σ, :β, :θ))
````


````
Table with 3 columns and 100000 rows:
      σ        β          θ
    ┌─────────────────────────────────
 1  │ 67.4315  [1509.13]  [0.212245]
 2  │ 47.9831  [1538.08]  [0.532841]
 3  │ 50.1346  [1508.02]  [0.434076]
 4  │ 53.2238  [1538.47]  [0.771382]
 5  │ 45.2975  [1520.62]  [0.423428]
 6  │ 36.7556  [1536.94]  [1.33812]
 7  │ 53.8161  [1519.88]  [0.867993]
 8  │ 47.8989  [1528.43]  [0.785752]
 9  │ 41.4     [1497.46]  [0.365355]
 10 │ 64.616   [1532.65]  [0.0]
 11 │ 57.2036  [1552.54]  [0.00848485]
 12 │ 49.355   [1519.28]  [0.493776]
 13 │ 59.6272  [1509.04]  [0.306747]
 14 │ 51.5431  [1531.7]   [0.630042]
 15 │ 64.0205  [1536.17]  [0.238096]
 16 │ 58.6856  [1526.42]  [0.0]
 17 │ 43.218   [1517.67]  [0.832206]
 ⋮  │    ⋮         ⋮           ⋮
````





The results from the sampling are returned as a `Table`, as defined in the `TypedTables.jl` package.
Both $\beta$ and $\theta$ are vectors - in this case one-dimensional vectors.  The `first` and `last` functions are useful for extracting individual elements from the sampled vectors.

Notice that, for some samples, the estimated value of $\theta$ is `[0.0]`.  In fact, this is the case for about about 10% of all the samples.

````julia
sum(iszero, samp.θ)
````


````
10090
````





A density plot of the bootstrapped values of `σ` shows a slightly skewed but unimodal distribution

````julia
plot(x=samp.σ, Geom.density, Guide.xlabel("Parametric bootstrap estimates of σ"))
````


![](./assets/bootstrap_6_1.svg)



but a density plot of the bootstrap estimates of $\theta_1$, or of $\sigma_1=\theta_1 \cdot \sigma$

````julia
plot(x=first.(samp.θ), Geom.density, Guide.xlabel("Parametric bootstrap estimates of θ₁"))
````


![](./assets/bootstrap_7_1.svg)

````julia
plot(x=first.(samp.θ) .* samp.σ, Geom.density, Guide.xlabel("Parametric bootstrap estimates of σ₁"))
````


![](./assets/bootstrap_8_1.svg)



has a mode at zero.  Although this mode shows up as being diffuse, this is an artifact of the way that density plots are created.  In fact, it is a pulse, as can be seen from a histogram.

````julia
plot(x=first.(samp.θ).*samp.σ, Geom.histogram, Guide.xlabel("Parametric bootstrap estimates of σ₁"))
````


![](./assets/bootstrap_9_1.svg)