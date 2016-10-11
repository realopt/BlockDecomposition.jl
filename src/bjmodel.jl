type BlockIdentificationData
  nb_block_indices::Int
  block_group_func::Function
  block_group_lb_func::Function
  block_group_ub_func::Function
end

function BlockModel(;solver = JuMP.UnsetSolver(),
                     nb_block_indices = 1,
                     block_group_func = x -> x,
                     block_group_lb_func = x -> 1,
                     block_group_ub_func = x -> 1      )
  m = JuMP.Model(solver = solver)
  JuMP.setsolvehook(m, bj_solve)
  m.ext[:BlockIdentification] = BlockIdentificationData(nb_block_indices,
                                                        block_group_func,
                                                        block_group_lb_func,
                                                        block_group_ub_func   )
  # Adding variable names and constraint names
  m.ext[:VarNames] = m.varDict
  m.ext[:ConstrNames] = m.conDict
  m.ext[:CurCost] = Array(Cdouble, m.numCols)
  m
end

function getcurcost(x::JuMP.Variable)
  cc = x.m.ext[:CurCost][x.col]
  (cc == NaN) && warn("current cost for the variable $x is not defined.")
  cc
end

function getcurcost(arr::Array{JuMP.Variable})
  error("getcurcost(Array{JuMP.Variable}) is not implemented")
end
