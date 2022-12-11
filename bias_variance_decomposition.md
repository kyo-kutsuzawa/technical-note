---
title: Bias-Variance分解
---

# 概要

- 回帰モデルの二乗誤差は一般的に，1) 望ましい入出力関係からのずれ（bias），2) データセットによる出力のばらつき（variance），3) 推定不可能なノイズ（noise），の3つの要素の和に分解できる。
- このうちbiasとvarianceは、データセットが有限であることによって生じる。

# Bias-Variance分解

## 背景

入力$\boldsymbol{x}$に対して出力$t$を予測するような問題を考える。
ここで，入出力の変数は以下のように適当な確率分布に従うとする。
$$
(\boldsymbol{x}, t) \sim p(\boldsymbol{x}, t)
$$
$p(\boldsymbol{x}, t)$はふつうわからないので，代わりに有限な大きさのデータセット$\mathcal{D}$をもとに回帰モデル$y(\boldsymbol{x}; \mathcal{D})$を得たとする。
$$
t \approx y(\boldsymbol{x}; \mathcal{D})
$$
そしてこのモデルの性能を以下のような二乗誤差で測る。
$$
L(t, y(\boldsymbol{x}; \mathcal{D})) = \{ y(\boldsymbol{x}; \mathcal{D}) - t \}^2
$$
ここで学習の目標を，未知のデータも含めた二乗誤差の期待値を最小化することとする。
すなわち，以下の式の値の最小化を目標とする。
$$
\begin{aligned}
\mathbb{E}_{(\boldsymbol{x}, t) \sim p(\boldsymbol{x}, t)}[L(t, y(\boldsymbol{x}; \mathcal{D}))] &= \iint L(t, y(\boldsymbol{x}; \mathcal{D})) p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
&= \iint \{ y(\boldsymbol{x}; \mathcal{D}) - t \}^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t \quad \text{(1)}
\end{aligned}
$$
この式がより詳細にどのような要素で構成されるのかを知ることは，回帰モデルの設計などをおこなう上で重要である。
そこで以降では，この期待値の数式を分解していく。

## ノイズ成分の分離

未知のデータが確率的に生成される場合，一般的には予測を正確におこなうことはできない。
よって，まずは二乗誤差の期待値を予測できる要素と予測できない要素に分解していく。
そのために，ある入力$\boldsymbol{x}$に対する出力の期待値を以下のように導入する。
$$
\mathbb{E}_t[t| \boldsymbol{x}] \triangleq \int t p(t| \boldsymbol{x}) \mathrm{d}t
$$
すると，二乗誤差の期待値は以下のように分解できる。
$$
\begin{aligned}
\mathbb{E}_{(\boldsymbol{x}, t) \sim p(\boldsymbol{x}, t)}[L(t, y(\boldsymbol{x}; \mathcal{D}))] &= \iint \{ y(\boldsymbol{x}; \mathcal{D}) - t \}^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
&= \int \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 p(\boldsymbol{x}) \mathrm{d}\boldsymbol{x} + \iint \{ \mathbb{E}_t[t| \boldsymbol{x}] - t \}^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t \quad \text{(2)}
\end{aligned}
$$

上式の分解のうち，モデルを調整して小さくできるのは第1項だけである。
第2項は$y(\boldsymbol{x}; \mathcal{D})$を含まないのでモデルをどう調整しても値を変化させることができない。
つまり第2項は，**推定不可能なノイズによる誤差**に対応する。

## BiasとVarianceの分離

続いて，予測可能な誤差に相当する式(2)第1項について考える。
この項は$y(\boldsymbol{x}; \mathcal{D}) \equiv \mathbb{E}_t[t| \boldsymbol{x}]$のときに値がゼロになる。
よって，モデルの理想的な出力は
$$
y(\boldsymbol{x}; \mathcal{D}) = \mathbb{E}_t[t| \boldsymbol{x}] = \int t p(t| \boldsymbol{x}) \mathrm{d}t
$$
となる（すなわち，このときに二乗誤差が最小となる）。
データが無限にある場合は，モデルは$\mathbb{E}_t[t| \boldsymbol{x}]$を任意の精度で近似できて，完璧な予測が可能である。
しかし実際には**有限のデータセット$\mathcal{D}$しか与えられない**。
このことによって誤差が残ってしまう。

そこで今度は，データセットが有限のときに二乗誤差がどのような要素で構成されるかを考える。
式(2)第1項の積分の中身について，データセットについての期待値をとると以下のようになる。
$$
\mathbb{E}_{\mathcal{D}}[\{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2] = \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 + \mathbb{E}_{\mathcal{D}}[\{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \}^2] \quad \text{(3)}
$$
上式の第1項は望ましい入出力関係$\mathbb{E}_t[t| \boldsymbol{x}]$からのずれ，すなわち**bias**を表す。
一方で第2項はデータセットによる$y(\boldsymbol{x}; \mathcal{D})$の違いの度合い，すなわち**variance**を表す。
varianceはデータセットに対する鋭敏性とも解釈できる。

よって最終的に，二乗誤差の期待値はおおむね以下のように分解できる。
$$
\text{expected loss} = (\text{bias term})^2 + \text{variance term} + \text{noise term}
$$

# 議論

bias-variance分解の導出はおおまかに以下のような流れになる。

1. まず二乗誤差の期待値を定式化する。
2. 期待値の積分の中で$(\mathbb{E}_t[t| \boldsymbol{x}] - \mathbb{E}_t[t| \boldsymbol{x}])$を錬成して展開することで，noise項を単離できる。
3. 残った項について，積分の中で$(\mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})])$を錬成して$\mathcal{D}$についての期待値をとることで，bias項とvariance項とに分解できる。

biasとvarianceは、有限のデータセットからではデータの期待値$\mathbb{E}_t[t| \boldsymbol{x}]$を完璧に予測できないことに起因する。

# 細かい導出

まずは
$$
\begin{aligned}
\mathbb{E}_{(\boldsymbol{x}, t) \sim p(\boldsymbol{x}, t)}[L(t, y(\boldsymbol{x}; \mathcal{D}))] &= \iint \{ y(\boldsymbol{x}; \mathcal{D}) - t \}^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
&= \int \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 p(\boldsymbol{x}) \mathrm{d}\boldsymbol{x} + \iint \{ \mathbb{E}_t[t| \boldsymbol{x}] - t \}^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t
\end{aligned}
$$
について。
おおざっぱには，二乗の項の中で$(-\mathbb{E}_t[t| \boldsymbol{x}] + \mathbb{E}_t[t| \boldsymbol{x}])$を生成して展開することでcross-termが消えて得られる。
詳しく述べる。
1行目右辺の積分の中身は
$$
\begin{aligned}
\{ y(\boldsymbol{x}; \mathcal{D}) - t \}^2
&= \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] + \mathbb{E}_t[t| \boldsymbol{x}] - t \}^2\\
&= \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 + \{ \mathbb{E}_t[t| \boldsymbol{x}] - t \}^2 - 2 \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \} \{ \mathbb{E}_t[t| \boldsymbol{x}] - t \}
\end{aligned}
$$
と分解できる。
このとき上式の第1項を元の積分に入れると
$$
\begin{aligned}
\iint \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t &= \int \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 \int p(\boldsymbol{x}, t) \mathrm{d}t \mathrm{d}\boldsymbol{x}\\
&= \int \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 p(\boldsymbol{x}) \mathrm{d}\boldsymbol{x}
\end{aligned}
$$
となり，第3項を元の積分に入れると
$$
\begin{aligned}
&\iint \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \} \{ \mathbb{E}_t[t| \boldsymbol{x}] - t \} p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
=& \iint \{ -t y(\boldsymbol{x}; \mathcal{D}) - (\mathbb{E}_t[t| \boldsymbol{x}])^2 + y(\boldsymbol{x}; \mathcal{D}) \mathbb{E}_t[t| \boldsymbol{x}] + t \mathbb{E}_t[t| \boldsymbol{x}] \} p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
=& -\iint t y(\boldsymbol{x}; \mathcal{D}) p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t - \iint (\mathbb{E}_t[t| \boldsymbol{x}])^2 p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
&+ \iint y(\boldsymbol{x}; \mathcal{D}) \mathbb{E}_t[t| \boldsymbol{x}] p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t + \iint t \mathbb{E}_t[t| \boldsymbol{x}] p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
=& - \int t p(t| \boldsymbol{x}) \mathrm{d}t \int y(\boldsymbol{x}; \mathcal{D}) p(\boldsymbol{x}) \mathrm{d}\boldsymbol{x} - (\mathbb{E}_t[t| \boldsymbol{x}])^2 \iint p(\boldsymbol{x}, t) \mathrm{d}\boldsymbol{x} \mathrm{d}t\\
&+ \mathbb{E}_t[t| \boldsymbol{x}] \int y(\boldsymbol{x}; \mathcal{D}) p(\boldsymbol{x}) \mathrm{d}\boldsymbol{x} \int p(t| \boldsymbol{x}) \mathrm{d}t + \mathbb{E}_t[t| \boldsymbol{x}] \int p(\boldsymbol{x}) \mathrm{d}\boldsymbol{x} \int t p(t| \boldsymbol{x}) \mathrm{d}t\\
=& - \mathbb{E}_t[t| \boldsymbol{x}] \mathbb{E}_{\boldsymbol{x}} [y(\boldsymbol{x}; \mathcal{D})] - (\mathbb{E}_t[t| \boldsymbol{x}])^2 + \mathbb{E}_t[t| \boldsymbol{x}] \mathbb{E}_{\boldsymbol{x}} [y(\boldsymbol{x}; \mathcal{D})] + \mathbb{E}_t[t| \boldsymbol{x}] \mathbb{E}_t[t| \boldsymbol{x}]\\
=& 0
\end{aligned}
$$
となる。
よって得られた。

続いて
$$
\mathbb{E}_{\mathcal{D}}[\{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2] = \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_t[t| \boldsymbol{x}] \}^2 + \mathbb{E}_{\mathcal{D}}[\{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \}^2]
$$
について。
おおざっぱには，二乗の項の中で$(-\mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] + \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})])$を生成して展開することでcross-termが消えて得られる。
詳しく述べる。
期待値の中身は
$$
\begin{aligned}
&\{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_t[t| \boldsymbol{x}] \}^2\\
=& \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] + \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_t[t| \boldsymbol{x}] \}^2\\
=& \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \}^2 + \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_t[t| \boldsymbol{x}] \}^2\\
&+ 2 \{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \} \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_t[t| \boldsymbol{x}] \}
\end{aligned}
$$
となる。
このうち第3項を元の期待値の式に入れると，
$$
\begin{aligned}
& \mathbb{E}_{\mathcal{D}} [\{ y(\boldsymbol{x}; \mathcal{D}) - \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \} \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \mathbb{E}_t[t| \boldsymbol{x}] \}] \\
=& \mathbb{E}_{\mathcal{D}} [y(\boldsymbol{x}; \mathcal{D}) \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \}^2 - y(\boldsymbol{x}; \mathcal{D}) \mathbb{E}_t[t| \boldsymbol{x}] + \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \mathbb{E}_t[t| \boldsymbol{x}]\\
=& \mathbb{E}_{\mathcal{D}} [y(\boldsymbol{x}; \mathcal{D})] \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] - \{ \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \}^2 - \mathbb{E}_{\mathcal{D}} [y(\boldsymbol{x}; \mathcal{D})] \mathbb{E}_t[t| \boldsymbol{x}] + \mathbb{E}_{\mathcal{D}}[y(\boldsymbol{x}; \mathcal{D})] \mathbb{E}_t[t| \boldsymbol{x}]\\
=& 0
\end{aligned}
$$
となって消える。
よって得られた。
