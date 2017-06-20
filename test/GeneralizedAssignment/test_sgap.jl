using JuMP, BlockDecomposition, MockBlockSolver
using Base.Test

include("data_sgap.jl")
include("model_sgap.jl")

appfolder = dirname(@__FILE__)
data = read_dataGap("$appfolder/data/play.txt")
solver = MockSolver()

(gap, x) = model_sgap(data, solver)
status = solve(gap)

@testset "GAP Objective function" begin
 @test solver.obj_lb == -1000
 @test solver.obj_ub == 1000
 @test solver.obj_magnitude == 100
end

@testset "GAP Variable branching priority" begin
  # @test solver.vars_branching_priorities[x[1,1].col] == 2
  # @test solver.vars_branching_priorities[x[2,1].col] == 8
  # @test solver.vars_branching_priorities[x[1,2].col] == 0
end

@testset "GAP Subproblem multiplicity" begin
  for (sp_id, sp_type, mult_lb, mult_ub) in solver.sp_mult
    @test sp_type == :DW_SP # The master doesn't have multiplicity
    @test mult_lb == 1
    @test mult_ub == 1
  end
end

@testset "GAP Dantzig-Wolfe constraints decomposition" begin
  for (constr_name, constr_id, sp_type, sp_id) in solver.cstrs_decomposition
    @test dw(constr_name, constr_id) == (sp_type, sp_id)
  end
end

@testset "GAP Dantzig-Wolfe variables decomposition" begin
  for (var_name, var_id, sp_type, sp_id) in solver.vars_decomposition
    @test (sp_type == :DW_SP) && (sp_id == (var_id[1],))
  end
end

@testset "GAP Subproblem priority" begin
  for (sp_id, sp_type, sp_prio) in solver.sp_prio
    @test sp_id[1] == sp_prio
    @test sp_type == :DW_SP
  end
end

@testset "GAP Oracles" begin
  @test length(solver.oracles) == 0
end
