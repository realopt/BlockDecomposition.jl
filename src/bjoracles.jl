function addblockgrouporacle!(model::JuMP.Model, blockgroup::Int, f::Function)
  addblockgrouporacle!(model, [blockgroup], f)
end

function addblockgrouporacle!(model::JuMP.Model, blockgroup::Array{Int,1}, f::Function)
  if !haskey(model.ext, :oracles)
    model.ext[:oracles] = Array{Tuple{Array{Int, 1}, Function}, 1}()
  end
  push!(model.ext[:oracles], (blockgroup, f))
end

function addtosolution(data::OracleSolverData, x::JuMP.Variable, val::Real)
  if applicable(set_oraclesolution_solution, data, x, val)
    set_oraclesolution_solution(data, x, val)
  else
    Base.warn("Solver does not appear to support oracle solver.")
  end
end

function setsolutionobjval(data::OracleSolverData, objval::Real)
  if applicable(set_oraclesolution_objval, data, objval)
    set_oraclesolution_objval(data, objval)
  else
    Base.warn("Solver doest not appear to support oracle solver.")
  end
end

function getcurcost(x::JuMP.Variable)
  if applicable(getcurrentcost, x.m.internalModel, x.col)
    return getcurrentcost(x.m.internalModel, x.col)
  end
  error("Solver does not appear to support current cost.")
end

# function getcurcost(x::JuMP.Variable)
#   return getcurcost(x, x.m.ext[:curcost_trait])
# end

# function getcurcost(x::JuMP.Variable, trait::CurCostApplicable)
#   return getcurrentcost(x.m.internalModel, x.col)
# end
#
# function getcurcost(x::JuMP.Variable, trait::CurCostNotApplicable)
#   error("Solver does not appear to support current costsy")
# end
