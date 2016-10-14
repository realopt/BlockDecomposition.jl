.. _introduction:

-----------------
Introduction
-----------------

BlockJuMP.jl is a package providing features to take advantage of the shape
of block structured problem. In other words, problems which have the set of
variables and constraints splitted into blocks.

Consider the following block structured problem

.. math::

  \begin{array}{c c c c c c c c c c c c c c}
    [F] \equiv \text{ min }
                       & c^{1} x^{1} & + & c^{2} x^{2} & + & c^{3} x^{3} & + & \cdots & + & c^{K} x^{K}             &        &   \\
    \text{mcst}_{i_0}: & a^{1} x^{1} & + & a^{2} x^{2} & + & a^{3} x^{3} & + & \cdots & + & a^{K} x^{K}             & \leq   & b_0 \\
    \text{scst}_{i_1}: & d^{1} x^{1} &   &                 &   &                 &   &        &   &                 & \leq   & b_1 \\
    \text{scst}_{i_2}: &                 &   & d^{2} x^{2} &   &                 &   &        &   &                 & \leq   & b_2 \\
    \text{scst}_{i_3}: &                 &   &                 &   & d^{3} x^{3} &   &        &   &                 & \leq   & b_3 \\
    \vdots             &                 &   &                 &   &             &   & \ddots &   &                 & \vdots &   \\
    \text{scst}_{i_K}: &                 &   &                 &   &             &   &        &   & d^{K} x^{K}     & \leq   & b_K \\
  \end{array}

with :math:`i_n = (i_{n}^1, i_{n}^2 \cdots i_{n}^l)` the multi-index of each variable/constraint.

Through this example, we will introduce the concepts of block-identification
implemented by BlockJuMP.

Block indentification
^^^^^^^^^^^^^^^^^^^^^

Consider :math:`b \in \mathbb{N}`, the number of indices used for the
block-identification. In other words the block multi-index is made of :math:`b` indices.

If :math:`b = 0`, there is no block-identification.

If :math:`b = 1`, the block-identification is done according to the first index of
each (variable/constraint) multi-index. In other words, the block multi-index
has one index. Thus, if
:math:`i_{p}^1 = i_{q}^1` , constraints :math:`\text{scst}_{i_p}` and
:math:`\text{scst}_{i_q}` are in the same block.

If :math:`b = 2`, the block-identification is done according to the two first elements
of each (variable/constraint) multi-index.
In other words, the block multi-index has 2 indices. Thus,
if :math:`(i_{p}^1, i_{p}^2) = (i_{q}^1, i_{q}^2)` , constraints
:math:`\text{scst}_{i_p}` and :math:`\text{scst}_{i_q}` are in the same block.

`Et cetera.`
