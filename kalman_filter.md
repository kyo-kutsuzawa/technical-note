---
title: カルマンフィルタの導出
---

# 概要

- カルマンフィルタは、観測値から状態変数を逐次推定するためによく使われる技術である。
- 制御分野においては推定誤差の最小化に基づいて導出されることが多いが、一般的な確率的推論の特殊例として導出することも可能である。
- ベイズフィルタ（状態変数の確率分布を逐次的に求める手続き）に系の動的モデルを代入することで、カルマンフィルタに対応する推定手続きが得られる。途中計算はかなりややこしいが、最終的にはきれいな形に行きつく。

# 背景

カルマンフィルタは、制御分野において状態推定のためによく使われる技術である。
ロケットの軌道推定やカーナビ、あるいは経済学にも応用されており、古くはアポロ計画にも利用された実績がある。

カルマンフィルタは実装が比較的容易である一方で、推定アルゴリズムの導出は少しややこしい。
制御分野で見かける導出では、系の線形性とか雑音のガウス性とかを先に仮定して、推定誤差の最小化に基づいて導出することが多い。

一方で、カルマンフィルタを確率的推論の特殊例として導出することも可能である。
この導出手順を知っておくと、より一般的な状態推定手法であるベイズフィルタなどとの関連も見通しが立ちやすいと思う。

# カルマンフィルタのアルゴリズム

ある系の状態方程式と観測方程式が以下のように記述できるとする。
$$
\begin{aligned}
x_k &= A_k x_{k-1} + B_k u_k + w_k \\
y_k &= C_k x_k + v_k
\end{aligned}
$$
ここで、$x_k$と$y_k$はそれぞれ、時刻$k$における状態変数と観測変数である。
また、$u_k$は制御入力であり、$w_k$と$v_k$はシステム雑音と観測雑音である。
雑音は以下の確率分布に従ってサンプリングされるものと仮定する。
$$
\begin{aligned}
w_k &\sim \mathcal{N}(w_k; 0, R) \\
v_k &\sim \mathcal{N}(v_k; 0, Q)
\end{aligned}
$$
ここで$\mathcal{N}$は正規分布を表し、以下のように定義される。
$$
\mathcal{N}(x; \mu, \Sigma) \triangleq \det(2\pi\Sigma)^{-\frac{1}{2}} \exp \left[-\frac{1}{2}(x - \mu)^{\top} \Sigma^{-1} (x - \mu) \right]
$$

カルマンフィルタは、時刻$k-1$での状態変数$x_{k-1}$が平均$\mu_{k-1}$、分散$\Sigma_{k-1}$の正規分布に従うとして、以下の手順で時刻$k$での状態変数の期待値$\mu_k$と分散$\Sigma_k$を計算する。

1. 予測ステップ
$$
\begin{aligned}
\bar{\mu}_{k} &= A_k \mu_{k-1} + B_k u_k \\
\bar{\Sigma}_{k} &= A_k \Sigma_{k-1} A_k^{\top} + R_k
\end{aligned}
$$
2. カルマンゲインの算出
$$
K_k = \bar{\Sigma}_k C_k^{\top} (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}
$$
3. 更新ステップ
$$
\begin{aligned}
\mu_k &= \bar{\mu}_{k} + K_k (y_k - C_k \bar{\mu}_k) \\
\Sigma_k &= (I - K_k C_k) \bar{\Sigma}_{k}
\end{aligned}
$$

# 確率モデルの定式化

まずは、線形性も正規性も仮定せず、一般的な隠れマルコフモデルとして系全体の確率モデルを定式化する。

表記の簡単化のため、ある変数$v$の時刻$k_1$から$k_2$にかけての時系列を、まとめて以下のように表記する。
$$
v_{k_1:k_2} \triangleq (v_{k_1}, v_{k_1 + 1}, \ldots, v_{k_2})
$$
この表記を使うと、系全体の生成モデルは以下のように表せる。
$$
\begin{aligned}
p(x_{0:k}, y_{0:k})
&= \left[ \prod_{l = 1}^{k} p(y_l | x_l) p(x_l | x_{l - 1}) \right] p(y_0 | x_0) p(x_0)\\
&= p(y_k | x_k) p(x_{0:k}, y_{0:k-1})\\
&= p(y_k | x_k) p(x_k | x_{k - 1}) p(x_{0:k-1}, y_{0:k-1})
\end{aligned}
$$
状態変数にマルコフ性があると仮定することで、生成過程は最後の式のように逐次的な形で表せる。

# 一般的な推定手続きの導出

上記の生成モデルを使って、まずは一般的な推定手続きを導出する。
ここで求めたいのは、現在の時刻$k$での状態変数$x_k$である。
観測変数の時系列$y_{0:k}$がわかっているとすると、求めるべき確率分布は以下のものになる。
$$
p(x_k | y_{0:k})
$$
すなわち、観測変数の時系列が与えられたときの、現在の状態変数の確率分布である。
これがわかれば、その分布の期待値あるいは最頻値として、確率的に最適な推定値を求めることができる。

最終的な目標を、1時刻前の確率分布$p(x_{k-1}| y_{0:k-1})$を使って現在の確率分布$p(x_k| y_{0:k})$を導出することとする。
これが計算できれば、新しい観測値が得られるたびに推定値を逐次更新することができる。

結論から言うと、以下の手順によって状態変数の確率分布を更新できる。
カルマンフィルタと似た手順である。

1. $p(x_{k-1}| y_{0:k-1})$が与えられているとする（時刻$0$の場合は$p(x_{0})$）。
2. 予測ステップ：状態遷移のモデルを使って、現在の状態変数の確率分布を計算する。すなわち、$p(x_{k-1}| y_{0:k-1})$と$p(x_k| x_{k-1})$から$p(x_{k}| y_{0:k-1})$を求める:
$$
p(x_{k}| y_{0:k-1}) = \int p(x_k| x_{k-1}) p(x_{k-1}| y_{0:k-1}) \mathrm{d}x_{k-1} \qquad (1)
$$
3. 更新ステップ：新しい観測値$y_k$が得られたら、それを使って状態変数の確率分布を更新する。すなわち、$p(x_{k}| y_{0:k-1})$と$p(y_{k}| x_{k})$から$p(x_{k}| y_{0:k})$を求める：
$$
p(x_k| y_{0:k}) = \frac{p(y_k| x_k) p(x_k| y_{0:k-1})}{\int p(y_k| x_k) p(x_k| y_{0:k-1}) \mathrm{d}x_{k}} \qquad (2)
$$

以降では式(1)と(2)を導出していく。

## 予測ステップの導出

まずは式(1)について。
すなわち、時刻$k$での観測値が得られる前の推定
$$
p(x_k| y_{0:k-1})
$$
を求める。
これを展開すると、
$$
\begin{aligned}
p(x_k| y_{0:k-1})
&= \frac{p(x_k, y_{0:k-1})}{p(y_{0:k-1})}\\
&= \frac{\int p(x_{0:k}, y_{0:k-1}) \mathrm{d}x_{0:k-1}}{\int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-1}}\\
&= \frac{\int p(x_k| x_{k-1}) \int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-2} \mathrm{d}x_{k-1}}{\int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-1}}\\
&= \int p(x_k| x_{k-1}) \frac{\int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-2}}{\int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-1}} \mathrm{d}x_{k-1}
\end{aligned}
$$
のようになる。
ここで、
$$
\begin{aligned}
    p(x_{k-1}| y_{0:k-1})
    &= \frac{p(x_{k-1}, y_{0:k-1})}{p(y_{0:k-1})}\\
    &= \frac{\int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-2}}{\int p(x_{0:k-1}, y_{0:k-1}) \mathrm{d}x_{0:k-1}}
\end{aligned}
$$
であることから、
$$
p(x_k| y_{0:k-1}) = \int p(x_k| x_{k-1}) p(x_{k-1}| y_{0:k-1}) \mathrm{d}x_{k-1}
$$
と求まる。

## 更新ステップの導出

続いて、式(2)について。
すなわち、観測値$y_k$が得られたときの状態変数の推定
$$
p(x_k| y_{0:k})
$$
を求める。
この確率分布は、単純にベイズの定理を適用すればいい。
展開すると、
$$
\begin{aligned}
p(x_k| y_{0:k})
&= p(x_k| y_k, y_{0:k-1})\\
&= \frac{p(y_k| x_k, y_{0:k-1}) p(x_k| y_{0:k-1})}{p(y_k| y_{0:k-1})}\\
&= \frac{p(y_k| x_k, y_{0:k-1}) p(x_k| y_{0:k-1})}{\int p(y_k, x_k| y_{0:k-1}) \mathrm{d}x_k}\\
&= \frac{p(y_k| x_k, y_{0:k-1}) p(x_k| y_{0:k-1})}{\int p(y_k| x_k, y_{0:k-1}) p(x_k| y_{0:k-1}) \mathrm{d}x_k}
\end{aligned}
$$
のようになる。
ここで、有向分離によって
$$
p(y_k| x_k, y_{0:k-1}) = p(y_k| x_k)
$$
が得られることを使うと、最終的に、
$$
p(x_k| y_{0:k}) = \frac{p(y_k| x_k) p(x_k| y_{0:k-1})}{\int p(y_k| x_k) p(x_k| y_{0:k-1}) \mathrm{d}x_k}
$$
が求まる。

# カルマンフィルタの導出

ここからは、上記の推定手続きに系の線形性や雑音の正規性などを入れていくことで、カルマンフィルタの導出をしていく。
なお、以降の導出手順は _Thrun et al., 2005_ に基づく。

確率分布を以下のように定式化する。
$$
\begin{aligned}
p(x_0) &= \mathcal{N}(x_0; \mu_0, \Sigma_0)\\
p(x_k| x_{k-1}) &= \mathcal{N}(x_k; A_k x_{k-1} + B_k u_k, R_k)\\
p(y_k| x_k) &= \mathcal{N}(y_k; C_k x_k, Q_k)
\end{aligned}
$$
また、時刻$k-1$での状態変数の事後分布を正規分布と仮定する。
$$
p(x_{k-1}| y_{0:k-1}) = \mathcal{N}(x_{k-1}; \mu_{k-1}, \Sigma_{k-1})
$$

これらを式(1)と(2)に代入していく。
途中計算は非常に長く複雑なものになるが、最終的にはカルマンフィルタの更新式に対応した正規分布の形に行きつく。
すなわち、
$$
\begin{aligned}
p(x_k| y_{0:k-1}) &= \mathcal{N}(x_k; A_k \mu_{k-1} + B_k u_k, A_k \Sigma_{k-1} A_k^{\top} + R_k) \\
p(x_k| y_{0:k}) &= \mathcal{N}(x_k; \bar{\mu}_{k} + K_k (y_k - C_k \bar{\mu}_k), (I - K_k C_k) \bar{\Sigma}_{k})
\end{aligned}
$$
が求まる。

## 予測ステップの導出

まずは予測ステップについて考える。
観測値が得られる前の現在の状態変数の確率分布$p(x_k| y_{0:k-1})$は以下のようになる。
$$
\begin{aligned}
p(x_k| y_{0:k-1})
&= \int p(x_k| x_{k-1}) p(x_{k-1}| y_{0:k-1}) \mathrm{d}x_{k-1} \\
&= \int \mathcal{N}(x_k; A_k x_{k-1} + B_k u_k, R_k) \mathcal{N}(x_{k-1}; \hat{x}_{k-1}, \Sigma_{k-1}) \mathrm{d}x_{k-1} \\
&= \int \det(2\pi R_k)^{-\frac{1}{2}} \exp \left[-\frac{1}{2}\{x_k - (A_k x_{k-1} + B_k u_k)\}^{\top} R_k^{-1} \{x_k - (A_k x_{k-1} + B_k u_k)\} \right] \det(2\pi\Sigma_k)^{-\frac{1}{2}} \exp \left[-\frac{1}{2}(x_{k-1} - \mu_{k-1})^{\top} \Sigma_{k-1}^{-1} (x_{k-1} - \mu_{k-1}) \right] \mathrm{d}x_{k-1} \\
&= \det(2\pi R_k)^{-\frac{1}{2}} \det(2\pi\Sigma_k)^{-\frac{1}{2}} \int \exp \left(-\frac{1}{2} \left[\{x_k - (A_k x_{k-1} + B_k u_k)\}^{\top} R_k^{-1} \{x_k - (A_k x_{k-1} + B_k u_k)\} + (x_{k-1} - \mu_{k-1})^{\top} \Sigma_{k-1}^{-1} (x_{k-1} - \mu_{k-1}) \right]\right) \mathrm{d}x_{k-1} \\
&= \eta \int \exp \left(-\frac{1}{2} L \right) \mathrm{d}x_{k-1}
\end{aligned}
$$
ここで、定数係数を$\eta$に、指数部分を$L$にまとめた。

確率分布は全区間での積分値が1になることから、定数係数$\eta$はその他の部分から一意に決まるので、ひとまず無視していい。
よって、この式において重要なのは指数部分の$L$である。
式には$x_{k-1}$の積分があることから、以下のように、$L$を$x_{k-1}$に依存する項（積分される項）とそうでない項（積分の外に出せる項）とに分けられると便利である。
$$
L = L_1(x_k) + L_2(x_k, x_{k-1})
$$
ここで、天下りだが、以下のような形を求めることにする。
$$
\begin{aligned}
L_1(x_k) &= (x_k - M_1)^{\top} S_1 (x_k - M_1) \\
L_2(x_k, x_{k-1}) &= (x_{k-1} - M_2)^{\top} S_2 (x_{k-1} - M_2)
\end{aligned}
$$
ただし$S_1$と$S_2$は正定値対称行列とする。
また、$M_2$の中には$x_k$が含まれうる。
以降は$L_1(x_k)$と$L_2(x_k, x_{k-1})$の具体的な形を求めていく。

まずは$L_2(x_k, x_{k-1})$について。
$L_2(x_k, x_{k-1})$は$x_{k-1}$の二次式なので、$x_{k-1}$の1階偏微分と2階偏微分から$M_2$と$S_2$が求められる。
$M_2$は$L_2(x_k, x_{k-1}) = 0$の解でもあるので、1階偏微分がゼロとなるときの$x_{k-1}$の値に等しい。
また、$S_2$は$L_2(x_k, x_{k-1})$の2階偏微分で求まる。
$$
M_2 = x_{k-1} \Leftrightarrow \frac{\partial}{\partial x_{k-1}} L_2(x_k, x_{k-1}) = 0
$$
$$
S_2 = \frac{1}{2} \left( \frac{\partial}{\partial x_{k-1}} \right)^2 L_2(x_k, x_{k-1})
$$
ここで、$L_1(x_k)$は$x_{k-1}$を含まないので、$x_{k-1}$で偏微分するとゼロになる。
すなわち、
$$
\frac{\partial}{\partial x_{k-1}} L = \frac{\partial}{\partial x_{k-1}} [L_1(x_k) + L_2(x_k, x_{k-1})] = \frac{\partial}{\partial x_{k-1}} L_2(x_k, x_{k-1})
$$
が成り立つ。
これを使うと、1階偏微分は以下のように求まる。
$$
\begin{aligned}
\frac{\partial}{\partial x_{k-1}} L_2(x_k, x_{k-1})
&= \frac{\partial}{\partial x_{k-1}} L \\
&= \frac{\partial}{\partial x_{k-1}} \left[\{x_k - (A_k x_{k-1} + B_k u_k)\}^{\top} R_k^{-1} \{x_k - (A_k x_{k-1} + B_k u_k)\} + (x_{k-1} - \mu_{k-1})^{\top} \Sigma_{k-1}^{-1} (x_{k-1} - \mu_{k-1}) \right] \\
&= -2 A_k^{\top} R_k^{-1} (x_k - A_k x_{k-1} - B_k u_k) + 2 \Sigma_{k-1}^{-1} (x_{k-1} - \mu_{k-1}) \\
\end{aligned}
$$
2行目から3行目の変形では、偏微分に関する以下の定理を用いた。
$$
\frac{\partial}{\partial x} (B x + c)^{\top} A (B x + c) = 2 B^{\top} A (B x + c)
$$
また、2階偏微分は以下のように求まる。
$$
\begin{aligned}
\left( \frac{\partial}{\partial x_{k-1}} \right)^2 L_2(x_k, x_{k-1})
&= \left( \frac{\partial}{\partial x_{k-1}} \right)^2 L \\
&= \frac{\partial}{\partial x_{k-1}} L \left[ -2 A_k^{\top} R_k^{-1} (x_k - A_k x_{k-1} - B_k u_k) + 2 \Sigma_{k-1}^{-1} (x_{k-1} - \mu_{k-1}) \right] \\
&= 2 A_k^{\top} R_k^{-1} A_k + 2 \Sigma_{k-1}^{-1} \\
\end{aligned}
$$

最終的に、以下が得られる。
$$
\begin{aligned}
S_2 &= A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1}^{-1} \triangleq \Psi_k^{-1} \\
M_2 &= \Psi_k [A_k^{\top} R_k^{-1} (x_k - B_k u_k) + \Sigma_{k-1}^{-1} \mu_{k-1}]
\end{aligned}
$$

続いて、$L_1(x_k)$について。
上の結果より、
$$
\begin{aligned}
L_1(x_k) =& L - L_2(x_k, x_{k-1}) \\
=& \{x_k - (A_k x_{k-1} + B_k u_k)\}^{\top} R_k^{-1} \{x_k - (A_k x_{k-1} + B_k u_k)\} + (x_{k-1} - \mu_{k-1})^{\top} \Sigma_{k-1}^{-1} (x_{k-1} - \mu_{k-1}) \\
&- (x_{k-1} - \Psi_k [A_k^{\top} R_k^{-1} (x_k - B_k u_k)])^{\top} \Psi_k^{-1} (x_{k-1} - \Psi_k [A_k^{\top} R_k^{-1} (x_k - B_k u_k)]) \\
=& (x_k - B_k u_k)^{\top} R_k^{-1} (x_k - B_k u_k) + \mu_{k-1}^{\top} \Sigma_{k-1}^{-1} \mu_{k-1} + [A_k^{\top} R_k^{-1} (x_k - B_k u_k) + \Sigma_{k-1}^{-1} \mu_{k-1}]^{\top} \Psi_k [A_k^{\top} R_k^{-1} (x_k - B_k u_k) + \Sigma_{k-1}^{-1} \mu_{k-1}]
\end{aligned}
$$
が得られる。
$x_{k-1}$が打ち消し合って、すべて消えることがわかる。
これを$x_k$で偏微分して$S_1$と$M_1$を求める。
まずは1階偏微分を計算していく。
$$
\begin{aligned}
\frac{\partial}{\partial x_k} L_1(x_k)
&= 2 R_k^{-1} (x_k - B_k u_k) - 2 R_k^{-1} A_k \Psi_k [A_k^{\top} R_k^{-1} (x_k - B_k u_k) + \Sigma_{k-1}^{-1} \mu_{k-1}] \\
&= 2 [R_k^{-1} - R_k^{-1} A_k \Psi_k A_k^{\top} R_k^{-1}] (x_k - B_k u_k) - 2 R_k^{-1} A_k \Psi_k \Sigma_{k-1}^{-1} \mu_{k-1}
\end{aligned}
$$
これを展開するために、以下に示す逆行列の補助定理を使う。
$$
(R + P Q P^{\top})^{-1} = R^{-1} - R^{-1} P (Q^{-1} + P^{\top} R^{-1} P)^{-1} P^{\top} R^{-1}
$$
実際に使う記号を当てはめると、
$$
\begin{aligned}
(R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1} &= R_k^{-1} - R_k^{-1} A_k (A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1}^{-1})^{-1} A_k^{\top} R_k^{-1} \\
&= R_k^{-1} - R_k^{-1} A_k \Psi_k A_k^{\top} R_k^{-1}
\end{aligned}
$$
となる。
よって、1階偏微分は以下のように求まる。
$$
\frac{\partial}{\partial x_k} L_1(x_k)
= 2 (R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1} (x_k - B_k u_k) - 2 R_k^{-1} A_k \Psi_k \Sigma_{k-1}^{-1} \mu_{k-1}
$$
$\frac{\partial}{\partial x_k} L_1(x_k) = 0$とすると、
$$
\begin{aligned}
\frac{\partial}{\partial x_k} L_1(x_k)
&= 2 (R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1} (x_k - B_k u_k) - 2 R_k^{-1} A_k \Psi_k \Sigma_{k-1}^{-1} \mu_{k-1} = 0 \\
(R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1} (x_k - B_k u_k) &= R_k^{-1} A_k \Psi_k \Sigma_{k-1}^{-1} \mu_{k-1} \\
x_k - B_k u_k &= (R_k + A_k \Sigma_{k-1} A_k^{\top}) R_k^{-1} A_k \Psi_k \Sigma_{k-1}^{-1} \mu_{k-1} \\
x_k &= (R_k + A_k \Sigma_{k-1} A_k^{\top}) R_k^{-1} A_k \Psi_k \Sigma_{k-1}^{-1} \mu_{k-1} + B_k u_k\\
&= (R_k + A_k \Sigma_{k-1} A_k^{\top}) R_k^{-1} A_k (A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1}^{-1})^{-1} \Sigma_{k-1}^{-1} \mu_{k-1} + B_k u_k\\
&= (R_k R_k^{-1} A_k + A_k \Sigma_{k-1} A_k^{\top} R_k^{-1} A_k) (A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1}^{-1})^{-1} \Sigma_{k-1}^{-1} \mu_{k-1} + B_k u_k\\
&= (A_k + A_k \Sigma_{k-1} A_k^{\top} R_k^{-1} A_k) (A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1}^{-1})^{-1} \Sigma_{k-1}^{-1} \mu_{k-1} + B_k u_k\\
&= A_k (I + \Sigma_{k-1} A_k^{\top} R_k^{-1} A_k) (A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1}^{-1})^{-1} \Sigma_{k-1}^{-1} \mu_{k-1} + B_k u_k\\
&= A_k (I + \Sigma_{k-1} A_k^{\top} R_k^{-1} A_k) (\Sigma_{k-1} A_k^{\top} R_k^{-1} A_k + \Sigma_{k-1} \Sigma_{k-1}^{-1})^{-1} \mu_{k-1} + B_k u_k\\
&= A_k (I + \Sigma_{k-1} A_k^{\top} R_k^{-1} A_k) (\Sigma_{k-1} A_k^{\top} R_k^{-1} A_k + I)^{-1} \mu_{k-1} + B_k u_k\\
&= A_k \mu_{k-1} + B_k u_k\\
\therefore M_1 &= A_k \mu_{k-1} + B_k u_k\\
\end{aligned}
$$
が得られる。
また、2階偏微分を計算すると、
$$
\begin{aligned}
S_1 &= \frac{1}{2} \left( \frac{\partial}{\partial x_k} \right)^2 L_1(x_k) \\
&= (R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1}
\end{aligned}
$$
となる。
これらを代入することで、$L_1(x_k)$の具体的な形が以下のように求まる。
$$
L_1(x_k) = [x_k - (A_k \mu_{k-1} + B_k u_k)]^{\top} (R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1} [x_k - (A_k \mu_{k-1} + B_k u_k)] \\
$$

以上のようにして得られた$L_1(x_k)$と$L_2(x_k, x_{k-1})$とを、予測ステップの確率分布に戻していく。
$$
\begin{aligned}
p(x_k| y_{0:k-1})
&= \eta \int \exp \left(-\frac{1}{2} L \right) \mathrm{d}x_{k-1} \\
&= \eta \int \exp \left(-\frac{1}{2} [L_1(x_k) + L_2(x_k, x_{k-1})] \right) \mathrm{d}x_{k-1} \\
&= \eta \exp \left[-\frac{1}{2} L_1(x_k) \right] \int \exp \left[-\frac{1}{2} L_2(x_k, x_{k-1}) \right] \mathrm{d}x_{k-1}
\end{aligned}
$$
ここで、$\int \exp \left[-\frac{1}{2} L_2(x_k, x_{k-1}) \right] \mathrm{d}x_{k-1}$はガウス積分の形になっており、その積分値は定数になる。
よって、積分の部分は定数係数にまとめることができて、以下のように表せるようになる。
$$
\begin{aligned}
p(x_k| y_{0:k-1})
&\propto \exp \left[-\frac{1}{2} L_1(x_k) \right] \\
&\propto \exp \left\{-\frac{1}{2} [x_k - (A_k \mu_{k-1} + B_k u_k)]^{\top} (R_k + A_k \Sigma_{k-1} A_k^{\top})^{-1} [x_k - (A_k \mu_{k-1} + B_k u_k)] \right\} \\
\end{aligned}
$$
指数部分が正規分布の形式になっていることがわかる。
確率分布は全区間で積分した結果が1になることから、定数係数は一意に復元できるので、結局$p(x_k| y_{0:k-1})$は以下のような正規分布になる。
$$
p(x_k| y_{0:k-1}) = \mathcal{N}(x_k; A_k \mu_{k-1} + B_k u_k, R_k + A_k \Sigma_{k-1} A_k^{\top})
$$
この平均と分散は、カルマンフィルタの予測ステップで求められる平均と分散に等しい。
こうして、予測ステップの手続きが導出できた。

## 更新ステップの導出

続いて、更新ステップを考える。
予測ステップで得た確率分布の平均と分散とを
$$
\begin{aligned}
p(x_k| y_{0:k-1}) &= \mathcal{N}(x_k; A_k \mu_{k-1} + B_k u_k, R_k + A_k \Sigma_{k-1} A_k^{\top})\\
&\triangleq \mathcal{N}(x_k; \bar{\mu}_{k}, \bar{\Sigma}_{k})
\end{aligned}
$$
のようにおくと、観測値$y_k$が得られた後の確率分布$p(x_k| y_{0:k})$は以下のようになる。
$$
\begin{aligned}
p(x_k| y_{0:k}) &= \frac{p(y_k| x_k) p(x_k| y_{0:k-1})}{\int p(y_k| x_k) p(x_k| y_{0:k-1}) \mathrm{d}x_k}\\
&= \frac{\mathcal{N}(y_k; C_k x_k, Q_k) \mathcal{N}(x_k; \bar{\mu}_{k}, \bar{\Sigma}_{k})}{\int p(y_k| x_k) p(x_k| y_{0:k-1}) \mathrm{d}x_k}\\
&= \frac{\det(2\pi Q_k)^{-\frac{1}{2}} \det(2\pi\bar{\Sigma}_k)^{-\frac{1}{2}}}{\int p(y_k| x_k) p(x_k| y_{0:k-1}) \mathrm{d}x_k} \exp\left[-\frac{1}{2}(y_k - C_k x_k)^{\top} Q_k^{-1} (y_k - C_k x_k) \right] \exp\left[-\frac{1}{2}(x_k - \bar{\mu}_k)^{\top} \bar{\Sigma}_k^{-1} (x_k - \bar{\mu}_k) \right]\\
&= \frac{\det(2\pi Q_k)^{-\frac{1}{2}} \det(2\pi\bar{\Sigma}_k)^{-\frac{1}{2}}}{\int p(y_k| x_k) p(x_k| y_{0:k-1}) \mathrm{d}x_k} \exp\left\{-\frac{1}{2}\left[(y_k - C_k x_k)^{\top} Q_k^{-1} (y_k - C_k x_k) + (x_k - \bar{\mu}_k)^{\top} \bar{\Sigma}_k^{-1} (x_k - \bar{\mu}_k) \right]\right\}\\
&= \zeta \exp\left( -\frac{1}{2} J \right)
\end{aligned}
$$
ここで、定数部分を$\zeta$に、指数部分を$J$にまとめた（積分項は$x_k$を含まないので定数項にまとめられる）。

予測ステップのときと同様に、定数項$\zeta$は確率分布の正規性から一意に定まるので無視してもいい。
なので、ここからは$J$を変形していく。

ここで、以下のように、$J$が$x_k$の二次式になるとする。
$$
J = (x_k - M)^{\top} S (x_k - M)
$$
ただし、$S$は正定値対称行列とする。
$M$と$S$は、予測ステップのときと同様に、$J$の2階までの偏微分から求めることができる。

まずは、$M$について。
$M$は、
$$
M = x_k \Leftrightarrow \frac{\partial}{\partial x_k} J = 0
$$
であることを使って求められる。
$$
\begin{aligned}
\frac{\partial}{\partial x_k} J &= \frac{\partial}{\partial x_k} \left[(y_k - C_k x_k)^{\top} Q_k^{-1} (y_k - C_k x_k) + (x_k - \bar{\mu}_k)^{\top} \bar{\Sigma}_k^{-1} (x_k - \bar{\mu}_k)\right]\\
&= -2 C_k^{\top} Q_k^{-1} (y_k - C_k x_k) + 2 \bar{\Sigma}_k^{-1} (x_k - \bar{\mu}_k)
\end{aligned}
$$
より、$\frac{\partial}{\partial x_k} J = 0$とすると、
$$
\begin{aligned}
-2 C_k^{\top} Q_k^{-1} (y_k - C_k x_k) + 2 \bar{\Sigma}_k^{-1} (x_k - \bar{\mu}_k) &= 0\\
\bar{\Sigma}_k^{-1} (x_k - \bar{\mu}_k) &= C_k^{\top} Q_k^{-1} (y_k - C_k x_k)\\
\bar{\Sigma}_k^{-1} x_k - \bar{\Sigma}_k^{-1} \bar{\mu}_k &= C_k^{\top} Q_k^{-1} y_k - C_k^{\top} Q_k^{-1} C_k x_k\\
\bar{\Sigma}_k^{-1} x_k + C_k^{\top} Q_k^{-1} C_k x_k &= C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k\\
(\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k) x_k &= C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k\\
x_k &= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k)
\end{aligned}
$$
となる。
よって、
$$
M = (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k)
$$

続いて、$S$について。
$$
\begin{aligned}
S &= \frac{1}{2} \left( \frac{\partial}{\partial x_k} \right)^2 J\\
&= \bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k
\end{aligned}
$$

これを元の式に代入すると、
$$
\begin{aligned}
p(x_k| y_{0:k}) &= \zeta \exp\left( -\frac{1}{2} J \right)\\
&= \zeta \exp \left[ -\frac{1}{2} (x_k - M)^{\top} S (x_k - M) \right]\\
&= \zeta \exp \left\{ -\frac{1}{2} [x_k - (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k)]^{\top} (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k) [x_k - (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k)] \right\}
\end{aligned}
$$
となる。
この式は正規分布の形なので、最終的に、$p(x_k| y_{0:k})$は以下のような正規分布になる。
$$
p(x_k| y_{0:k}) = \mathcal{N}(x_k; (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k), (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1})
$$

更新ステップの手続き自体は以上で求まった。
しかし、確率分布の平均と分散はまだカルマンフィルタのものと似つかない。
以降は、カルマンフィルタの導出に向けて式変形していく。

上で求まった正規分布の平均と分散をそれぞれ以下のようにおく。
$$
\begin{aligned}
\mu_k &= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k)\\
\Sigma_k &= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1}\\
\end{aligned}
$$

まずは、平均$\mu_k$を変形していく。
$$
\begin{aligned}
\mu_k &= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k)\\
&= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k + \bar{\Sigma}_k^{-1} \bar{\mu}_k + C_k^{\top} Q_k^{-1} C_k \bar{\mu}_k - C_k^{\top} Q_k^{-1} C_k \bar{\mu}_k)\\
&= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} [C_k^{\top} Q_k^{-1} y_k + (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k) \bar{\mu}_k - C_k^{\top} Q_k^{-1} C_k \bar{\mu}_k]\\
&= \bar{\mu}_k + (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} y_k - C_k^{\top} Q_k^{-1} C_k \bar{\mu}_k)\\
&= \bar{\mu}_k + (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} C_k^{\top} Q_k^{-1} (y_k - C_k \bar{\mu}_k)\\
\end{aligned}
$$

さらに、$(\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} C_k^{\top} Q_k^{-1}$の部分を抜き出して変形すると、
$$
\begin{aligned}
&(\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} C_k^{\top} Q_k^{-1}\\
=& (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} C_k^{\top} Q_k^{-1} (C_k \bar{\Sigma}_k C_k^{\top} + Q_k) (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}\\
=& (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} C_k \bar{\Sigma}_k C_k^{\top} + C_k^{\top} Q_k^{-1} Q_k) (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}\\
=& (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} C_k \bar{\Sigma}_k C_k^{\top} + C_k^{\top}) (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}\\
=& (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} C_k \bar{\Sigma}_k C_k^{\top} + \bar{\Sigma}_k^{-1} \bar{\Sigma}_k C_k^{\top}) (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}\\
=& (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1} (C_k^{\top} Q_k^{-1} C_k + \bar{\Sigma}_k^{-1}) \bar{\Sigma}_k C_k^{\top} (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}\\
=& \bar{\Sigma}_k C_k^{\top} (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1}\\
\end{aligned}
$$
となる。よって、$\mu_k$は以下のように表せる。
$$
\mu_k = \bar{\mu}_k + \bar{\Sigma}_k C_k^{\top} (C_k \bar{\Sigma}_k C_k^{\top} + Q_k)^{-1} (y_k - C_k \bar{\mu}_k)
$$

続いて、$\Sigma_k$について考える。
予測ステップの導出で使った逆行列の補助定理を使うと、$\Sigma_k$は以下のように変形できる。
$$
\begin{aligned}
\Sigma_k &= (\bar{\Sigma}_k^{-1} + C_k^{\top} Q_k^{-1} C_k)^{-1}\\
&= \bar{\Sigma}_k - \bar{\Sigma}_k C_k^{\top} (Q_k + C_k \bar{\Sigma}_k C_k^{\top})^{-1} C_k \bar{\Sigma}_k\\
&= [I - \bar{\Sigma}_k C_k^{\top} (Q_k + C_k \bar{\Sigma}_k C_k^{\top})^{-1} C_k] \bar{\Sigma}_k
\end{aligned}
$$

以上のようにして得られた$\mu_k$と$\Sigma_k$とを見比べると、共通して$\bar{\Sigma}_k C_k^{\top} (Q_k + C_k \bar{\Sigma}_k C_k^{\top})^{-1}$を含むことがわかる。
これを$K_k$とおくことで、更新ステップの確率分布$p(x_k| y_{0:k})$は以下のように表せる。
$$
p(x_k| y_{0:k}) = \mathcal{N}(x_k; \bar{\mu}_k + K_k (y_k - C_k \bar{\mu}_k),  (I - K_k C_k) \bar{\Sigma}_k)
$$
$$
K_k \triangleq \bar{\Sigma}_k C_k^{\top} (Q_k + C_k \bar{\Sigma}_k C_k^{\top})^{-1}
$$
これらの式は、カルマンフィルタの更新ステップの手続きそのものである。

# まとめ

もうちょっとわかりやすくなるようにしたいので直すかも。

# 参考文献

1. S. Thrun, W. Burgard, and D. Fox, "Probabilistic Robotics," MIT Press, 2005.
