----------------------
Installation Guide
----------------------

BlockDecomposition requires Julia, JuMP.jl and MathProgBase.jl

Getting BlockDecomposition.jl
^^^^^^^^^^^^^^^^^^^^^

BlockDecomposition.jl can be installed using the package manager of Julia. To install
it, run::

  julia> Pkg.clone("git@github.com:realopt/BlockDecomposition.jl.git")

This command will, recursively, install BlockDecomposition.jl and its dependencies.

To start using BlockDecomposition.jl, it should be imported together with JuMP into the
local scope::

    using JuMP, BlockDecomposition
