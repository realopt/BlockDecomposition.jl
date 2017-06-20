using JuMP, BlockDecomposition, MockBlockSolver
using Base.Test

function model_with_anonconstr(solver)
  model = BlockModel(solver = solver)

  @variable(model, x, Bin)
  @variable(model, y[1:3], Bin)
  @constraint(model, x + y[1] <= 1) # Anonymous constraint not supported by BlockDecomposition
  @constraint(model, x + y[2] <= 1)
  @constraint(model, x + y[3] <= 1)

  return model
end

function model_with_anonvar(solver)
  model = BlockModel(solver = solver)
  x = @variable(model) # Anonymous variable not supported
  @variable(model, y[1:3], Bin)
  @constraint(model, dummy[i in 1:3], x + y[i] <= 1)

  return model
end

function trytosolve(model::JuMP.Model, errortype::Type)
  error = false
  try
    solve(model)
  catch e
    error = isa(e, errortype)
  end
  return error
end

s1 = MockSolver()
m1 = model_with_anonconstr(s1)
s2 = MockSolver()
m2 = model_with_anonvar(s2)

@testset "Anonymous constraint & variable error" begin
  @test trytosolve(m1, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(m2, BlockDecomposition.BlockDecompositionError)
end
