module BlockJuMP

include("BlockSolverInterface.jl")
using .BlockSolverInterface

import JuMP
import MathProgBase.MathProgSolverInterface

export  BlockModel,
        BlockIdentificationData,
        defaultBlockIdeData,
        getcurcost,
        getdisaggregatedvalue,
        objectivevaluemagnitude,
        objectivevalueupperbound,
        objectivevaluelowerbound,
        variablebranchingpriority,
        attachnewsolution,
        getphaseofstageapproach,
        getblockgroup,
        show

# Oracles
export OracleSolverData,
       addblockgrouporacle!, addtosolution, setsolutionobjval

include("bjprint.jl")
include("bjmodel.jl")
include("bjexpand.jl")
include("bjoracles.jl")
include("bjsolve.jl")

end # module
