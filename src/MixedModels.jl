module MixedModels

using BlockArrays
using BlockDiagonals
using Distributions
using Feather
using GLM
using LinearAlgebra
using NamedArrays
using NLopt
using Random
using Pkg.Artifacts
using ProgressMeter
using Showoff
using SparseArrays
using StaticArrays
using Statistics
using StatsBase
using StatsModels
using Tables
using TypedTables

using LinearAlgebra: BlasFloat, BlasReal, HermOrSym, PosDefException, copytri!
using Printf: @printf, @sprintf
using GLM: Link, canonicallink

using StatsFuns: log2π

import Base: *
import GLM: dispersion, dispersion_parameter
import NLopt: Opt
import StatsBase: fit, fit!

export @formula,
       Bernoulli,
       Binomial,
       Block,
       BlockedSparse,
       DummyCoding,
       EffectsCoding,
       Gamma,
       GeneralizedLinearMixedModel,
       HelmertCoding,
       InverseGaussian,
       InverseLink,
       LinearMixedModel,
       LogitLink,
       LogLink,
       MixedModel,
       Normal,
       OptSummary,
       Poisson,
       RaggedArray,
       RandomEffectsTerm,
       ReMat,
       SqrtLink,
       TestData,
       UniformBlockDiagonal,
       VarCorr,
       aic,
       aicc,
       bic,
       coef,
       coefnames,
       coeftable,
       cond,
       describeblocks,
       condVar,
       deviance,
       dispersion,
       dispersion_parameter,
       dof,
       dof_residual,
       fit,
       fit!,
       fitted,
       fixef,
       fixefnames,
       fulldummy,
       fnames,
       GHnorm,
       issingular,
       loglikelihood,
       lowerbd,
       nobs,
       objective,
       parametricbootstrap,
       pirls!,
       predict,
       pwrss,
       ranef,
       refit!,
       replicate,
       residuals,
       response,
       shortestcovint,
       sdest,
       setθ!,
       simulate!,
       sparse,
       statscholesky,
       std,
       stderror,
       updateL!,
       varest,
       vcov,
       zerocorr,
       zerocorr!

import Base: ==, *

abstract type MixedModel{T} <: StatsModels.RegressionModel end # model with fixed and random effects

function __init__()
    global TestData = artifact"TestData"
end

include("utilities.jl")
include("arraytypes.jl")
include("varcorr.jl")
include("femat.jl")
include("remat.jl")
include("optsummary.jl")
include("schema.jl")
include("randomeffectsterm.jl")
include("linearmixedmodel.jl")
include("gausshermite.jl")
include("generalizedlinearmixedmodel.jl")
include("linalg/statschol.jl")
include("linalg/cholUnblocked.jl")
include("linalg/rankUpdate.jl")
include("linalg/logdet.jl")
include("linalg.jl")
include("simulate.jl")

end # module
