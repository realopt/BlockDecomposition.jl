using BlockDecomposition
using MockBlockSolver
using Base.Test

include("FacilityLocation/test_flp.jl")
include("GeneralizedAssignment/test_sgap.jl")
include("DummyModels/test_anonymousvarnconstr.jl")
include("DummyModels/test_singlevarnconstr.jl")
include("DummyModels/test_userfcterrors.jl")
include("DummyModels/test_wrongdecompositions.jl")
include("DummyModels/test_oracles.jl")
