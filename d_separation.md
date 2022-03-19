# 概要

Graphical modelにおいて経路がブロックされるのは以下の３つのとき：

1. ノードが観測済でhead-to-tailである。
![head-to-tail observed](d_separation/head2tail_observed.svg)
2. ノードが観測済でhead-to-headである。
![head-to-tail observed](d_separation/tail2tail_observed.svg)
3. ノードがhead-to-headで，自身もその子孫すべても未観測である。
![head-to-head non-observed for all descendants](d_separation/head2head_descendants.svg)

2つのノードの間にあるすべての経路がブロックされていれば，その2つは条件付き独立となる。
