---
title: Softなんとかとエントロピーと自由エネルギー
---

# 概要

- softmax写像は最適化問題の形で定式化できる。この定式化はいくつかの側面で見ることができる。
    1. argmax写像（これも最適化問題として定式化できる）にエントロピー正則化を加えたものと解釈できる。
    1. 自由エネルギー（ヘルムホルツエネルギー）の最小化問題と解釈できる。
    1. 最適値は単体上に制限された負のエントロピー関数のルジャンドル=フェンシル変換として表せて、その値はlog-sum-exp関数で計算できる。

# Softmax写像

文献[1]を参考に、softmax写像をいくつかの側面で見てみる。

## 最適化問題としての定式化

変数$\boldsymbol{z} = [z_1, \ldots, z_n]^{\top} \in \mathbb{R}^n$について、softmax写像は以下のように表される。
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
ここで、単体$\Delta^{n-1}$は以下のように定義される集合である。
$$
\Delta^{n-1} = \{ \boldsymbol{x} \in \mathbb{R}^n \mid \| \boldsymbol{x} \|_1 = 1, x_i \leq 0 \}
$$

## argmax写像との関係

argmax写像を次式のように定義する。
$$
\mathrm{argmax}(\boldsymbol{z}) = \mathop{\arg \max}_{\boldsymbol{x} \in \Delta^{n-1}} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} \right]
$$
argmax写像は、$\boldsymbol{z}$の要素のうち最大値をとるところを1に、その他のところを0にした変数$\boldsymbol{x}$を返す。
例えば$\boldsymbol{z} = [-1, 5, 1.2]^{\top}$に対して$\mathrm{softmax}(\boldsymbol{z}) = [0, 1, 0]^{\top}$となる。
$\boldsymbol{z}$が複数の要素で最大値をとるときは解も複数になる。
例えば$\boldsymbol{z} = [3, 2, 3]^{\top}$に対しては$\mathrm{softmax}(\boldsymbol{z}) = \left\{ [1, 0, 0]^{\top}, [0, 0, 1]^{\top} \right\}$となる。
すなわち、この写像は多価写像である。

softmax写像は、上記のように定義されるargmax写像の拡張版とみることができる。
argmax写像の最適化関数に正則化項$\left( -\sum_{j=1}^n x_j \log x_j \right)$を加えた形である。
このとき$\lambda$は正則化の強さを定める定数とみなせる。
$\boldsymbol{x}$を離散確率分布と解釈すると、この正則化項は情報理論におけるエントロピーと解釈することができる。
すなわち、**softmax写像はargmax写像にエントロピー正則化を加えたものと解釈できる**。

## 自由エネルギー最小化との関係

softmax写像は自由エネルギー（ヘルムホルツエネルギー）を最小化する写像とも解釈できる。
softmax写像を最適化問題として定式化したときの最適化関数に$-1$を乗じたものを考える。
$$
-\boldsymbol{x}^{\top}\boldsymbol{z} - \lambda^{-1} \left( -\sum_{j=1}^n x_j \log x_j \right)
$$
$\lambda$が逆温度であることから$\lambda^{-1}$は温度とみなせる。
また、$\left( -\sum_{j=1}^n x_j \log x_j \right)$はエントロピーと解釈できるのだった。
ここで、$(-\boldsymbol{x}^{\top}\boldsymbol{z})$を内部エネルギーと解釈してみる。
すると、上記の量は熱力学におけるヘルムホルツエネルギーに対応する。
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

## log-sum-exp関数との関係

ちょっと話がそれる。
単体上に制限された負のエントロピー関数$\psi: \mathbb{R}^n \rightarrow \mathbb{R} \cup \{+\infty\}$を考える。
$$
\psi(\boldsymbol{x}) \triangleq
\begin{cases}
    \lambda^{-1} \sum_{j=1}^n x_j \log x_j & \boldsymbol{x} \in \Delta^{n-1}\\
    +\infty & \boldsymbol{x} \notin \Delta^{n-1}
\end{cases}
$$
softmax写像の最適化関数はこの$\psi$を使って以下のようにも書ける。
$$
\mathrm{softmax}(\boldsymbol{z}) = \mathop{\arg \max}_{\boldsymbol{x} \in \Delta^{n-1}} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \psi(\boldsymbol{x}) \right]
$$

このとき、$\psi$の[ルジャンドル=フェンシル変換](https://ja.wikipedia.org/wiki/%E5%87%B8%E5%85%B1%E5%BD%B9%E6%80%A7)は以下のように表される。
$$
\psi^*(\boldsymbol{z}) = \max_{x} \left[ \boldsymbol{x}^{\top}\boldsymbol{z} - \psi(\boldsymbol{x}) \right]
$$
その解は以下のように表される。
$$
\psi^*(\boldsymbol{z}) = \lambda^{-1} \log \left[ \sum_{j=1}^n \exp(\lambda z_j) \right]
$$
この関数はいわゆるlog-sum-exp関数でもある。
先ほどの自由エネルギーの話と絡めると、**log-sum-exp関数は負のエントロピー関数のルジャンドル=フェンシル変換であり、最小自由エネルギーを表すと解釈できる**。

# 参考文献

1. Bolin Gao and Lacra Pavel, "On the Properties of the Softmax Function with Application in Game Theory and Reinforcement Learning," arXiv preprint, arXiv:1704.00805v4, 2018. URL: [https://arxiv.org/abs/1704.00805](https://arxiv.org/abs/1704.00805)
