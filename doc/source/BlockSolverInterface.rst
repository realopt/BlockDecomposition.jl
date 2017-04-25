.. _block-solver-interface:

-----------------
BlockSolverInterface module (dev)
-----------------

The content of this section is not useful to the user of BlockDecomposition.
It has implementation details about the connection of BlockDecomposition with the underlying solver.
It is aimed mainly at developpers who would like to contribute to BlockDecomposition.


Decomposition data
^^^^^^^^^^^^^^

.. function:: set_constrs_decomposition!(s::AbstractMathProgSolver, data::Array)

  Send to the solver ``s`` in which subproblems are the constraints.
  Each element of the ``data`` array is a ``Tuple`` containing  ``(constr_name::Symbol, constr_id::Tuple, sp_type::Symbol, sp_id::Tuple)``.
  ``constr_name`` and ``constr_id`` are the name and the index of the constraint in the JuMP model.
  ``sp_type`` and ``sp_id`` are the type and the index of the subproblem to which the constraint is assigned.

.. function:: set_vars_decomposition!(s::AbstractMathProgSolver, data::Array)

  Send to the solver ``s`` in which subproblems are the variables.
  Each element of the ``data`` array is a ``Tuple`` containing  ``(var_name::Symbol, var_id::Tuple, sp_type::Symbol, sp_id::Tuple)``.
  ``var_name`` and ``var_id`` are the name and the index of the variable in the JuMP model.
  ``sp_type`` and ``sp_id`` are the type and the index of the subproblem to which the variable is assigned.


BlockDecomposition creates the decomposition list for both constraints and
variables regardless of the type of decomposition used. Types of subproblem are :
   - ``:DW_MASTER`` Dantzig-Wolfe master problem
   - ``:B_MASTER`` Benders master problem
   - ``:DW_SP`` Dantzig-Wolfe subproblem
   - ``:B_SP`` Benders subproblem


Additional data to the decomposition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. function:: set_oracles!(s::AbstractMathProgSolver, list::Array)

  Send to the solver ``s`` the ``list`` with subproblems and oracles functions.

.. function:: set_sp_mult!(s::AbstractMathProgSolver, data::Array)

  Send to the solver ``s`` the multiplicity of each subproblem.

.. function:: set_sp_prio!(s::AbstractMathProgSolver, priorities::Array)

  Send to the solver ``s`` the list of subproblem priorities.

.. function:: set_var_branching_prio!(s::AbstractMathProgSolver, priorities::Array)

  Send to the solver ``s`` the list of variables branching priorities.


Additional data to the model
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. function:: set_objective_bounds_and_magnitude!(s::AbstractMathProgSolver, magnitude, lb, ub)

  Send to the solver ``s`` the magnitude ``magnitude``, the lower bound ``lb``
  and the upper bound ``ub`` of the objective function.


Costs and solutions
^^^^^^^^^^^^^^^^^^^^^

.. function:: getblocksolution(m::AbstractMathProgModel)

  Get the disaggregated solution and store it in the attribute``ext[:BlockSolution]`` of the JuMP model.

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
