type ObjectiveData
  magnitude
  lb
  ub
  artcostvalue
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
  m.ext[:objective_data] = ObjectiveData(NaN, -Inf, Inf, NaN)

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

"""
    objectivevaluemagnitude(m::JuMP.Model, magnitude)

Set the magnitude of the objective function of the model `m` to `magnitude`
"""
function objectivevaluemagnitude(m::JuMP.Model, magnitude)
  m.ext[:objective_data].magnitude = magnitude
end

"""
    objectivevalueupperbound(m::JuMP.Model, ub)

Set the upper bound of the objective function of the model `m` to `ub`
"""
function objectivevalueupperbound(m::JuMP.Model, ub)
  m.ext[:objective_data].ub = ub
end

"""
    objectivevaluelowerbound(m::JuMP.Model, lb)

Set the lower bound of the objective function of the model `m` to `lb`
"""
function objectivevaluelowerbound(m::JuMP.Model, lb)
  m.ext[:objective_data].lb = lb
end

# TODO documentation
function artcostvalue(m::JuMP.Model, acv)
  m.ext[:objective_data].artcostvalue = acv
end

"""
    branchingpriorityinmaster(x::JuMP.JuMPContainer, subproblem::Tuple{Symbol, Union{Tuple, Integer}}, priority)

Assign to the variables `x` defined in the subproblem `subproblem` the priority
value `priority` in master.

```julia
branchingpriorityinmaster(x, (:B_SP, 1), 2)
```
The variable `x` defined in the Benders subproblem with id `1` will have the
branching priority value `2`in the master.
"""
function branchingpriorityinmaster(x::JuMP.JuMPContainer, subproblem::Tuple{Symbol, Union{Tuple, Integer}}, priority)
  var_name = name(x)
  model = jumpmodel(x)
  model.ext[:var_branch_prio_dict][(var_name, subproblem, :MASTER)] = priority
end

"""
    branchingpriorityinsubproblem(x::JuMP.JuMPContainer, subproblem::Tuple{Symbol, Union{Tuple, Integer}}, priority)

Assign to the variables `x` defined in the subproblem `subproblem` the priority
value `priority` in subproblems.

```julia
branchingpriorityinsubproblem(x, (:B_SP, 1), 2)
```
The variable `x` defined in the Benders subproblem with id `1` will have the
branching priority value `2`in subproblems.
"""
function branchingpriorityinsubproblem(x::JuMP.JuMPContainer, subproblem::Tuple{Symbol, Union{Tuple, Integer}}, priority)
  var_name = name(x)
  model = jumpmodel(x)
  model.ext[:var_branch_prio_dict][(var_name, subproblem, :SUBPROBLEM)] = priority
end

"""
    addspmultiplicity(m::JuMP.Model, sp_mult::Function)

assign the multiplicity function `sp_mult` to the model `m`. The multiplicity
function takes two arguments, the type of the subproblem `sp_type` and the id
of the subproblem `sp_id`. It returns a `Pair` within the lower bound `lb` and
the upper bound `ub` of the multiplicity.

```julia
  sp_mult(sp_type::Symbol, sp_id::Union{Integer, Tuple}) = (lb, ub)
```
"""
function addspmultiplicity(m::JuMP.Model, sp_mult::Function)
  m.ext[:sp_mult_fct] = sp_mult
end

function addsppriority(m::JuMP.Model, sp_prio)
  m.ext[:sp_prio_fct] = sp_prio
end
