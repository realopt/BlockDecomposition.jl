using JuMP, BlockDecomposition, Scanner, MockBlockSolver
using Base.Test

include("data_flp.jl")
include("model_flp.jl")

appfolder = dirname(@__FILE__)
data = DataFl("$appfolder/data/play.txt")
solver = MockSolver()

(fl, x, y) = model_fl(data, solver)

status = solve(fl)

@testset "GAP Objective function" begin
 @test isnan(solver.obj_lb)
 @test isnan(solver.obj_ub)
 @test isnan(solver.obj_magnitude)
end

@testset "GAP Variable branching priority" begin
  @test length(solver.vars_branching_priorities) == 0
end

@testset "GAP Subproblem multiplicity" begin
 @test solver.sp_mult == nothing
end

@testset "GAP Benders variables decomposition" begin
  for (var_name, var_id, sp_type, sp_id) in solver.vars_decomposition
    # Note : sp_id is a converted in a 1-Tuple by BlockDecomposition
    @test benders_fct(var_name, var_id) == (sp_type, sp_id[1])
  end
end

@testset "GAP Benders constraints decomposition" begin
  for (constr_name, constr_id, sp_type, sp_id) in solver.cstrs_decomposition
    @test (sp_type, sp_id) == (:B_SP, (0,))
  end
end

@testset "GAP Subproblem priority" begin
  @test length(solver.sp_prio) == 1 # Only one subproblem
  @test solver.sp_prio[1] == ((0,), :B_SP, 66) # Its priority is 66
end

@testset "GAP Oracles" begin
  @test length(solver.oracles) == 0
end
