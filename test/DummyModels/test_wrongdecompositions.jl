using JuMP, BlockDecomposition, MockBlockSolver
using Base.Test

function trytosolve(model::JuMP.Model, errortype::Type)
  error = false
  try
    solve(model)
  catch e
    error = isa(e, errortype)
  end
  return error
end

A = 1:5
B = 1:10

# decomposition on A
function model_with_wrongDW(solver)
  model = BlockModel(solver = solver)
  @variable(model, x[a in A, b in B])
  @variable(model, y[b in B])
  @variable(model, w) # w belongs to the master & the subproblems => error !
  @constraint(model, mastercstr, sum(y[b] for b in B) + w <= 1)
  @constraint(model, spcstr[a in A], sum(x[a,b] for b in B) + w <= 1)

  function dw(constrname, constrid)
    if constrname == :spcstr
      return (:DW_SP, constrid[1])
    else
      return (:DW_MASTER, 0)
    end
  end
  add_Dantzig_Wolfe_decomposition(model, dw)
  return model
end

# decomposition on A
function model_with_wrongB(solver)
  model = BlockModel(solver = solver)
  @variable(model, x[a in A, b in B])
  @variable(model, y[b in B])
  @constraint(model, cstr1, sum(y[b] for b in B) <= 2)
  @constraint(model, cstr2[a in A], sum(x[a,b] for b in B) <= 1)
  @constraint(model, w, x[1,2] + x[2,1] <= 1) # Variables belong to two different subproblems => error !!!

  function b(varname, varid)
    if varname == :x
      return (:B_SP, varid[1])
    else
      return (:B_MASTER, 0)
    end
  end
  add_Benders_decomposition(model, b)
  return model
end

dwmodel = model_with_wrongDW(MockSolver())
bmodel = model_with_wrongB(MockSolver())

@testset "Bad decompositions" begin
  @test trytosolve(dwmodel, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(bmodel, BlockDecomposition.BlockDecompositionError)
end
