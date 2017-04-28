module BlockDecomposition

include("BlockSolverInterface.jl")
using .BlockSolverInterface

import JuMP

using Requires
using JuMP
# Usefull

@require BlockDecompositionExtras begin
       using BlockDecompositionExtras
end
@require CPLEX begin
       using CPLEX
end

export  BlockModel,
        BlockIdentificationData,
        BlockDecompositionData,
        defaultBlockIdeData,
        getcurcost,
        getdisaggregatedvalue,
        objectivevaluemagnitude,
        objectivevalueupperbound,
        objectivevaluelowerbound,
        variablebranchingpriority,
        add_Dantzig_Wolfe_decomposition,
        add_Benders_decomposition,
        addspmultiplicity,
        addsppriority,
        show

# Oracles
export OracleSolverData,
       addoracletosp!,
       add_oracle_to_DWsp!,
       add_oracle_to_Bsp!,
       addtosolution,
       setsolutionobjval,
       getspid,
       getsptype,
       attachnewsolution,
       getphaseofstageapproach

import Base.convert, Base.show, Base.copy, Base.pointer

include("bjutils.jl")
include("bjreport.jl")
include("bjprint.jl")
include("bjmodel.jl")
include("bjexpand.jl")
include("bjoracles.jl")
include("bjsolve.jl")
include("bjdecomposition.jl")
include("bjcplex.jl")

end # module
