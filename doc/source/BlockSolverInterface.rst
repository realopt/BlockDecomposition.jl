.. _block-solver-interface:

-----------------
BlockSolverInterface module
-----------------

The content of this section is not useful to the user of BlockJuMP.
It has implementation details about the connection with JuMP and the underlying solver.
It is aimed mainly at developpers who would like to contribute to BlockJuMP.

Block-identification data
^^^^^^^^^^^^^^^^^^^^^^^^^

Block-identification data are storred in the dict ``ext`` of the ``JuMP.Model``.::

  model.ext[:BlockIdentification]

It contains block-identification data given by the user when he instanciates
``BlockModel``. Attributes are :

- ``nb_block_indices::Int`` number of indices used for block identification
- ``block_group_func::Function`` returning the block group multi-index of a
  block multi-index
- ``block_group_lb_func::Function`` providing the lower bound multiplicity of
  the block group
- ``block_group_ub_func::Function`` providing the upper bound multiplicity of
  the block group

::

  m.ext[:BlockSolution]

Containing the disaggregrated solution.

::

  m.ext[:VarNames]
  m.ext[:ConstrNames]

Names of variables and constraints


Instanciation
^^^^^^^^^^^^^^

.. function:: set_block_info!(s::AbstractMathProgSolver, d::Dict{Symbol, Any})

  Variable ``d`` contains block-identification data.
  Returns ``true`` if the solver takes benefit of the block-identification, ``false`` else.


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
