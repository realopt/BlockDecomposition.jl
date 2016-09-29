module BlockJuMP

import JuMP
import MathProgBase
import MathProgBase.MathProgSolverInterface

export BlockModel, expand

include("bjmodel.jl")
include("bjexpand.jl")

end # module
