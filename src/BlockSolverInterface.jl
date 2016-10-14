module BlockSolverInterface

using Base.Meta
using Compat

abstract OracleSolverData
export OracleSolverData

# Interfaces
set_block_info!() = nothing
export set_block_info!

set_oraclesolution_solution() = nothing
export set_oraclesolution_solution

set_oraclesolution_objval() = nothing
export set_oraclesolution_objval

getcurrentcost() = nothing
export set_oraclesolution_objval

getblocksolution() = nothing
export getblocksolution

end
