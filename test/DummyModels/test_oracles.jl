using JuMP, BlockDecomposition, MockBlockSolver
using Base.Test


function model_with_oracles(solver)
  model = BlockModel(solver = solver)


  return model
end
