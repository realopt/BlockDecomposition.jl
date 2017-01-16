.. _quick-start:

-----------------
Quick Start Guide
-----------------

This quick start guide introduces features of BlockJuMP.jl package.


BlockModel instantiation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. A BlockJuMP model can be instantiated as

::

  gap = BlockModel(solver = decomp_solver)

The instantiation is similar to the one of ``JuMP.Model``.
However ``decomp_solver`` must be a MIP solver of JuMP models that additionally supports Benders and/or Dantzig-Wolfe decomposition.

Write the model
^^^^^^^^^^^^^^^
The model is written as a JuMP model. If you are not familiar with JuMP syntax,
you may want to check its `documentation <https://jump.readthedocs.io/en/latest/quickstart.html#defining-variables>`_.

..
    The following example is the generalized assignement problem.
    Consider a set of machines ``Machines = 1:M`` and a set of jobs ``Jobs = 1:J``.
    A machine ``m`` has a resource capacity ``Capacity[m]``. When we assign a job
    ``j`` to a machine ``m``, the job has a cost ``Cost[m,j]`` and consumes
    ``Weight[m,j]`` resources of the machine ``m``. The goal is to minimize the jobs
    cost sum by assigning each job to a machine while not exceeding the capacity of
    each machine ::

      gap = BlockModel(solver = solver)

      @variable(gap, x[m in Machines, j in Jobs], Bin)

      @constraint(gap, cov[j in Jobs],
                     sum{ x[m,j], m in Machines } >= 1)

      @constraint(gap, knp[m in Machines],
                     sum{Weight[m,j]*x[m,j], j in Jobs} <= Capacity[m])

      @objective(gap, Min,
                     sum{Cost[m,j]*x[m,j], m in Machines, j in Jobs})

      status = solve(gap)


The following example is the capacitated facility location problem.
Consider a set of potential facility sites ``Facilities = 1:F`` where a
facility can be opened and a set of customers ``Customers = 1:C`` that must be
serviced. Assign a customer ``c`` to a facility ``f`` has a cost ``DistanceCosts[c, f]``.
Moreover, opening a facility has a cost ``Fixedcosts[f]`` and each facility has a capacity ``Capacities[f]``.
All customers must be assigned to a facility. ::

  fl = BlockModel(solver = decomp_solver)

  @variable(fl, 0 <= x[c in Customers, f in Factories] <= 1 )
  @variable(fl, y[f in Facilities], Bin)

  @constraint(fl, cov[c in Customers],
                sum( x[c, f] for j in Facilities ) >= 1)

  @constraint(fl, knp[f in Facilities],
                sum( x[c, f] for c in Customers ) <= y[f] * Capacities[f])

  @objective(fl, Min,
                sum( DistanceCosts[c, f] * x[c, f] for f in Facilities, c in Customers)
                + sum( Fixedcosts[f] * y[f] for f in Facilities) )


Decomposition
^^^^^^^^^^^^^

The decomposition is described with a function that takes two arguments.
This function is call by BlockJuMP to build the decomposition data.

..
      If it is a Dantzig-Wolfe decomposition, the arguments will be ``cstrname`` the
      name of the constraint and ``cstrid`` the index of the constraint. ::

        function DW_decomp(cstrid::Symbol, cstrid::Tuple) :: Tuple{Symbol, Tuple}

for Benders decomposition, the arguments will be ``varname`` the name
of the variable and ``varid`` the index of the variable. ::

  function B_decomp(varname::Symbol, varid::Tuple) :: Tuple{Symbol, Union{Int, Tuple}}

The function returns a ``Tuple`` that contains a ``Symbol`` and
a ``Union{Int, Tuple}``. The ``Symbol`` is the type of problem to which
the variable belongs.
It may be ``:B_MASTER`` or ``:B_SP``.
The ``Union{Int, Tuple}`` is the index of this problem.

..  It may be ``:DW_MASTER`` and ``:DW_SP``
      or ``:B_MASTER`` and ``:B_SP`` depending on the decomposition.

..  To assign the decomposition function to the model, BlockJuMP provides two functions ::
      add_Dantzig_Wolfe_decomposition(model, DW_decomp) # DW_decomp is our decomposition function
      add_Benders_decomposition(model, B_decomp) # B_decomp is our decomposition function

To assign the decomposition function to the model, BlockJuMP provides the function

.. function:: add_Benders_decomposition(model::JuMP.Model, B_decomp::Function)

  with ``model`` the model and ``B_decomp`` the Benders decomposition function.

Now, we can write the decomposition function of our two ewamples. For the
Capacitated Facility Location problem, we want to put variables :math:`y` in
the master and variables :math:`x` in the unique subproblem. It can be write ::

  function benders_fct(varname::Symbol, varid::Tuple) :: Tuple{Symbol, Union{Int, Tuple}}
    if varname == :x              # variables x will be assigned to the
      return (:B_SP, 0)        # subproblem that has the index 0
    else                          # variables y will be assigned to the
      return (:B_MASTER, 0)    # master that has the index 0
    end
  end
  add_Benders_decomposition(fl, benders_fct)

Notice that even if there is only one master problem, he must have an index.

..
    For the
    Generalized Assignment problem, we want to make a subproblem for each machine that
    will contain the knapsack constraint ::

      function dw_fct(cstrname::Symbol, cstrid::Tuple) :: Tuple{Symbol, Tuple}
        if cstrname == :cov            # cov constraints will be assigned in the
          return (:DW_MASTER, (0,))    # master that has the index 0
        else                           # others constraints will be assigned in a
          return (:DW_SP, cstrid)      # subproblem that has the same index as the constraint
        end
      end
      add_Dantzig_Wolfe_decomposition(gap, dw_fct)


..
      Get the solution
      ^^^^^^^^^^^^^^^^
      You can use methods provided by JuMP.

      Considering the cutting-stock problem solved with column generation, the solution
      given by JuMP is ::

        julia> getvalue(x)
        Solution x : x: 2 dimensions:
        [1,:]
          [1, 1] = 5.0
          [1, 2] = 5.0
          [1, 3] = 6.0
          [1, 4] = 5.0
          [1, 5] = 5.0
          [1, 6] = 5.0
          [1, 7] = 5.0
          [1, 8] = 2.0
          [1, 9] = 7.0
          [1,10] = 5.0

      When the block-group has a multiplicity upper bound greater than 1
      (like the case of cutting stock problem),
      :func:`getvalue` returns an aggregated solution of the block-group. In order to
      get the solution for each occurance of the block-group (from 1 to its
      upperbound), :func:`getdisaggregatedvalue` should be used instead.::

        julia> getdisaggregatedvalue(x)
        Solution x : x: 2 dimensions:
        [1,:]
          [1, 1] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
          [1, 2] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
          [1, 3] = [  1.0  1.0  1.0  1.0  1.0  0.0  1.0  ]
          [1, 4] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
          [1, 5] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
          [1, 6] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
          [1, 7] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
          [1, 8] = [  0.0  0.0  0.0  0.0  0.0  1.0  1.0  ]
          [1, 9] = [  1.0  1.0  1.0  1.0  1.0  1.0  1.0  ]
          [1,10] = [  1.0  1.0  1.0  1.0  1.0  0.0  0.0  ]
