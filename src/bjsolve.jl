function bj_solve(model;
                suppress_warnings=false,
                relaxation=false,
                kwargs...)
  # Step 1 : Create variables & constraints report
  report_cstrs_and_vars!(model)
  create_cstrs_vars_decomposition_list!(model)
  create_sp_mult_tab!(model)
  create_sp_prio_tab!(model)
  create_var_branching_prio_tab!(model)

  # Step 2 : Send decomposition (& others) data to the solver
  # Cstrs decomposition : mandatory
  send_to_solver!(model, set_cstrs_decomposition!, :cstrs_decomposition_list, true)
  # Vars decomposition : mandatory
  send_to_solver!(model, set_vars_decomposition!, :vars_decomposition_list, true)
  # Subproblems multiplicities
  send_to_solver!(model, set_sp_mult!, :sp_mult_tab, false)
  # Subproblems priorities
  send_to_solver!(model, set_sp_prio!, :sp_prio_tab, false)
  # Variables branching priority
  send_to_solver!(model, set_var_branching_prio!, :var_branch_prio_tab, false)
  # Oracles
  send_to_solver!(model, set_oracles!, :oracles, false)
  #  TODO find antoher way to do that
  if Pkg.installed("BlockJuMPExtras") != nothing
    if applicable(BlockJuMPExtras.send_extras_to_solver!, model)
      BlockJuMPExtras.send_extras_to_solver!(model)
    end
  end
  # Objective bounds and magnitude
  obj = model.ext[:objective_data]
  if applicable(set_objective_bounds_and_magnitude!, model.solver, obj.magnitude, obj.lb, obj.ub)
    set_objective_bounds_and_magnitude!(model.solver, obj.magnitude, obj.lb, obj.ub)
  end

  model.ext[:colscounter] = model.numCols
  model.ext[:rowscounter] = length(model.ext[:cstrs_decomposition_list])

  # Step 3 : Build + solve
  a = JuMP.solve(model, suppress_warnings=suppress_warnings,
                    ignore_solve_hook=true,
                    relaxation=relaxation)

  # Step 4 : Get the column generation solution if it's a Dantzig Wolfe decomposition
  if use_DantzigWolfe(model) && applicable(getblocksolution, model.internalModel)
    model.ext[:dw_solution] = getblocksolution(model.internalModel)
  end
  # TODO expand model to take account of sp multiplicities
  a
end

function send_to_solver!(model::JuMP.Model, f::Function, k::Symbol, mandatory::Bool)
  if haskey(model.ext, k)
    if applicable(f, model.solver, model.ext[k])
      f(model.solver, model.ext[k])
    else
      if mandatory
        bjerror("Your solver does not support function $f.")
      end
    end
  else
    bjerror("Key $(k) does not exist in model.ext.")
  end
end

# _get_values(v::JuMP.Variable) = v.m.ext[:dw_solution][v.col]
#
# function _getblockvalue_inner(x)
#   vars = x.innerArray
#   vals = Array(Vector{Cdouble}, JuMP.size(x))
#   data = x.meta[:model].varData[x] # to remove
#   for k in eachindex(vars)
#     vals[k] = _get_values(vars[k]) # todo
#   end
#   vals
# end

# Copied from JuMP
# JuMPContainer_from(x::JuMP.JuMPDict,inner) = JuMP.JuMPDict(inner)
# JuMPContainer_from(x::JuMP.JuMPArray,inner) = JuMP.JuMPArray(inner, x.indexsets)

# function getdisaggregatedvalue(x::JuMP.Variable)
#   if !haskey(x.m.ext, :dw_solution)
#     return JuMP.getvalue(x)
#   end
#   (x.m.ext[:BlockSolution] == nothing) &&
#     bjerror("Make sure that the problem has been solved.")
#   x.m.ext[:dw_solution][x.col]
# end

function getdisaggregatedvalue(x::JuMP.Variable)
  if !haskey(x.m.ext, :dw_solution)
     return JuMP.getvalue(x)
  end
  (x.m.ext[:dw_solution] == nothing) &&
    bjerror("Make sure that the problem has been solved.")
  x.m.ext[:dw_solution][x.col, :]
end

# function getdisaggregatedvalue(x::JuMP.JuMPContainer)
#   if !haskey(first(x.innerArray).m.ext, :dw_solution)
#     return JuMP.getvalue(x)
#   end
#   ret = JuMPContainer_from(x, _getblockvalue_inner(x))
#   for (k,v) in x.meta
#     ret.meta[k] = v
#   end
#   m = x.meta[:model]
#   m.varData[ret] = m.varData[x]
#   ret
# end

function getdisaggregatedvalue(x::JuMP.JuMPContainer)
  warn("getdisaggregatedvalue of a JuMPContainer not implemented. Use getdisaggregatedvalue(x::JuMP.Variable).")
end

function getdisaggregatedvalue(model::JuMP.Model)
  if haskey(model.ext, :dw_solution)
    return model.ext[:dw_solution]
  end
end
