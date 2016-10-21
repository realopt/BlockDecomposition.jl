module BlockSolverInterface

using Base.Meta
using Compat

abstract OracleSolverData
export OracleSolverData

# Interfaces
set_blockmodel_info!() = nothing
export set_blockmodel_info!

set_oraclesolution_newsolution() = nothing
export set_oraclesolution_newsolution

set_oraclesolution_solution() = nothing
export set_oraclesolution_solution

set_oraclesolution_objval() = nothing
export set_oraclesolution_objval

get_oracle_phaseofstageapproach() = nothing
export get_oracle_phaseofstageapproach

getcurrentcost() = nothing
export getcurrentcost

getblocksolution() = nothing
export getblocksolution

setobjectivevaluelb!() = nothing
export setobjectivevaluelb!

setobjectivevalueub!() = nothing
export setobjectivevalueub!

setobjectivevaluemagnitude!() = nothing
export setobjectivevaluemagnitude!

end
