module BlockSolverInterface

using Base.Meta
using Compat

abstract OracleSolverData
export OracleSolverData

abstract OracleCallbackData
export OracleCallbackData

# Interfaces
set_constrs_decomposition!() = nothing
export set_constrs_decomposition!

set_vars_decomposition!() = nothing
export set_vars_decomposition!

set_sp_mult!() = nothing
export set_sp_mult!

set_sp_prio!() = nothing
export set_sp_prio!

set_var_branching_prio!() = nothing
export set_var_branching_prio!

set_oracles!() = nothing
export set_oracles!

set_objective_bounds_and_magnitude!() = nothing
export set_objective_bounds_and_magnitude!

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

getdisaggregatedvalueofvariable() = nothing
export getdisaggregatedvalueofvariable

end
