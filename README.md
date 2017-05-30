# BlockDecomposition

[![Build Status](https://travis-ci.org/realopt/BlockDecomposition.jl.svg?branch=master)](https://travis-ci.org/realopt/BlockDecomposition.jl)
[![codecov](https://codecov.io/gh/realopt/BlockDecomposition.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/realopt/BlockDecomposition.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://realopt.github.io/BlockDecomposition.jl/latest/)
[![Join the chat at https://gitter.im/realopt/BlockDecomposition.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/realopt/BlockDecomposition.jl)


BlockDecomposition.jl is a package providing features to take advantage of the shape of block structured problem; in other words, problems on which Dantzig-Wolfe decomposition or Benders decomposition can be applied.


This package is under development. Although it is a JuMP extension, It is not written nor maintained by the primary developers of JuMP. Therefore, do not expect high reactiveness on the issues.

### Getting BlockDecomposition.jl
BlockDecomposition.jl can be installed using the package manager of Julia. To install it, run:

```
 julia> Pkg.clone("https://github.com/realopt/BlockDecomposition.jl.git")
```

This command will, recursively, install BlockDecomposition.jl and its dependencies.

To start using BlockDecomposition.jl, it should be imported together with JuMP into the local scope:

```julia
 using JuMP, BlockDecomposition
 ```

### Demo : [Facility Location Problem](https://en.wikipedia.org/wiki/Facility_location_problem)
```julia
function model_fl(data::DataFl, solver)

  fl = BlockModel(solver = solver)

  @variable(fl, 0 <= x[i in data.customers, j in data.factories] <= 1 )
  @variable(fl, y[j in data.factories], Bin)

  @constraint(fl, cov[i in data.customers],
                sum( x[i, j] for j in data.factories ) >= 1)

  @constraint(fl, knp[j in data.factories],
                sum( x[i, j] for i in data.customers ) <= y[j] * data.capacities[j])

  @objective(fl, Min,
                sum( data.costs[i,j] * x[i, j] for j in data.factories, i in data.customers)
                + sum( data.fixedcosts[j] * y[j] for j in data.factories) )

  # Benders decomposition
  function benders_fct(varname::Symbol, varid::Tuple)
    if varname == :x
      return (:B_SP, 0)
    else
      return (:B_MASTER, 0)
    end
  end
  add_Benders_decomposition(fl, benders_fct)
  return (fl, x, y)
end
```
