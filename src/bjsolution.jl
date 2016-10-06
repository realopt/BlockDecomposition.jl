function create_blocksol_pattern!(m::JuMP.Model)
  m.ext[:blockSolPattern] = Dict()
  println("To be implemented")
end

function get_block_occurences(m::JuMP.Model, idblock)
  println("get_block_occurences not yet implemented")
  3
end

# function getvalue(x::JuMP.JuMPContainer, idblock, idsol)
#   println("\e[31m getvalue implementation \e[00m")
#   println("\e[36m printing args :")
#   println("\t - x = $(x[idblock,:])")
#   println("\t - ndims(x) = $(ndims(x))")
#   println("\t - idblock = $idblock")
#   println("\t - idsol = $idsol")
#
#   println("\e[31m END GETVALUE \e[00m")
#   nothing
# end
