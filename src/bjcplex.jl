defineannotations() = nothing

@require CPLEX begin
  function defineannotations(m::JuMP.Model, vars_decomposition)
    if m.solver isa CPLEX.CplexSolver
      JuMP.build(m)
      model = m.internalModel
      blocks = Dict{Tuple,Clong}()
      iblock = 1
      newlongannotation(model.inner, "cpxBendersPartition", Clong(-1))
      for (col, (v_name, v_id, sp_type, sp_id)) in enumerate(vars_decomposition)
          indexArr = Array{Cint}(1)
          indexArr[1] = col - 1
          valArr = Array{Clong}(1)
          if sp_type == :B_MASTER
              valArr[1] = 0
          elseif sp_type == :B_SP
              if !haskey(blocks, sp_id)
                  blocks[sp_id] = iblock
                  iblock += 1
              end
              valArr[1] = blocks[sp_id]
          end
          setlongannotations(model.inner, Cint(0), Cint(1), Cint(1), indexArr, valArr)
      end
    end
  end
end
