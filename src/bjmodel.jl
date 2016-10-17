type BlockIdentificationData
  nb_block_indices::Int
  block_group_func::Function
  block_group_lb_func::Function
  block_group_ub_func::Function
  block_group_priority_func::Function
end

type ObjectiveData
  magnitude
  lb
  ub
end

defaultBlockIdeData() = BlockIdentificationData(1, x->x, x->1, x->1, x->1)

function BlockModel(;solver = JuMP.UnsetSolver(),
                     nb_block_indices = 1,
                     block_group_func = x -> x,
                     block_group_lb_func = x -> 1,
                     block_group_ub_func = x -> 1,
                     block_group_priority_func = x -> 1 )
  m = JuMP.Model(solver = solver)
  JuMP.setsolvehook(m, bj_solve)
  m.ext[:BlockIdentification] = BlockIdentificationData(nb_block_indices,
                                                        block_group_func,
                                                        block_group_lb_func,
                                                        block_group_ub_func,
                                                        block_group_priority_func )
  # Adding variable names and constraint names
  m.ext[:VarNames] = m.varDict
  m.ext[:ConstrNames] = m.conDict
  m.ext[:CurCost] = Array(Cdouble, m.numCols)
  m.ext[:BlockSolution] = nothing
  m.ext[:ObjectiveData] = ObjectiveData(nothing, nothing, nothing)
  m.ext[:VariablePriority] = [1.0]
  m
end

function objectivevaluemagnitude(m::JuMP.Model, magnitude)
  m.ext[:ObjectiveData].magnitude = magnitude
end

function objectivevalueupperbound(m::JuMP.Model, ub)
  m.ext[:ObjectiveData].ub = ub
end

function objectivevaluelowerbound(m::JuMP.Model, lb)
  m.ext[:ObjectiveData].lb = lb
end

function variablebranchingpriority(x::JuMP.Variable, priority)
  l = length(x.m.ext[:VariablePriority])
  if l <= x.m.numCols
    resize!(x.m.ext[:VariablePriority], x.m.numCols)
    for i in l+1:x.m.numCols
      x.m.ext[:VariablePriority][i] = 1.0
    end
  end
  x.m.ext[:VariablePriority][x.col] = priority
end
