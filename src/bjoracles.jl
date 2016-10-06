function addblockgrouporacle!(model::JuMP.Model, blockgroup::Int, f::Function)
  addblockgrouporacle!(model, [blockgroup], f)
end

function addblockgrouporacle!(model::JuMP.Model, blockgroup::Array{Int,1}, f::Function)
  if !haskey(model.ext, :oracles)
    model.ext[:oracles] = Array{Tuple{Array{Int, 1}, Function}, 1}()
  end
  push!(model.ext[:oracles], (blockgroup, f))
end
