.. _quick-start:

-----------------
Quick Start Guide
-----------------

This quick start guide introduces features of BlockJuMP.jl package.


BlockModel instantiation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. A BlockJuMP model can be instantiated as

::

    gap = BlockModel( solver = block_solver,
                      nb_block_indices = b,
                      block_group_func = s
                      block_group_lb_func = l,
                      block_group_ub_func = u )

* ``solver = block_solver`` can be simply a MIP solver supported by JuMP.
  However a BlockModel makes more sense when providing a solver that
  takes benefit of the block-identification.
|

* ``nb_block_indices = b`` :math:`\in \mathbb{N}`, is
  the number of indices used for block identification
|
* *(Optional)* ``block_group_func = s`` a function from :math:`\mathbb{N}^b`
  to :math:`\mathbb{N}^{\sigma}`,
  assuming we want to group blocks into block groups with
  multi-indices that are made of :math:`\sigma` indices.
  This function returns the block group multi-index of a block multi-index.
  If it is not filled,
  the default function used is the idendity function.
|
* *(Optional)* ``block_group_lb_func = l`` a function from
  :math:`\mathbb{N}^{\sigma}` to  :math:`\mathbb{N}`, provides
  the lower bound multiplicity of the block group.
  If it is not filled, the default
  function used returns ``1``
|
* *(Optional)* ``block_group_ub_func = u`` a function from
  :math:`\mathbb{N}^{\sigma}` to  :math:`\mathbb{N}`, provides
  the upper bound multiplicity of the block group.
  If it is not filled, the default
  function used returns ``1``

Write the model
^^^^^^^^^^^^^^^
The model is written as a JuMP model. If you are not familiar with the JuMP syntax,
you may want to check its `documentation <https://jump.readthedocs.io/en/latest/quickstart.html#defining-variables>`_.

The following example is the generalized assignement problem.
Consider a set of machines ``Machines = 1:M`` and a set of jobs ``Jobs = 1:J``.
A machine ``m`` has a resource capacity ``Capacity[m]``. When we assign a job
``j`` to a machine ``m``, the job has a cost ``Cost[m,j]`` and consumes
``Weight[m,j]`` resources of the machine ``m``. The goal is to minimize the jobs
cost sum by assigning each job to a machine while not exceeding the capacity of
each machine ::

  gap = BlockModel(solver = solver)

  @variable(gap, x[m in Machines, j in Jobs], Bin)

  @constraint(gap, cov[0, j in Jobs],
                 sum{ x[m,j], m in Machines } >= 1)

  @constraint(gap, knp[m in Machines],
                 sum{Weight[m,j]*x[m,j], j in Jobs} <= Capacity[m])

  @objective(gap, Min,
                 sum{Cost[m,j]*x[m,j], m in Machines, j in Jobs})

  status = solve(gap)


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

When the block-group has a multiplicity upperbound greater than 1 (like the case of cutting stock problem),
getvalue returns an aggregated solution of the block-group. In order to
get the solution for each occurance of the block-group (from 1 to its upperbound),
getdisaggregatedvalue should be used instead.::

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
