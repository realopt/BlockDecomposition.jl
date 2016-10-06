type BlockIdentificationData
  nb_block_indices::Int
  block_group_func::Function
  block_group_lb_func::Function
  block_group_ub_func::Function
end

function BlockModel(;solver = JuMP.UnsetSolver(),
                     nb_block_indices = 1,
                     block_group_func = x -> x,
                     block_group_lb_func = x -> 1,
                     block_group_ub_func = x -> 1      )
  m = JuMP.Model(solver = solver)
  JuMP.setsolvehook(m, bj_solve)
  m.ext[:BlockIdentification] = BlockIdentificationData(nb_block_indices,
                                                        block_group_func,
                                                        block_group_lb_func,
                                                        block_group_ub_func    )
  # Adding variable names and constraint names
  m.ext[:VarNames] = m.varDict
  m.ext[:ConstrNames] = m.conDict
  m.ext[:CurCost] = Vector{Float64}()
  m
end

_similar(x::Array) = Array(Float64,size(x))
_similar{T}(x::Dict{T}) = Dict{T,Float64}()
_getCurCost(x::JuMP.Variable) = x.m.ext[:CurCost][x.col]

function _getCurCostInner(x)
  vars = x.innerArray
  costs = _similar(vars)
  for i in eachindex(vars)
    costs[i] = _getCurCost(vars[i])
  end
  costs
end

function getcurcost(x::JuMP.Variable)
  cc = _getCurCost(x)
  # add warning if is NaN
end

JuMPContainer_from(x::JuMP.JuMPDict,inner) = JuMP.JuMPDict(inner)
JuMPContainer_from(x::JuMP.JuMPArray,inner) = JuMP.JuMPArray(inner, x.indexsets)

function getcurcost(arr::Array{JuMP.Variable})
  error("getcurcost(Array{JuMP.Variable}) is not implemented")
end

function getcurcost(x::JuMP.JuMPContainer{JuMP.Variable})
  ret = JuMPContainer_from(x, _getCurCostInner(x))
  for (key, val) in x.meta
    ret.meta[key] = val
  end
  m = x.meta[:model] #getmeta
  m.varData[ret] = x.meta[:model].varData[x] #printdata
  ret
end
