function create_blocksol_pattern!(m::JuMP.Model)
  m.ext[:blockSolPattern] = Dict()
  println("To be implemented")
end

function getblockoccurences(m::JuMP.Model, idblock)
  error("getblockoccurences not yet implemented")
end
