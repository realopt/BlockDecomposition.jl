set_block_info!() = nothing

function bj_solve(model;
                suppress_warnings=false,
                relaxation=false,
                kwargs...)
  # TODO : try to remove the importall BaPCod
  if method_exists(set_block_info!, (typeof(model.solver), Dict{Symbol, Any}))
    set_block_info!(model.solver, model.ext)
  else
    expand(model)
  end
  JuMP.solve(model, suppress_warnings=suppress_warnings,
                    ignore_solve_hook=true,
                    relaxation=relaxation)
end
