# BlockDecomposition

[![Join the chat at https://gitter.im/realopt/BlockDecomposition.jl](https://badges.gitter.im/realopt/BlockDecomposition.jl.svg)](https://gitter.im/realopt/BlockDecomposition.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://realopt.github.io/BlockDecomposition.jl/latest/)

BlockDecomposition.jl is a package providing features to take advantage of the shape of block structured problem; in other words, problems on which Dantzig-Wolfe decomposition or Benders decomposition can be applied.


This package is under development. Although it is a JuMP extension, It is not written nor maintained by the primary developers of JuMP. Therefore, do not expect high reactiveness on the issues.

### Getting BlockDecomposition.jl
BlockDecomposition.jl can be installed using the package manager of Julia. To install it, run:

```
 julia> Pkg.clone("git@github.com:realopt/BlockDecomposition.jl.git")
```

This command will, recursively, install BlockDecomposition.jl and its dependencies.

To start using BlockDecomposition.jl, it should be imported together with JuMP into the local scope:

```julia
 using JuMP, BlockDecomposition
 ```
