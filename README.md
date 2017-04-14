# BlockJuMP

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://realopt.github.io/BlockJuMP.jl/latest/)

BlockJuMP.jl is a package providing features to take advantage of the shape of block structured problem; in other words, problems on which Dantzig-Wolfe decomposition or Benders decomposition can be applied.


### Getting BlockJuMP.jl
BlockJuMP.jl can be installed using the package manager of Julia. To install it, run:

```
 julia> Pkg.clone("git@github.com:realopt/BlockJuMP.jl.git")
```

This command will, recursively, install BlockJuMP.jl and its dependencies.

To start using BlockJuMP.jl, it should be imported together with JuMP into the local scope:

```julia
 using JuMP, BlockJuMP
 ```
