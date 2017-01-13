.. _block-solver-interface:

-----------------
BlockSolverInterface module (dev)
-----------------

The content of this section is not useful to the user of BlockJuMP.
It has implementation details about the connection of BlockJuMP with the underlying solver.
It is aimed mainly at developpers who would like to contribute to BlockJuMP.


Instanciation
^^^^^^^^^^^^^^

.. function:: set_cstrs_decomposition!(s::AbstractMathProgSolver, data::Array)

  Send to the solver ``s`` in which subproblems are the constraints.

.. function:: set_vars_decomposition!(s::AbstractMathProgSolver, data::Array)

  Send to the solver ``s`` in which subproblems are the variables.

.. function:: set_sp_mult!(s::AbstractMathProgSolver, data::Array)

  Send to the solver ``s`` the multiplicity of each subproblem.

.. function:: set_oracles!(s::AbstractMathProgSolver, list::Array)

  Send to the solver ``s`` the ``list`` with subproblems and oracles functions.



Additional data to the model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. function:: setobjectivevaluelb!(m::AbstractMathProgModel, lb)

  Set the upper bound of the objective function of the model ``m`` to ``lb``.

.. function:: setobjectivevalueub!(m::AbstractMathProgModel, ub)

  Set the lower bound of the objective function of the model ``m`` to ``ub``.

.. function :: setobjectivevaluemagnitude!(m::AbstractMathProgModel, magnitude)

  Set the magnitude of the objective function of the model ``m`` to ``magnitude``.

Costs and solutions
^^^^^^^^^^^^^^^^^^^^^

.. function:: getblocksolution(m::AbstractMathProgModel)

  Get the disaggregated solution and store it in ``m.ext[:BlockSolution]``.

.. function:: getcurrentcost(m::AbstractMathProgModel, vcol::Integer)

  Returns the current cost of the ``vcol`` :math:`{}^{th}` variable.


Oracle solver
^^^^^^^^^^^^^

The oracle solver solution must be stored in an object of type inheriting from
``OracleSolverData``. Following functions communicate between the solver and
the oracle solver written in Julia.

.. function:: set_oraclesolution_solution(o::OracleSolverData, x::JuMP.Variable, v::Real)

  Set the value of the variable ``x`` to ``v`` in the oracle solver solution stored
  in the ``OracleSolverData`` object ``o``.

.. function:: set_oraclesolution_objval(o::OracleSolverData, v::Real)

  Set the objective value stored in the ``OracleSolverData`` object ``o`` to ``v``.

.. function:: set_oraclesolution_newsolution(o::OracleSolverData)

  Creates a new solution in the oracle solver solution. It is usefull, if the
  user wants to return several solutions.

.. function:: get_oracle_phaseofstageapproach(o::OracleSolverData)

  Return the phase of stage approach.
