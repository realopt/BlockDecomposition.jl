module BlockJuMP

importall BaPCod # TODO check if BaPCod exists

import JuMP
import MathProgBase
import MathProgBase.MathProgSolverInterface

export  BlockModel,
        expand,
        get_block_occurences,
        getvalue,
        addblockgrouporacle!,
        getcurcost,

include("bjmodel.jl")
include("bjexpand.jl")
include("bjoracles.jl")
include("bjsolve.jl")
include("bjsolution.jl")

end # module
