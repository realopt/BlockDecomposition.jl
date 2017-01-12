module BlockSolverInterface

using Base.Meta
using Compat

abstract OracleSolverData
export OracleSolverData

# Interfaces
load_cstrs_decomposition!() = nothing
export load_cstrs_decomposition!

load_vars_decomposition!() = nothing
export load_vars_decomposition!

load_sp_mult!() = nothing
export load_sp_mult!

load_sp_prio!() = nothing
export load_sp_prio!

load_oracles!() = nothing
export load_oracles!

load_objective_bounds_and_magnitude!() = nothing
export load_objective_bounds_and_magnitude!

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
