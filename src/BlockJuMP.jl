module BlockJuMP

include("BlockSolverInterface.jl")
using .BlockSolverInterface

import JuMP
import MathProgBase
import MathProgBase.MathProgSolverInterface

export  BlockModel,
        getblockoccurences,
        getcurcost,
        getdisaggregatedvalue,
        show

# Oracles
export OracleSolverData,
       addblockgrouporacle!, addtosolution, setsolutionobjval

immutable CurCostApplicable end
immutable CurCostNotApplicable end
immutable OracleSolApplicable end
immutable OracleSolNotApplicable end

include("bjprint.jl")
include("bjmodel.jl")
include("bjexpand.jl")
include("bjoracles.jl")
include("bjsolve.jl")
include("bjsolution.jl")

end # module
