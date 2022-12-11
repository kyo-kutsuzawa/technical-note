---
title: Dynamic Locomotion in the MIT Cheetah 3 Through Convex Model-Predictive Control
---

Jared Di Carlo, Patrick M. Wensing, Benjamin Katz, Gerardo Bledt, and Sangbae Kim, "Dynamic Locomotion in the MIT Cheetah 3 Through Convex Model-Predictive Control," in Proceedings of 2018 IEEE/RSJ International Conference on Intelligent Robots and Systems, 2018, pp. 1--9. [Online Available](https://ieeexplore.ieee.org/document/8594448)

# 要約

4脚ロボットの歩行を，簡易な物理モデルを用いたMPCによって高速かつ頑健に制御する手法を提案した。

# 制御則

各脚について，**脚が接地しているかどうかで制御則を切り替える**。
接地時にはMPCを，浮遊時にはPD制御を使って制御する。
各脚の接地状態は一定周期で切り替わるように制御される。

## 遊脚の制御

遊脚は動力学補償と加速度フィードフォワード制御がついたPD制御で制御される。
$i$ 番目の脚のトルク指令 $\boldsymbol{\tau}_i$ は以下のように計算される：
$$
\boldsymbol{\tau}_i = \boldsymbol{J}_i^{\top} \left[ \boldsymbol{K}_{\mathrm{p}} (\boldsymbol{p}_{i, \mathrm{ref}} - \boldsymbol{p}_i) + \boldsymbol{K}_{\mathrm{d}} (\boldsymbol{v}_{i,\mathrm{ref}} - \boldsymbol{v}_i) \right] + \boldsymbol{\tau}_{i, \mathrm{ff}}
$$
$\boldsymbol{p}_i$ は足先の位置，$\boldsymbol{v}_i$ は足先の速度である。
$\bullet_{\mathrm{ref}}$ は指令値を表す。
また，$\boldsymbol{K}_{\mathrm{p}}, \boldsymbol{K}_{\mathrm{d}}$ は制御ゲイン，$\boldsymbol{J}_i$ は $i$ 番目の脚のヤコビ行列である。
$\boldsymbol{\tau}_{i,\mathrm{ff}}$ はフィードフォワード指令で，以下のように計算される：
$$
\boldsymbol{\tau}_{i,\mathrm{ff}} = \boldsymbol{J}^{\top}  \boldsymbol{\Lambda}_i (\boldsymbol{a}_{i, \mathrm{ref}} - \dot{\boldsymbol{J}}_i \dot{\boldsymbol{q}}_i) + \boldsymbol{C}_i \dot{\boldsymbol{q}}_i + \boldsymbol{G}_i
$$
$\boldsymbol{a}_{i, \mathrm{ref}}$ は足先の加速度指令であり，$\dot{\boldsymbol{q}}_i$ は関節角速度である。
$\boldsymbol{\Lambda}$ は関節からみた慣性を表す。
また，$\boldsymbol{C}_i \dot{\boldsymbol{q}}_i$ はコリオリ力を，$\boldsymbol{G}_i$ は重力を表す。
比例ゲイン $\boldsymbol{K}_{\mathrm{p}}$ は，脚の見かけの慣性変化によらず自然角周波数が一定となるように調整される。
$$
K_{\mathrm{p}, i} = \omega_i^2 \Lambda_{i, i}
$$

遊脚の接地位置は，_Raibert, 1986_ （読んでいない）をヒントにしたヒューリスティックな手法によって決定される。
ざっくり言うと重心の速度方向に向けて足を置くように決定される。
具体的には，$x$-$y$ 平面上での目標接地位置は次式で決定される：
$$
\boldsymbol{p}^{\mathrm{des}} = \boldsymbol{p}^{\mathrm{ref}} + \boldsymbol{v}^{\mathrm{CoM}} \frac{\Delta t}{2}
$$
$\Delta t$ は接地期間，$\boldsymbol{p}^{\mathrm{ref}}$ は腰の位置を $x$-$y$ 平面に射影した位置，$\boldsymbol{v}^{\mathrm{CoM}}$ はロボットの重心速度を $x$-$y$ 平面に射影したベクトルである。
接地したかどうかは _Bledt et al., 2018_ （ちゃんと読んでいない）のアルゴリズムで検出され，もしも予定より早い時間に接地した場合は即座に制御則を接地時のものに切り替える。

## 支持脚の制御

支持脚は**床反力が所望の値となるようにトルク制御**される。
参照トルクは所望の床反力からヤコビ行列を使って算出される。
$$
\boldsymbol{\tau}_i = \boldsymbol{J}_i^{\top} \boldsymbol{R}_i^{\top} \boldsymbol{f}_i
$$
ここで $\boldsymbol{J}_i$ は $i$ 番目の脚のヤコビ行列であり， $\boldsymbol{R}_i$ はロボットの身体をワールド座標系に変換する回転行列である。

各脚の所望の床反力は，MPCによって算出される。
まず，ロボットの運動は **脚を無視してひとつの剛体としてモデル化** される：
$$
\ddot{\boldsymbol{p}} = \frac{1}{m} \sum_{i=1}^{n} \boldsymbol{f}_i - \boldsymbol{g}
$$
$$
\frac{\mathrm{d}}{\mathrm{d}t} (\boldsymbol{I} \boldsymbol{\omega}) = \sum_{i=1}^n \boldsymbol{r}_i \times \boldsymbol{f}_i
$$
$$
\dot{\boldsymbol{R}} = [\boldsymbol{\omega}]_{\times} \boldsymbol{R}
$$
さらに角運動量の時間微分について**ジャイロモーメントの影響をゼロに近似**することで，回転に関する運動方程式を線形近似できる：
$$
\frac{\mathrm{d}}{\mathrm{d}t} (\boldsymbol{I} \boldsymbol{\omega}) = \boldsymbol{I} \dot{\boldsymbol{\omega}} + \boldsymbol{\omega} \times (\boldsymbol{I} \boldsymbol{\omega}) \approx \boldsymbol{I} \dot{\boldsymbol{\omega}}
$$
すると，ロボットの並進と回転のダイナミクスは局所的に線形状態方程式で表現できる：
$$
\frac{\mathrm{d}}{\mathrm{d}t} \boldsymbol{x}(t) = \boldsymbol{A}_{\mathrm{c}}(\psi) \boldsymbol{x} + \boldsymbol{B}_{\mathrm{c}}(\boldsymbol{r}_1, \ldots, \boldsymbol{r}_n, \psi) \boldsymbol{u}(t)
$$
これを離散化すると，最終的に離散時間状態方程式は以下のように表現できる：
$$
\boldsymbol{x}_{i+1} = \boldsymbol{A}_i \boldsymbol{x}_i + \boldsymbol{B}_i \boldsymbol{u}_i
$$
状態方程式は最適化においては等式制約として利用される。

この他に，各脚の床反力は静止摩擦の範囲内でのみ発揮できること，および支持脚のみが床反力を発生できることも制約として利用される。
静止摩擦に関する条件は以下のように表現される：
$$
f_{\mathrm{min}} \leq f_z \leq f_{\mathrm{max}}
$$
$$
-\mu f_z \leq \pm f_x \leq \mu f_z
$$
$$
-\mu f_z \leq \pm f_y \leq \mu f_z
$$

最終的に，状態変数を所望の値に2乗誤差の意味で近づける問題は**制約付き2次計画問題**として定式化できる：
$$
\begin{aligned}
\min_{\boldsymbol{x}, \boldsymbol{u}}& \sum_{i=0}^{k-1} \| \boldsymbol{x}_{i+1} - \boldsymbol{x}_{i+1, \mathrm{ref}} \|_{\boldsymbol{Q}_i} + \| \boldsymbol{u}_i \|_{\boldsymbol{R}_i} \\
\text{subject to }& \boldsymbol{x}_{i+1} = \boldsymbol{A}_i \boldsymbol{x}_i + \boldsymbol{B}_i \boldsymbol{u}_i, \\
& \underline{\boldsymbol{c}}_i \leq \boldsymbol{C}_i \boldsymbol{x}_i \leq \bar{\boldsymbol{c}}_i, \\
& \boldsymbol{D}_i \boldsymbol{u}_i = 0.
\end{aligned}
$$

さらにまとめ直すと以下のような形式に帰着できる：
$$
\begin{aligned}
\min_{\boldsymbol{U}}& \boldsymbol{U}^\top \boldsymbol{H} \boldsymbol{U} + \boldsymbol{U}^\top \boldsymbol{g} \\
\text{subject to }& \underline{\boldsymbol{c}} \leq \boldsymbol{C} \boldsymbol{U} \leq \bar{\boldsymbol{c}}.
\end{aligned}
$$
$\boldsymbol{U} \in \mathbb{R}^{3nk}$ は $n$ 本の脚についての $k$ ステップ分の制御入力である。

# 検証

計算には2011年のIntel Core i7を使った。
状態推定や遊脚制御などはMatlab/simulinkで実装したものをC言語に変換して走らせた。
MPCはC++で実装された。
線形代数計算にはEigen3を使い，制約付き2次計画問題にはqpOASESを使った。

ギャロップの制御において，計算速度はおおむね0.2～0.3 msくらいで，遅くても0.5 ms以内であった。
そのほか，立位やトロット，flying trot，ペース，バウンド，プロンク，3-legged gaitも実現した。

トロットで速度を上げすぎると，遊脚が他の脚に接触してしまった。
また，あまりにも腰の速度が速いと遊脚の制御が追い付かなかった。
それによって姿勢制御の性能が悪くなり，実験用のトレッドミルから落ちてしまうことがあった。
シミュレーション内で脚の最高速度を上げてみたら高速度でもちゃんと移動できた。

# 今後の展望

今回は歩容が事前に設計されたものだったので，そこを上位の動作計画で決定できると頑健性や性能が向上するだろう。

# 感想とか

- MPCすごい。シンプルなモデル化でも制御周期が十分短ければ機能するんだなというのが印象的。
- 遊脚の制御と支持脚の制御とがまったく別々に設計されているが，これはやはり足の接触状態でダイナミクスが不連続に切り替わるからだろうか。そのあたりは学習ベースの手法のほうが得意？

# 参考文献

1. M. H. Raibert, Legged Robots That Balance. Cambridge, MA, USA: Massachusetts Institute of Technology, 1986.
2. G. Bledt, P. M. Wensing, S. Ingersoll, and S. Kim, “Contact model fusion for event-based locomotion in unstructured terrains,” in Proceedings of 2018 IEEE International Conference on Robotics and Automation, 2018, pp. 4399--4406.
