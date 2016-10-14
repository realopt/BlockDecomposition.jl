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



Imagine we have a julia function that can solve very easily the knapsack problem
and returns the solution and the value of the solution ::

  (sol, value) = solveKnapsack(costs::Vector{Float64}, weights::Vector{Integer}, capacity::Integer)

Write the oracle solver
^^^^^^^^^^^^^^^^^^^^^^^^

We define an oracle that call this function and solve the knapsack constraint for
each block. ::

  function myKnapsackSolver(od::OracleSolverData)
    machine = od.blockgroup[1] # get the machine index
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

In this code, we use the three functions for oracles provided by BlockJuMP.

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

.. function:: addblockgrouporacle!(m::JuMP.Model, id, oraclesolver::Function)

  Attaches the ``oraclesolver`` function to the block group ``id``.

In our example, we do ::

  for m_id in data.machines
    addblockgrouporacle!(gap, m_id, myKnapsackSolver)
  end
