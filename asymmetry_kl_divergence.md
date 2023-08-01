---
title: KL情報量の非対称性
---

# 概要

- KL情報量は2つの確率分布の違いを測る指標だが、対称性をもたないので、確率分布の最適化において$D_{\mathrm{KL}}(p \parallel q)$を使うか$D_{\mathrm{KL}}(q \parallel p)$を使うかで解が異なることがある。それぞれの解は、$\lim_{x \rightarrow 0}(-\log x) = \infty$であることに起因して異なる傾向を示す。
- $\operatorname{arg min}_q D_{\mathrm{KL}}(p \parallel q)$の解は、$p$を取りこぼしなく覆うような確率分布となる（包括的な分布）。
	- $q$が正規分布のときは、できるだけすべての峰（モード）を覆うような大きな分散の正規分布になる。
- $\operatorname{arg min}_q D_{\mathrm{KL}}(q \parallel p)$の解は、$p$の低い領域を避けるような確率分布となる（排他的な分布）。
	- $q$が正規分布のときは、ひとつの峰（モード）を狙って捉えるような比較的小さな分散の正規分布になる。

# 背景

2つの連続値確率分布$p$と$q$を考える。
これらの間のKullback-Leibler（KL）情報量は、以下のように定義される。
$$
D_{\mathrm{KL}}(p \parallel q) \triangleq \int_{-\infty}^{\infty} p(x) \log \frac{p(x)}{q(x)} \mathrm{d}x
$$

確率的推論では、KL情報量の最小化がよく現れる。
例えば変分推論では、事後確率分布が解析的に求まらないときに、代わりにそれとのKL情報量が最小となる近似確率分布を求めようとする。
また、最尤推定も、サンプルサイズが無限大のときはKL情報量の最小化問題と等価になる。

KL情報量は対称性がない。
すなわち、一般に
$$
D_{\mathrm{KL}}(q \parallel p) \neq D_{\mathrm{KL}}(p \parallel q)
$$
である。
そのため、KL情報量を最小化する問題も、以下のように引数の位置によって解が異なることがある。
$$
\underset{q}{\operatorname{arg min}} D_{\mathrm{KL}}(p \parallel q) \neq \underset{q}{\operatorname{arg min}} D_{\mathrm{KL}}(q \parallel p)
$$

それぞれの最小化問題で得られる解の特徴は、主に$f(x) = 0 \Rightarrow -\log f(x) = \infty$となることに起因して、以下のような傾向をもつと言える。

# $\operatorname{arg min}_q D_{\mathrm{KL}}(p \parallel q)$について

$D_{\mathrm{KL}}(p \parallel q)$は以下のように変形できる。
$$
\begin{aligned}
D_{\mathrm{KL}}(p \parallel q) &= \int_{-\infty}^{\infty} p(x) \log \frac{p(x)}{q(x)} \mathrm{d}x\\
&= \int_{-\infty}^{\infty} p(x) \log p(x) \mathrm{d}x - \int_{-\infty}^{\infty} p(x) \log q(x) \mathrm{d}x\\
&= \mathbb{E}_{x \sim p(x)}[\log p(x)] - \mathbb{E}_{x \sim p(x)}[\log q(x)]
\end{aligned}
$$
このとき、第1項は$q$と関係なく決まるので、$q$の最小化問題においては定数とみなせる。
よって、KL情報量の最小化問題の解は、以下の最小化問題の解と同じである。
$$
\underset{q}{\operatorname{arg min}} \mathbb{E}_{x \sim p(x)}[ -\log q(x)]
$$

上記の最小化問題においては、$p(x) > 0$である$x$において$q(x) = 0$だと、$-\log q(x) = \infty$となって評価値が無限大に発散してしまう。
そのため、$p(x) > 0$となる領域では$q(x) > 0$となるように方向づけられる。
一方で、$p(x)$が低いところで$q(x)$が高い値をとる分には、評価値への直接の影響はない。

上記のことから、最小化問題の解は **$p$を取りこぼしなく覆うような確率分布**となる。
$p(x)$が小さいところを取り込むのは問題ないが、$p(x)$が大きいところを取りこぼすとKL情報量が極端に大きくなってしまう。
そのため、$p(x)$がゼロより大きいところで$q(x)$もゼロより大きくなることが優先される。

$p$が混合正規分布のような多峰性をもつ確率分布で、$q$が正規分布であるとき、$\operatorname{arg min}_q D_{\mathrm{KL}}(p \parallel q)$の解は、できるだけすべての峰を覆うような大きな分散の正規分布になる。

# $\operatorname{arg min}_q D_{\mathrm{KL}}(q \parallel p)$について

$D_{\mathrm{KL}}(q \parallel p)$は以下のように変形できる。
$$
D_{\mathrm{KL}}(q \parallel p) = \mathbb{E}_{x \sim q(x)}[\log q(x)] + \mathbb{E}_{x \sim q(x)}[-\log p(x)]
$$
すなわち、KL情報量の最小化問題は以下のように書き直せる。
$$
\underset{q}{\operatorname{arg min}} \mathbb{E}_{x \sim q(x)}[\log q(x)] + \mathbb{E}_{x \sim q(x)}[-\log p(x)]
$$

上記の最小化問題において、第1項は$q$が裾野の広い分布であるほど値が小さくなる。
第2項は、$p(x)$が大きい値になるところで$q(x)$も大きい値になるほど小さくなる。
その一方で、$p(x) = 0$となる領域で$q(x) > 0$であると、$-\log p(x) = \infty$となって評価値が無限大に発散してしまう。

上記のことから、最小化問題の解は **$p$の低い領域を避けるような確率分布**となる。
$p(x)$が大きくなるところを広く捉えようとする一方で、$p(x)$が小さいところまで覆ってしまうとKL情報量が極端に大きくなってしまう。
そのため、$p(x)$がゼロに近いところで$q(x)$もゼロに近くなることが優先される。

$p$が混合正規分布のような多峰性をもつ確率分布で、$q$が正規分布であるとき、$\operatorname{arg min}_q D_{\mathrm{KL}}(q \parallel p)$の解は、ひとつの峰を狙って捉えるような比較的小さな分散の正規分布になる。
