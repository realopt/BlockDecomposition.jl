# Callbacks

!!! note
    No solver over Julia supports this feature yet.

Oracles are customized solvers that can be used to solve efficiently subproblems.
We introduce them using the example of Generalized Assignment Problem.

## Introduction

Cosider a set of machines `Machines = 1:M` and a set of jobs `Jobs = 1:J`.
A machine `m` has a resource capacity `Capacity[m]`. When we assign a job
`j` to a machine `m`, the job has a cost `Cost[m,j]` and consumes
`Weight[m,j]` resources of the machine `m`. The goal is to minimize the jobs
cost sum by assigning each job to a machine while not exceeding the capacity of
each machine. The model is

```julia
gap = BlockModel(solver = solver)

@variable(gap, x[m in Machines, j in Jobs], Bin)

@constraint(gap, cov[0, j in Jobs],
               sum{ x[m,j], m in Machines } >= 1)

@constraint(gap, knp[m in Machines],
               sum{Weight[m,j]*x[m,j], j in Jobs} <= Capacity[m])

@objective(gap, Min,
               sum{Cost[m,j]*x[m,j], m in Machines, j in Jobs})

function dw_fct(cstrname::Symbol, cstrid::Tuple) :: Tuple{Symbol, Tuple}
    if cstrname == :cov           # cov constraints will be assigned in the
        return (:DW_MASTER, (0,)) # master that has the index 0
    else                          # others constraints will be assigned in a
        return (:DW_SP, cstrid)   # subproblem with same index as the constraint
    end
end
add_Dantzig_Wolfe_decomposition(gap, dw_fct)
```    

Generalized Assignment problem can be solved using a Dantzig-Wolfe decomposition.
Imagine we have a julia function that can solve efficiently the knapsack problem
and returns the solution and the value of the solution

```julia
(sol,value) = solveKnp(costs::Vector{Float64}, weights::Vector{Integer}, capacity::Integer)
```

## Write the oracle solver

We define an oracle that calls this function and solves each knapsack subproblem. ::

```julia
function myKnapsackSolver(od::OracleSolverData)
    machine = getspid(od)[0] # get the machine index
    costs = [getcurcost(x[machine,j]) for j in Jobs] # get the current cost
    (sol_x_m, value) = solveKnp(costs, Weight[m,:], Capacity[m]) # call the solver

    # Building the oracle solution
    for j in data.jobs
        # add to oracle solution variables x[machine,j] with values sol_x_m[j]
        addtosolution(od, x[machine,j], sol_x_m[j])
    end

    # Set the objective value of the solution
    setsolutionobjval(od, value)
end
```

In this code, we use the four main functions for oracles provided by BlockDecomposition.

```@docs
getspid
```

```@docs
getcurcost
```

```@docs
addtosolution
```

```@docs
setsolutionobjval
```

## Attach the oracle solver

Once the oracle solver function defined, we assign it to some subproblems using
the following function.

```@docs
addoracletosp!
````

In our example, we do

```julia
for m in data.machines
    addoracletosp!(gap, m, myKnapsackSolver)
end
```
