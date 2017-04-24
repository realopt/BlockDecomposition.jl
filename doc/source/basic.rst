.. _quick-start:

-----------------
Basic usage
-----------------

This quick start guide introduces features of BlockDecomposition.jl package.


BlockModel instantiation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. A BlockDecomposition model can be instantiated as

::

  gap = BlockModel(solver = decomp_solver)

The instantiation is similar to the one of ``JuMP.Model``.
However ``decomp_solver`` must be a MIP solver of JuMP models that additionally supports Benders and/or Dantzig-Wolfe decomposition.

Write the model
^^^^^^^^^^^^^^^
The model is written as a JuMP model. If you are not familiar with JuMP syntax,
you may want to check its `documentation <https://jump.readthedocs.io/en/latest/quickstart.html#defining-variables>`_.

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
This function is call by BlockDecomposition to build the decomposition data.
For Benders decomposition, the arguments will be ``varname`` the name
of the variable and ``varid`` the index of the variable. ::

  function B_decomp(varname::Symbol, varid::Tuple) :: Tuple{Symbol, Union{Int, Tuple}}

The function returns a ``Tuple`` that contains a ``Symbol`` and
a ``Union{Int, Tuple}``. The ``Symbol`` is the type of problem to which
the variable belongs.
It may be ``:B_MASTER`` or ``:B_SP``.
The ``Union{Int, Tuple}`` is the index of this problem.


To assign the decomposition function to the model, BlockDecomposition provides the function

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
