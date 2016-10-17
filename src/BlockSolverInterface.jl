module BlockSolverInterface

using Base.Meta
using Compat

abstract OracleSolverData
export OracleSolverData

# Interfaces
set_blockmodel_info!() = nothing
export set_blockmodel_info!

set_oraclesolution_solution() = nothing
export set_oraclesolution_solution

set_oraclesolution_objval() = nothing
export set_oraclesolution_objval

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
