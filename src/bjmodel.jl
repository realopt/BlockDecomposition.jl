type BlockIdentificationData
  nb_block_indices::Int
  block_lb_func
  block_ub_func
end

function BlockModel(;solver = JuMP.UnsetSolver(),
                     nb_block_indices = 1,
                     block_lb_func = x -> 1,
                     block_ub_func = x -> 1      )
  m = JuMP.Model(solver = solver)
  m.ext[:BlockIdentification] = BlockIdentificationData(nb_block_indices,
                                                        block_lb_func,
                                                        block_ub_func    )
  # Adding variable names and constraint names
  m.ext[:VarNames] = m.varDict
  m.ext[:ConstrNames] = m.conDict
  m
end
