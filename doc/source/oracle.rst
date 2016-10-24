.. _oracle:

-----------------
Oracle solver
-----------------


We introduce oracles with the generalized assignment problem.

Introduction
^^^^^^^^^^^^^^

Consider a set of machines ``Machines = 1:M`` and a set of jobs ``Jobs = 1:J``.
A machine ``m`` has a resource capacity ``Capacity[m]``. When we assign a job
``j`` to a machine ``m``, the job has a cost ``Cost[m,j]`` and consumes
``Weight[m,j]`` resources of the machine ``m``. The goal is to minimize the jobs
cost sum by assigning each job to a machine while not exceeding the capacity of
each machine. The model is ::

    gap = BlockModel(solver = solver)

    @variable(gap, x[m in Machines, j in Jobs], Bin)

    @constraint(gap, cov[0, j in Jobs],
                   sum{ x[m,j], m in Machines } >= 1)

    @constraint(gap, knp[m in Machines],
                   sum{Weight[m,j]*x[m,j], j in Jobs} <= Capacity[m])

    @objective(gap, Min,
                   sum{Cost[m,j]*x[m,j], m in Machines, j in Jobs})



Imagine we have a julia function that can solve efficiently the knapsack problem
and returns the solution and the value of the solution ::

  (sol, value) = solveKnapsack(costs::Vector{Float64}, weights::Vector{Integer}, capacity::Integer)

Write the oracle solver
^^^^^^^^^^^^^^^^^^^^^^^^

We define an oracle that calls this functions and solves the knapsack problem of each block. ::

  function myKnapsackSolver(od::OracleSolverData)
    machine = getblockgroup(od) # get the machine index
    costs = [getcurcost(x[machine,j]) for j in Jobs] # get the current cost with getcurcost
    (sol_x_m, value) = solveKnapsack(costs, Weight[m,:], Capacity[m]) # call the solver

    # Building the oracle solution
    for j in data.jobs
      # add to oracle solution the variables x[machine,j] with the value sol_x_m[j]
      addtosolution(od, x[machine,j], sol_x_m[j])
    end

    # Set the objective value of the solution
    setsolutionobjval(od, value)
  end

In this code, we use the four main functions for oracles provided by BlockJuMP.

.. function:: getblockgroup(od::OracleSolverData)

  Returns the block-group index for which the oracle has been assigned.

.. function:: getcurcost(x::JuMP.Variable)

  Returns the current cost of the varibale ``x``.

.. function:: addtosolution(od::OracleSolverData, x::JuMP.Variable, value::Real)

  Assigns the value ``value`` to the variable ``x`` in the solution of the
  oracle solver

.. function:: setsolutionobjval(od::OracleSolverData, value::real)

  Sets the objective value of the oracle solver solution.

Attach the oracle solver
^^^^^^^^^^^^^^^^^^^^^^^^^^
Once the oracle solver function defined, we assign it to some block groups using
the following function.

.. function:: addblockgrouporacle!(m::JuMP.Model, bgid, oraclesolver::Function)

  Attaches the :func:`oraclesolver` function to the block group ``bgid``.

In our example, we do ::

  for m in data.machines
    addblockgrouporacle!(gap, m, myKnapsackSolver)
  end

Notice that ``m`` is a block index and a block-group index. The block-group
identification function has not been initialized, so the default function,
which is the identity, is used.

Advanced features
^^^^^^^^^^^^^^^^^^

For one call, the oracle solver can return several solution by using the
following function :

.. function:: attachnewsolution(od::OracleSolverData)

  It ends the current solution and create a new solution in the oracle solver
  solution. Note that the previous solutions cannot be modified anymore.


.. function:: getphaseofstageapproach(od::OracleSolverData)

  Returns the phase of stage approach.
