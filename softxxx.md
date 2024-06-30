---
title: Softなんとか
---

# 概要

- softmax写像は最適化問題の形で定式化できる。この定式化はいくつかの側面で見ることができる。
    1. argmax写像（これも最適化問題として定式化できる）にエントロピー正則化を加えたものと解釈できる。
    1. 自由エネルギー（ヘルムホルツエネルギー）の最小化問題と解釈できる。
    1. 最適値のほうは単体上に制限された負のエントロピー関数のルジャンドル=フェンシル変換として表せて、その値はlog-sum-exp関数で計算できる。

# softmax写像

文献[1]を参考に、softmax写像をいくつかの側面で見てみる。

## 最適化問題としての定式化

変数$\boldsymbol{z} = [z_1, \ldots, z_n]^{\top} \in \mathbb{R}^n$について、softmax写像は以下のように計算される。
$$
\mathrm{softmax}(\boldsymbol{z}) = \left( \sum_{j=1}^n \exp (\lambda z_j) \right)^{-1}
\begin{bmatrix}
\exp(\lambda z_1)\\
\vdots\\
\exp(\lambda z_n)\\
\end{bmatrix}
$$
ここで$\lambda > 0$は逆温度とも呼ばれる定数である。

実装上は上記の定義がよく使われる一方で、softmax写像は以下のようにも定式化できる。
$$
\mathrm{softmax}(\boldsymbol{z}) = \mathop{\arg \max}_{\boldsymbol{x} \in \Delta^{n-1}} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \lambda^{-1} \sum_{j=1}^n x_j \log x_j \right]
$$
ここで、$\Delta^{n-1}$は以下のように定義される$(n-1)$次元単体である。
$$
\Delta^{n-1} = \left\{ \boldsymbol{x} \in \mathbb{R}^n \,\middle\vert\, \sum_{j=1}^{n} x_j = 1, x_j \geq 0 \ \text{for}\ j = 1, \ldots, n \right\}
$$

## argmax写像との関係

argmax写像を次式のように定義する。
$$
\mathrm{argmax}(\boldsymbol{z}) = \mathop{\arg \max}_{\boldsymbol{x} \in \Delta^{n-1}} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} \right]
$$
argmax写像は、$\boldsymbol{z}$の要素のうち最大値をとるところを1に、その他のところを0にした変数$\boldsymbol{x}$を返す。
例えば$\boldsymbol{z} = [-1, 5, 1.2]^{\top}$に対して$\mathrm{argmax}(\boldsymbol{z}) = [0, 1, 0]^{\top}$となる。
$\boldsymbol{z}$が複数の要素で最大値をとるときは解も複数になる。
例えば$\boldsymbol{z} = [3, 2, 3]^{\top}$に対しては$\mathrm{argmax}(\boldsymbol{z}) = \left\{ [a, 0, 1 - a]^{\top} \,\middle\vert\, 0 \leq a \leq 1 \right\}$となる。
すなわち、argmax写像は多価写像である。

softmax写像は、上記のargmax写像の拡張版とみることができる。
argmax写像の目的関数に正則化項$\left( -\sum_{j=1}^n x_j \log x_j \right)$を加えた形である。
このとき$\lambda$は正則化の強さを定める定数とみなせる。
$\boldsymbol{x}$を離散確率分布と解釈すると、この正則化項は情報理論におけるエントロピーと解釈することができる。
すなわち、**softmax写像はargmax写像にエントロピー正則化を加えたものと解釈できる**。
argmax写像は解が複数ある多価写像であるが、正則化を加えたsoftmax写像は解が唯一に定まる。

## 自由エネルギー最小化との関係

softmax写像は自由エネルギー（ヘルムホルツエネルギー）を最小化する写像とも解釈できる。
softmax写像を最適化問題として定式化したときの目的関数に$-1$を乗じたものを考える。
$$
-\boldsymbol{x}^{\top}\boldsymbol{z} - \lambda^{-1} \left( -\sum_{j=1}^n x_j \log x_j \right)
$$
$\lambda$が逆温度であることから$\lambda^{-1}$は温度とみなせる。
また、$\left( -\sum_{j=1}^n x_j \log x_j \right)$はエントロピーと解釈できるのだった。
ここで、$(-\boldsymbol{x}^{\top}\boldsymbol{z})$を内部エネルギーだと解釈してみる。
すると、上記の目的関数の値は熱力学におけるヘルムホルツエネルギーに対応する。
熱力学においてヘルムホルツエネルギー$F$は、内部エネルギー$U$、温度$T$、エントロピー$S$に対して$F = U - T S$の関係がある。
このことから、softmax写像は自由エネルギー$F$を使って以下のように表せる。
$$
\begin{aligned}
\mathrm{softmax}(\boldsymbol{z})
&= \mathop{\arg \max}_{\boldsymbol{x} \in \Delta^{n-1}} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \lambda^{-1} \sum_{j=1}^n x_j \log x_j \right] \\
&= \mathop{\arg \min}_{\boldsymbol{x} \in \Delta^{n-1}} \left[ -\boldsymbol{x}^{\top}\boldsymbol{z} - \lambda^{-1} \left( -\sum_{j=1}^n x_j \log x_j \right) \right]\\
&= \mathop{\arg \min}_{\boldsymbol{x} \in \Delta^{n-1}} F
\end{aligned}
$$
すなわち、**softmax写像は自由エネルギーを最小化する写像とも解釈できる**。

## 最適値について

softmax写像は上記のように最適解を求める問題（argmax）として表されるが、今度は最適値（max）のほうを考える。
まず、単体上に制限された負のエントロピー関数$\psi: \mathbb{R}^n \rightarrow \mathbb{R} \cup \{+\infty\}$を考える。
$$
\psi(\boldsymbol{x}) \triangleq
\begin{cases}
    \lambda^{-1} \sum_{j=1}^n x_j \log x_j & \boldsymbol{x} \in \Delta^{n-1}\\
    +\infty & \boldsymbol{x} \notin \Delta^{n-1}
\end{cases}
$$
この$\psi$を使うと、softmax写像は以下のように書き直せる。
$$
\mathrm{softmax}(\boldsymbol{z}) = \mathop{\arg \max}_{\boldsymbol{x} \in \mathbb{R}^n} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \psi(\boldsymbol{x}) \right]
$$
なお、$\psi$は単体$\Delta^{n-1}$の外で$+\infty$の値をとるので、上記の最適化問題では制約条件が不要になる。

上記の最適化問題の最適値は以下の形で表せる。
$$
\max_{x \in \mathbb{R}^n} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \psi(\boldsymbol{x}) \right]
$$
これは$\psi$の[ルジャンドル=フェンシル変換](https://ja.wikipedia.org/wiki/%E5%87%B8%E5%85%B1%E5%BD%B9%E6%80%A7)の形である。
よって、以下のように表せる。
$$
\psi^*(\boldsymbol{z}) = \max_{x \in \mathbb{R}^n} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \psi(\boldsymbol{x}) \right]
$$
$\psi^*(\boldsymbol{z})$の値は以下の式で計算できる。
$$
\psi^*(\boldsymbol{z}) = \lambda^{-1} \log \left[ \sum_{j=1}^n \exp(\lambda z_j) \right]
$$
これはいわゆるlog-sum-exp関数である。
つまり、softmax写像を最適化問題として定式化したとき、**最適値は負のエントロピー関数のルジャンドル=フェンシル変換であり、その値はlog-sum-exp関数で計算できる**。

# 参考文献

1. Bolin Gao and Lacra Pavel, "On the Properties of the Softmax Function with Application in Game Theory and Reinforcement Learning," arXiv preprint, arXiv:1704.00805v4, 2018. URL: [https://arxiv.org/abs/1704.00805](https://arxiv.org/abs/1704.00805)
