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

## Wrong Subproblem Mutiplicity
A = 1:5 # decomposition on a
B = 1:10

function right_dw(cstrname, cstrmid)::Tuple{Symbol, Tuple}
  if cstrname == :mastercstr
    return (:DW_MASTER, (0,))
  else
    return (:DW_SP, cstrmid)
  end
end

wrong_dw1(cstrname, cstrmid) = (:WRONG, ("OUTPUT",))
wrong_dw2(cstrname, cstrmid) = (:DW_SP, "WRONGOUTPUT")
wrong_dw3(wronginput) = (:DW_SP, 0)

wrong_b1(varname, varid) = (:WRONG, ("OUTPUT",))
wrong_b2(varname, varid) = (:B_SP, "WRONGOUTPUT")
wrong_b3(wronginput) = (:B_SP, 0)


function dummymodel(solver)
  model = BlockModel(solver = solver)
  @variable(model, x[a in A, b in B])
  @variable(model, y[b in B])
  @constraint(model, mastercstr, sum(y[b] for b in B) <= 2)
  @constraint(model, spcstr[a in A], sum(x[a,b] for b in B) <= 1)

  return model
end

wrongmultiplicity1(spid::Tuple, sptype::Symbol) = (3, 2) # ub > lb
wrongmultiplicity2(spid::Tuple, sptype::Symbol) = ("wrong", "output") # output must be a tuple of integer

model1 = dummymodel(MockSolver())
add_Dantzig_Wolfe_decomposition(model1, wrong_dw1)
model2 = dummymodel(MockSolver())
add_Dantzig_Wolfe_decomposition(model2, wrong_dw2)
model3 = dummymodel(MockSolver())
add_Dantzig_Wolfe_decomposition(model3, wrong_dw3)

@testset "Wrong DW decomposition function" begin
  @test trytosolve(model1, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(model2, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(model3, BlockDecomposition.BlockDecompositionError)
end

model1 = dummymodel(MockSolver())
add_Benders_decomposition(model1, wrong_b1)
model2 = dummymodel(MockSolver())
add_Benders_decomposition(model2, wrong_b2)
model3 = dummymodel(MockSolver())
add_Benders_decomposition(model3, wrong_b3)

@testset "Wrong B decomposition function" begin
  @test trytosolve(model1, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(model2, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(model3, BlockDecomposition.BlockDecompositionError)
end

model1 = dummymodel(MockSolver())
add_Dantzig_Wolfe_decomposition(model1, right_dw)
model2 = dummymodel(MockSolver())
add_Dantzig_Wolfe_decomposition(model2, right_dw)
addspmultiplicity(model1, wrongmultiplicity1)
addspmultiplicity(model2, wrongmultiplicity2)

@testset "Wrong sp mult user functions" begin
  @test trytosolve(model1, BlockDecomposition.BlockDecompositionError)
  @test trytosolve(model2, BlockDecomposition.BlockDecompositionError)
end
