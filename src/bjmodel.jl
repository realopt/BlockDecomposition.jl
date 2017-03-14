type ObjectiveData
  magnitude
  lb
  ub
end

type BlockDecompositionData
  DantzigWolfe_decomposition_fct
  Benders_decomposition_fct
end
BlockDecompositionData() = BlockDecompositionData(nothing, nothing)

function BlockModel(;solver = JuMP.UnsetSolver())
  m = JuMP.Model(solver = solver)
  JuMP.setsolvehook(m, bj_solve)

  # Block decomposition data
  m.ext[:block_decomposition] = BlockDecompositionData()
  # Variables & constraints report
  m.ext[:varcstr_report] = VarCstrReport()
  # Priorities & multiplicities
  m.ext[:sp_mult_fct] = nothing
  m.ext[:sp_prio_fct] = nothing

  # Storage (to list all subproblems)
  m.ext[:sp_list_dw] = Dict{Tuple, Integer}()
  m.ext[:sp_list_b] = Dict{Tuple, Integer}()

  # Data sent to the solver
  m.ext[:cstrs_decomposition_list] = nothing
  m.ext[:vars_decomposition_list] = nothing
  m.ext[:sp_mult_tab] = nothing
  m.ext[:sp_prio_tab] = nothing
  m.ext[:var_branch_prio_tab] = nothing
  m.ext[:objective_data] = ObjectiveData(NaN, -Inf, Inf)
  m.ext[:var_branch_prio_dict] = Dict{Int, Cdouble}() # var.col => priority
  m.ext[:oracles] = Array(Tuple{Tuple, Symbol, Function},0)

  m
end

function objectivevaluemagnitude(m::JuMP.Model, magnitude)
  m.ext[:objective_data].magnitude = magnitude
end

function objectivevalueupperbound(m::JuMP.Model, ub)
  m.ext[:objective_data].ub = ub
end

function objectivevaluelowerbound(m::JuMP.Model, lb)
  m.ext[:objective_data].lb = lb
end

function update_tab_size!(tab, newsize, dfv)
  l = length(tab)
  if l <= newsize
    resize!(tab, newsize)
    for i in l+1:newsize
      tab[i] = dfv
    end
  end
end

function variablebranchingpriority(x::JuMP.Variable, priority)
  x.m.ext[:var_branch_prio_dict][x.col] = priority
end

function addspmultiplicity(m::JuMP.Model, sp_mult)
  m.ext[:sp_mult_fct] = sp_mult
end

function addsppriority(m::JuMP.Model, sp_prio)
  m.ext[:sp_prio_func] = sp_prio
end
