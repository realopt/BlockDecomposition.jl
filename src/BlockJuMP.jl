module BlockJuMP

importall BaPCod # TODO check if BaPCod exists

import JuMP
import MathProgBase
import MathProgBase.MathProgSolverInterface

export BlockModel, expand

include("bjmodel.jl")
include("bjexpand.jl")
include("bjsolve.jl")

end # module
