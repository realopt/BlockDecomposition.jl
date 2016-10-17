function bj_solve(model;
                suppress_warnings=false,
                relaxation=false,
                kwargs...)
  # TODO : try to remove the importall BaPCod
  # if method_exists(set_block_info!, (typeof(model.solver), Dict{Symbol, Any}))
  block = set_blockmodel_info!(model.solver, model.ext)
  block || expand(model)

  model.ext[:CurCost] = fill(NaN, model.numCols)

  a = JuMP.solve(model, suppress_warnings=suppress_warnings,
                    ignore_solve_hook=true,
                    relaxation=relaxation)

  if block && applicable(getblocksolution, model.internalModel)
    getblocksolution(model.internalModel)
  end
  a
end

_get_values(v::JuMP.Variable) = v.m.ext[:BlockSolution][v.col]

function _getblockvalue_inner(x)
  vars = x.innerArray
  vals = Array(Vector{Cdouble}, JuMP.size(x))
  data = x.meta[:model].varData[x] # to remove
  for k in eachindex(vars)
    vals[k] = _get_values(vars[k]) # todo
  end
  vals
end

# Copied from JuMP
JuMPContainer_from(x::JuMP.JuMPDict,inner) = JuMP.JuMPDict(inner)
JuMPContainer_from(x::JuMP.JuMPArray,inner) = JuMP.JuMPArray(inner, x.indexsets)

function getdisaggregatedvalue(x::JuMP.Variable)
  if !haskey(x.m.ext, :BlockIdentification)
    return JuMP.getvalue(x)
  end
  (x.m.ext[:BlockSolution] == nothing) &&
    error("Make sure that the problem has been solved.")
  x.m.ext[:BlockSolution][x.col]
end

function getdisaggregatedvalue(x::JuMP.JuMPContainer)
  if !haskey(first(x.innerArray).m.ext, :BlockIdentification)
    return JuMP.getvalue(x)
  end
  ret = JuMPContainer_from(x, _getblockvalue_inner(x))
  for (k,v) in x.meta
    ret.meta[k] = v
  end
  m = x.meta[:model]
  m.varData[ret] = m.varData[x]
  ret
end
