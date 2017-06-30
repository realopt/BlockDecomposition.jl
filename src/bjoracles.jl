function add_oracle_to_DWsp!(model::JuMP.Model, sp_id::Integer, f::Function)
  add_oracle_to_DWsp!(model, (sp_id,), f)
end

function add_oracle_to_DWsp!(model::JuMP.Model, sp_id::Tuple, f::Function)
  addoracletosp!(model, sp_id, :DW_SP, f)
end

function add_oracle_to_Bsp!(model::JuMP.Model, sp_id::Integer, f::Function)
  add_oracle_to_Bsp!(model, (sp_id,), f)
end

function add_oracle_to_Bsp!(model::JuMP.Model, sp_id::Tuple, f::Function)
  addoracletosp!(model, sp_id, :B_SP, f)
end

"""
    addoracletosp!(model::JuMP.Model, sp_id, sp_type::Symbol, f::Function)

Attaches the oracle `f` to the subproblem of type `sp_type` which has the index `spid `.
The argument `spid` must be a  `Tuple` or an  `Integer`.
"""
function addoracletosp!(model::JuMP.Model, sp_id::Tuple, sp_type::Symbol, f::Function)
  push!(model.ext[:oracles], (sp_id, sp_type, f))
end
function addoracletosp!(model::JuMP.Model, sp_id::Integer, sp_type::Symbol, f::Function)
  addoracletosp!(model, (sp_id,), sp_type, f)
end

function getphaseofstageapproach(data::OracleSolverData)
  if applicable(get_oracle_phaseofstageapproach, data)
    get_oracle_phaseofstageapproach(data)
  else
    Base.warn("Solver does not appear to support phase of stage approach.")
  end
end

"""
    attachnewsolution(data::OracleSolverData)

It ends the current solution and create a new solution in the oracle solver
solution. Note that the previous solutions cannot be modified anymore.
"""
function attachnewsolution(data::OracleSolverData)
  if applicable(set_oraclesolution_newsolution, data)
    set_oraclesolution_newsolution(data)
  else
    Base.warn("Solver does not appear to support multi solutions oracle.")
  end
end

"""
    addtosolution(data::OracleSolverData, x::JuMP.Variable, val::Real)
    
Assigns the value `val` to the variable `x` in the solution of the
oracle solver
"""
function addtosolution(data::OracleSolverData, x::JuMP.Variable, val::Real)
  if applicable(set_oraclesolution_solution, data, x, val)
    set_oraclesolution_solution(data, x, val)
  else
    Base.warn("Solver does not appear to support oracle solver.")
  end
end

"""
    setsolutionobjval(data::OracleSolverData, objval::Real)

Assigns the value `value` to the variable `x` in the solution of the
oracle solver
"""
function setsolutionobjval(data::OracleSolverData, objval::Real)
  if applicable(set_oraclesolution_objval, data, objval)
    set_oraclesolution_objval(data, objval)
  else
    Base.warn("Solver doest not appear to support oracle solver.")
  end
end

"""
    getcurcost(x::JuMP.Variable)

Returns the current cost of the varibale `x`.
"""
function getcurcost(x::JuMP.Variable)
  if applicable(getcurrentcost, x.m.internalModel, x.col)
    return getcurrentcost(x.m.internalModel, x.col)
  end
  bjerror("Solver does not appear to support current cost.")
end

"""
    getspid(data::OracleSolverData)

Returns the subproblem index for which the oracle has been assigned.
"""
function getspid(data::OracleSolverData)::Tuple
  return data.sp_id
end

function getsptype(data::OracleSolverData)::Symbol
  return data.sp_type
end
