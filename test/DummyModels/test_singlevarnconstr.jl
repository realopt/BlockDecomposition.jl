using JuMP, BlockDecomposition, MockBlockSolver
using Base.Test

function model_with_singlevarnconstr(solver)
  model = BlockModel(solver = solver)

  @variable(model, x) # Single variable at col 1
  @variable(model, y[1:3], Bin)
  @constraint(model, test, x <= 5) # Single constraint at row 1
  @constraint(model, dummy[i in 1:3], x + y[i] <= 1)

  return model
end

s1 = MockSolver()
m1 = model_with_singlevarnconstr(s1)
solve(m1)

@testset "Decomposition of a MIP with single vars&constrs" begin
  @test s1.vars_decomposition[1] == (:x, nothing, :MIP, 0)
  @test s1.cstrs_decomposition[1] == (:test, nothing, :MIP, 0)
end
