# Function describing the Dantzig-Wolfe decomposition
function dw(cstrname, cstrmid)::Tuple{Symbol, Tuple}
  if cstrname == :cov
    return (:DW_MASTER, (0,))
  else
    return (:DW_SP, cstrmid)
  end
end

function model_sgap(data::DataGap, solver)
  gap = BlockModel(solver = solver)

  @variable(gap, x[m in data.machines, j in data.jobs], Bin)

  @constraint(gap, cov[j in data.jobs],
                 sum(x[m,j] for m in data.machines) >= 1)

  @constraint(gap, knp[m in data.machines],
                 sum(data.weight[j,m]*x[m,j] for j in data.jobs) <= data.capacity[m])

  @objective(gap, Min,
                 sum(data.cost[j,m]*x[m,j] for m in data.machines, j in data.jobs))

  add_Dantzig_Wolfe_decomposition(gap, dw)

  # Function describing the multiplicity of the subproblems
  function spm(spid::Tuple, sptype::Symbol)
    return (1, 1)
  end
  addspmultiplicity(gap, spm)

  # lb/ub/magnitude of the objective function
  objectivevaluemagnitude(gap, 100)
  objectivevalueupperbound(gap, 1000)
  objectivevaluelowerbound(gap, -1000)

  # priority of subproblems
  function spprio(spid::Tuple, sptype::Symbol)
    return spid
  end
  # addsppriority(gap, spprio)

  # branching priority of few variables
  variablebranchingpriority(x[1,1], 2)
  variablebranchingpriority(x[2,1], 8)

  return (gap, x)
end
