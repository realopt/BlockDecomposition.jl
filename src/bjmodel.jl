type ObjectiveData
  magnitude
  lb
  ub
end

type BlockDecompositionData
  DantzigWolfe_decomposition_fct
  DantzigWolfe_decomposition_on_vars_fct
  Benders_decomposition_fct
  Benders_decomposition_on_cstrs_fct
end
BlockDecompositionData() = BlockDecompositionData(nothing, nothing, nothing, nothing)

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
  m.ext[:sp_tab] = nothing

  # Data sent to the solver
  m.ext[:cstrs_decomposition_list] = nothing
  m.ext[:vars_decomposition_list] = nothing
  m.ext[:sp_mult_tab] = nothing
  m.ext[:sp_prio_tab] = nothing
  m.ext[:objective_data] = ObjectiveData(NaN, -Inf, Inf)

  m.ext[:var_branch_prio_dict] = Dict{Tuple{Symbol, Tuple, Symbol}, Cdouble}() # (varname, sp, where) => (priority)

  # Callbacks
  m.ext[:oracles] = Array{Tuple{Tuple, Symbol, Function}}(0)

  m.ext[:generic_vars] = Dict{Symbol, Tuple{JuMP.Variable, Function}}()
  m.ext[:generic_cstrs] = Dict{Int, Tuple{JuMP.JuMP.ConstraintRef, String, Function}}()
  m.ext[:cstrs_preproc] = Dict{Tuple{Symbol, Tuple}, Bool}() # (cstrname, sp) => bool

  # Columns counter for generic variables & constraints
  m.ext[:colscounter] = 0
  m.ext[:rowscounter] = 0
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

function branchingpriorityinmaster(x::JuMP.JuMPContainer, subproblem::Tuple{Symbol, Union{Tuple, Integer}}, priority)
  varname = Symbol(x.meta[:model].varData[x].name)
  x.meta[:model].ext[:var_branch_prio_dict][(varname, subproblem, :MASTER)] = priority
end

function branchingpriorityinsubproblem(x::JuMP.JuMPContainer, subproblem::Tuple{Symbol, Union{Tuple, Integer}}, priority)
  varname = Symbol(x.meta[:model].varData[x].name)
  x.meta[:model].ext[:var_branch_prio_dict][(varname, subproblem, :SUBPROBLEM)] = priority
end

function addspmultiplicity(m::JuMP.Model, sp_mult)
  m.ext[:sp_mult_fct] = sp_mult
end

function addsppriority(m::JuMP.Model, sp_prio)
  m.ext[:sp_prio_fct] = sp_prio
end
