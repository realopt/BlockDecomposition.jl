using JuMP, BlockJuMP, Scanner, CPLEX

include("data_flp.jl")
include("model_flp.jl")

appfolder = dirname(@__FILE__)
data = DataFl("$appfolder/data/play.txt")

(fl, x, y) = model_fl(data, CplexSolver())

println(fl)
status = solve(fl)

#output
println("Status is $status")

if status == :Optimal
  println("Objective value : $(getobjectivevalue(fl))")
  println("Solution x : $(getvalue(x))")
  println("Solution y : $(getvalue(y))")
end
