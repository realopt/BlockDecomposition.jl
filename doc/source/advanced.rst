.. _oracle:

-----------------
Advanced usage
-----------------

.. note ::
  No solver over Julia supports this feature yet.

Oracles are customized solvers that can be used to solve efficiently subproblems.
We introduce them using the example of Generalized Assignment Problem.

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

    function dw_fct(cstrname::Symbol, cstrid::Tuple) :: Tuple{Symbol, Tuple}
      if cstrname == :cov            # cov constraints will be assigned in the
        return (:DW_MASTER, (0,))    # master that has the index 0
      else                           # others constraints will be assigned in a
        return (:DW_SP, cstrid)      # subproblem that has the same index as the constraint
      end
    end
    add_Dantzig_Wolfe_decomposition(gap, dw_fct)


Generalized Assignment problem can be solved using a Dantzig-Wolfe decomposition.
Imagine we have a julia function that can solve efficiently the knapsack problem
and returns the solution and the value of the solution ::

  (sol, value) = solveKnp(costs::Vector{Float64}, weights::Vector{Integer}, capacity::Integer)

Write the oracle solver
^^^^^^^^^^^^^^^^^^^^^^^^

We define an oracle that calls this function and solves each knapsack subproblem. ::

  function myKnapsackSolver(od::OracleSolverData)
    machine = getspid(od)[0] # get the machine index
    costs = [getcurcost(x[machine,j]) for j in Jobs] # get the current cost with getcurcost
    (sol_x_m, value) = solveKnp(costs, Weight[m,:], Capacity[m]) # call the solver

    # Building the oracle solution
    for j in data.jobs
      # add to oracle solution the variables x[machine,j] with the value sol_x_m[j]
      addtosolution(od, x[machine,j], sol_x_m[j])
    end

    # Set the objective value of the solution
    setsolutionobjval(od, value)
  end

In this code, we use the four main functions for oracles provided by BlockJuMP.

.. function:: getspid(od::OracleSolverData) :: Tuple

  Returns the subproblem index for which the oracle has been assigned.

.. function:: getcurcost(x::JuMP.Variable)

  Returns the current cost of the varibale ``x``.

.. function:: addtosolution(od::OracleSolverData, x::JuMP.Variable, value::Real)

  Assigns the value ``value`` to the variable ``x`` in the solution of the
  oracle solver

.. function:: setsolutionobjval(od::OracleSolverData, value::real)

  Sets the objective value of the oracle solver solution.

Attach the oracle solver
^^^^^^^^^^^^^^^^^^^^^^^^^^
Once the oracle solver function defined, we assign it to some subproblems using
the following function.

.. function:: addoracletosp!(m::JuMP.Model, spid::Union{Tuple,Integer}, oraclesolver::Function)

  Attaches the :func:`oraclesolver` function to the subproblem which has the index ``spid``.
  The argument ``spid`` must be a ``Tuple`` or an ``Integer``.

In our example, we do ::

  for m in data.machines
    addoracletosp!(gap, m, myKnapsackSolver)
  end


Advanced feature
^^^^^^^^^^^^^^^^^^

For one call, the oracle solver can return several solution by using the
following function :

.. function:: attachnewsolution(od::OracleSolverData)

  It ends the current solution and create a new solution in the oracle solver
  solution. Note that the previous solutions cannot be modified anymore.
