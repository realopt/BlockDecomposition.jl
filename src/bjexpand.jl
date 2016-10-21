# Expand the model to take into account multiplicity of the block-groups
function expand(m::JuMP.Model)
  # First step : expand variables
  expand_variables(m)
  # Second step : expand constraints
  expand_constraints(m)
end

function expand_variables(m::JuMP.Model)
  variables = m.ext[:VarNames]
  for varcollection in variables
    typevc = string(typeof(varcollection.second))
    # Expand can be only done in JuMP.Container of Variables
    isjumpcontnr = (match(r"^JuMP.JuMPArray", typevc) !== nothing)
    isjumpcontnr |= (match(r"^JuMP.JuMPDict", typevc) !== nothing)
    isjumpcontnr && expand_var_collection(m, varcollection)
  end
end

function expand_var_collection(m::JuMP.Model, var_collection)
  mult_ub_func = m.ext[:BlockIdentification].block_group_ub_func
  error("expand function no yet implemented.")
end

function expand_constraints(m::JuMP.Model)
  constraints = m.ext[:ConstrNames]
  for constrcollection in constraints
    typecc = string(typeof(constrcollection.second))
    isjumpcontnr = (match(r"^JuMP.JuMPArray", typecc) !== nothing)
    isjumpcontnr |= (match(r"^JuMP.JuMPDict", typecc) !== nothing)
    isjumpcontnr && expand_cstr_collection(m, constrcollection)
  end
end

function expand_cstr_collection(m::JuMP.Model, cstr_collection)
  mult_ub_func = m.ext[:BlockIdentification].block_group_ub_func
  error("expand function not yet implemented.")
end
