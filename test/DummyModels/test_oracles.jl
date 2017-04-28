using JuMP, BlockDecomposition, MockBlockSolver
using Base.Test


## Wrong Subproblem Mutiplicity
A = 1:5
B = 1:10

# Oracle
function dummyoracle(od::OracleSolverData)
  spid = getspid(od)
  nothing
end

# decomposition on A
function model_with_DWdec_n_oracles(solver)
  model = BlockModel(solver = solver)
  @variable(model, x[a in A, b in B])
  @variable(model, y[b in B])
  @constraint(model, mastercstr, sum(y[b] for b in B) <= 1)
  @constraint(model, spcstr[a in A], sum(x[a,b] for b in B) <= 1)

  function dw(constrname, constrid)
    if constrname == :spcstr
      return (:DW_SP, constrid[1])
    else
      return (:DW_MASTER, 0)
    end
  end
  add_Dantzig_Wolfe_decomposition(model, dw)

  for a in A
    add_oracle_to_DWsp!(model, a, dummyoracle)
  end
  return model
end

# decomposition on A
function model_with_Bdec_n_oracles(solver)
  model = BlockModel(solver = solver)
  @variable(model, x[a in A, b in B])
  @variable(model, y[b in B])
  @constraint(model, cstr1, sum(y[b] for b in B) <= 2)
  @constraint(model, cstr2[a in A], sum(x[a,b] for b in B) <= 1)

  function b(varname, varid)
    if varname == :x
      return (:B_SP, varid[1])
    else
      return (:B_MASTER, 0)
    end
  end
  add_Benders_decomposition(model, b)

  for a in A
    add_oracle_to_Bsp!(model, a, dummyoracle)
  end
  return model
end

solverB = MockSolver()
modelB = model_with_Bdec_n_oracles(solverB)
solverDW = MockSolver()
modelDW = model_with_DWdec_n_oracles(solverDW)

solve(modelB)
solve(modelDW)

@testset "add Oracles" begin
  checkspid = [0, 0, 0, 0, 0]
  for (sp_id, sp_type, fct) in solverB.oracles
    @test fct === dummyoracle
    @test sp_type == :B_SP
    if sp_id[1] >= 1 && sp_id[1] <= 5
      checkspid[sp_id[1]] += 1
    else
      @test false
    end
  end

  for (sp_id, sp_type, fct) in solverDW.oracles
    @test fct === dummyoracle
    @test sp_type == :DW_SP
    if sp_id[1] >= 1 && sp_id[1] <= 5
      checkspid[sp_id[1]] += 1
    else
      @test false
    end
  end

  for c in checkspid
    @test c == 2
  end

end
