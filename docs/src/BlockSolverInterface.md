
# BlockSolverInterface module (dev)

The content of this section is not useful to the user of BlockDecomposition.
It has implementation details about the connection of BlockDecomposition with the underlying solver.
It is aimed mainly at developpers who would like to contribute to BlockDecomposition.


## Decomposition data

```@docs
BlockDecomposition.BlockSolverInterface.set_constrs_decomposition!
```

```@docs
BlockDecomposition.BlockSolverInterface.set_vars_decomposition!
```

BlockDecomposition creates the decomposition list for both constraints and
variables regardless of the type of decomposition used. Types of subproblem are :
   - `:DW_MASTER` Dantzig-Wolfe master problem
   - `:B_MASTER` Benders master problem
   - `:DW_SP` Dantzig-Wolfe subproblem
   - `:B_SP` Benders subproblem


## Additional data to the decomposition

```@docs
BlockDecomposition.BlockSolverInterface.set_oracles!
```

```@docs
BlockDecomposition.BlockSolverInterface.set_sp_mult!
```

```@docs
BlockDecomposition.BlockSolverInterface.set_sp_prio!
```

```@docs
BlockDecomposition.BlockSolverInterface.set_var_branching_prio!
```

## Additional data to the model

```@docs
BlockDecomposition.BlockSolverInterface.set_objective_bounds_and_magnitude!
```

Send to the solver `s` the magnitude `magn`, the lower bound `lb`
and the upper bound `ub` of the objective function.

## Costs and solutions

```@docs
BlockDecomposition.BlockSolverInterface.getcurrentcost
```

```@docs
BlockDecomposition.BlockSolverInterface.getdisaggregatedvalueofvariable
```

## Oracle solver


```@docs
BlockDecomposition.BlockSolverInterface.set_oraclesolution_solution
```

```@docs
BlockDecomposition.BlockSolverInterface.set_oraclesolution_objval
```

```@docs
BlockDecomposition.BlockSolverInterface.set_oraclesolution_newsolution
```

```@docs
BlockDecomposition.BlockSolverInterface.get_oracle_phaseofstageapproach
```
