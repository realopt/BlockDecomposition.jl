----------------------
Installation Guide
----------------------

BlockJuMP requires Julia, JuMP.jl and MathProgBase.jl

Getting BlockJuMP.jl
^^^^^^^^^^^^^^^^^^^^^

BlockJuMP.jl can be installed using the package manager of Julia. To install
it, run::

  julia> Pkg.clone("git@github.com:realopt/BlockJuMP.jl.git")

This command will, recursively, install BlockJuMP.jl and its dependencies.

To start using BlockJuMP.jl, it should be imported together with JuMP into the
local scope::

    using JuMP, BlockJuMP
