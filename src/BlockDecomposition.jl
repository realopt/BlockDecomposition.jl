module BlockDecomposition

include("BlockSolverInterface.jl")
using .BlockSolverInterface

# Usefull
if Pkg.installed("BlockDecompositionExtras") != nothing
       using BlockDecompositionExtras
end

import JuMP
using JuMP

# todo
if Pkg.installed("CPLEX") != nothing
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

# todo : enhance
if Pkg.installed("CPLEX") != nothing
       include("bjcplex.jl")
end

end # module
