---
title: 加速度制御とバイラテラル制御
---

# 概要

- 加速度制御に基づくバイラテラル制御の設計は、モード空間における制御インピーダンスの設計として考えることができる。
- 位置、速度、力の応答値から加速度指令値を算出して加速度制御することは、制御対象がフィードバックゲインによって定まる機械インピーダンスをもつようにインピーダンス制御しているものとみなすことができる。
- 加速度制御された2つの制御対象の和のモードと差のモードについて、それぞれ所望の機械インピーダンスを設定して、それに対応するフィードバック系を設計することで、理想的なバイラテラル制御が実現できる。

# 加速度制御に基づくインピーダンス制御

物理学における運動という単語は、[wikipediaの記事](https://ja.wikipedia.org/wiki/%E9%81%8B%E5%8B%95_(%E7%89%A9%E7%90%86%E5%AD%A6))曰く、「物体と参照系の位置関係が変化すること」と説明される。
ニュートン力学において運動は加速度を使って表されることから、制御対象の加速度を思い通りの値にすることで、制御対象の運動を思い通りに制御できることになる。

加速度制御（*Luh et al., 1980; 堀, 1988; Ohnishi et al., 1996*）を利用することで、制御対象の機械的特性を制御することができる。
以下の微分方程式で記述されるバネ－マス－ダンパ系の運動を考える。
$$
m \ddot{x} + d \dot{x} + k x = f
$$
ここで$m$は慣性、$d$は粘性、$k$は弾性であり、0でないスカラーまたは正定値対称行列とする。
この式を整理すると以下のようにできる。
$$
\ddot{x} = - m^{-1} k x -  m^{-1} d \dot{x} + m^{-1} f
$$
この式の右辺にある$x$、$\dot{x}$、$f$に応答値を代入し、算出された左辺の加速度$\ddot{x}$を指令値として加速度制御すると、機械定数が$m$、$d$、$k$である機械系の運動が再現できる。
さらにここで、
$$
\begin{aligned}
K_{\mathrm{p}} &\triangleq m^{-1} k\\
K_{\mathrm{v}} &\triangleq m^{-1} d\\
K_{\mathrm{f}} &\triangleq m^{-1}
\end{aligned}
$$
と定数を定義すれば、制御則は以下のような位置のPD制御＋力のP制御の形になる。
$$
\begin{aligned}
\ddot{x}^{\mathrm{ref}} &= -K_{\mathrm{p}} x -  K_{\mathrm{v}} \dot{x} + K_{\mathrm{f}} f\\
&= -(K_{\mathrm{p}} + K_{\mathrm{v}} s) x + K_{\mathrm{f}} f
\end{aligned}
$$
ただし、微分演算の一部を$s$で表した。
このときの系の機械定数は以下のようになる。
$$
\begin{aligned}
m &= K_{\mathrm{f}}^{-1}\\
d &= K_{\mathrm{f}}^{-1} K_{\mathrm{v}}\\
k &= K_{\mathrm{f}}^{-1} K_{\mathrm{p}}
\end{aligned}
$$

すなわち、**加速度制御系に対して位置と力のフィードバックをすることで、制御系は制御ゲインに対応する機械定数をもつように振る舞う**。
系が所望の機械定数をもつかのように運動を制御することから、この制御則はインピーダンス制御（*Hogan, 1985*）に他ならない。

この方法によるインピーダンス制御系の設計は、制御ゲインによって系の機械定数がほぼ直接指定できるという明快さに利点があると思う。
外乱オブザーバ（*Ohishi et al., 1983*）を使って設計された加速度制御系では、制御対象のモデル化誤差の影響は独立した内部ループで外乱として抑圧され、閉ループ系は規範モデルのとおりに振る舞う。
そのため、外部ループでは制御対象の元々の機械インピーダンスを考慮することなくシンプルに所望の振舞いを設計できる。
この方法は、制御対象の重力や摩擦力、コリオリ力、アクチュエータ間の干渉などを陽に計算して補償する計算トルク法と比べて実装が簡単であり、モデル化誤差に対する頑健性も高い。

## 余談１：平衡点の時間変化がある場合

より一般的に、系の平衡点$x_\mathrm{o}$が時間変化する場合の運動方程式は以下のようになる。
$$
m (\ddot{x} - \ddot{x}_\mathrm{o}) + d (\dot{x} - \dot{x}_\mathrm{o}) + k (x - x_\mathrm{o}) = f
$$
これに対応するフィードバック制御則は、以下のような、加速度フィードフォワード項＋位置のPD制御＋力のP制御の形になる。
$$
\begin{aligned}
\ddot{x}^{\mathrm{ref}} &= \ddot{x}_\mathrm{o} - m^{-1} k (x - x_\mathrm{o}) -  m^{-1} d (\dot{x} - \dot{x}_\mathrm{o}) + m^{-1} f\\
&= \ddot{x}_\mathrm{o} + (K_{\mathrm{p}} + K_{\mathrm{v}} s) (x_\mathrm{o} - x) + K_{\mathrm{f}} f
\end{aligned}
$$
なお、反力の目標値$f_\mathrm{o}$を入れた制御則も考えることができるが、これは次式のとおり、平衡点として$x_\mathrm{o}$の代わりに$x_\mathrm{o}' \triangleq x_\mathrm{o} - \frac{K_{\mathrm{f}}}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} f_\mathrm{o}$を使った形に帰着できる。
すなわち、**反力の目標値$f_\mathrm{o}$を導入しても平衡点$x_{\mathrm{o}}$をずらすことと実質的に等価であり、上述したインピーダンス制御の枠組みを超えることはない**。
$$
\begin{aligned}
\ddot{x}^{\mathrm{ref}} &= \ddot{x}_\mathrm{o} + (K_{\mathrm{p}} + K_{\mathrm{v}} s) (x_\mathrm{o} - x) + K_{\mathrm{f}} (f - f_\mathrm{o})\\
&= \ddot{x}_\mathrm{o} + (K_{\mathrm{p}} + K_{\mathrm{v}} s) (x_\mathrm{o} - x) + K_{\mathrm{f}} f - K_{\mathrm{f}} f_\mathrm{o}\\
&= \ddot{x}_\mathrm{o} + (K_{\mathrm{p}} + K_{\mathrm{v}} s) (x_\mathrm{o} - x) + K_{\mathrm{f}} f - \frac{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} K_{\mathrm{f}} f_\mathrm{o}\\
&= \ddot{x}_\mathrm{o} + (K_{\mathrm{p}} + K_{\mathrm{v}} s) (x_\mathrm{o} - x) + K_{\mathrm{f}} f - s^2\frac{K_{\mathrm{f}}}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} f_\mathrm{o} - (K_{\mathrm{p}} + K_{\mathrm{v}} s) \frac{K_{\mathrm{f}}}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} f_\mathrm{o}\\
&= s^2 \left( x_\mathrm{o} - \frac{K_{\mathrm{f}}}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} f_\mathrm{o} \right) + (K_{\mathrm{p}} + K_{\mathrm{v}} s) \left[ \left( x_\mathrm{o} - \frac{K_{\mathrm{f}}}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} f_\mathrm{o} \right) - x \right] + K_{\mathrm{f}} f\\
&= \ddot{x}_\mathrm{o}' + (K_{\mathrm{p}} + K_{\mathrm{v}} s) (x_\mathrm{o}' - x) + K_{\mathrm{f}} f
\end{aligned}
$$
$$
x_\mathrm{o}' \triangleq x_\mathrm{o} - \frac{K_{\mathrm{f}}}{K_{\mathrm{p}} + K_{\mathrm{v}} s + s^2} f_\mathrm{o} = x_\mathrm{o} - \frac{1}{m s^2 + d s + k} f_\mathrm{o}
$$

## 余談２：制御系の特性

バネ－マス－ダンパ系の位置から力までの伝達関数$G$を変形すると、以下のようになる。
$$
\begin{aligned}
G &\triangleq m s^2 + d s + k\\
&= (m^{-1} k k^{-1})^{-1} \left[ s^2 + \sqrt{m^{-1}} \sqrt{k} \left( \sqrt{m} \sqrt{k} \right)^{-1} d s + m^{-1} k \right]\\
&= (\Omega_{\mathrm{n}} K)^{-1} \left[ s^2 + 2 \omega_{\mathrm{n}} \zeta s + \Omega_{\mathrm{n}} \right]
\end{aligned}
$$
各定数の定義は以下のとおり。
$$
\begin{aligned}
K &\triangleq k^{-1}\\
\Omega_{\mathrm{n}} &\triangleq m^{-1} k\\
\omega_{\mathrm{n}} &\triangleq \sqrt{m^{-1}} \sqrt{k}\\
\zeta &\triangleq \frac{1}{2} \left( \sqrt{m} \sqrt{k} \right)^{-1} d
\end{aligned}
$$
ただし、$m$と$k$とはどちらもスカラーもしくは正定値対称行列とし、平方根記号$\sqrt{}$はスカラーの平方根もしくは行列の主平方根行列を表す。
このとき各定数は制御ゲインを使って以下のように表せる。
$$
\begin{aligned}
K &= K_{\mathrm{p}}^{-1} K_{\mathrm{f}}\\
\Omega_{\mathrm{n}} &= K_{\mathrm{p}}\\
\omega_{\mathrm{n}} &= \sqrt{K_{\mathrm{f}}} \sqrt{K_{\mathrm{f}}^{-1} K_{\mathrm{p}}}\\
\zeta &= \frac{1}{2} \left[ \sqrt{K_{\mathrm{f}}^{-1}} \sqrt{K_{\mathrm{f}}^{-1} K_{\mathrm{p}}} \right]^{-1} K_{\mathrm{f}}^{-1} K_{\mathrm{v}}
\end{aligned}
$$

特に、$m$と$k$との固有ベクトルがすべて一致する（あるいはどちらもスカラーである）ときは、$m^{-1} k$も正定値対称行列になることから、
$$
\Omega_{\mathrm{n}} \triangleq m^{-1} k = \left( \sqrt{m^{-1}} \sqrt{k} \right)^2 = \omega_{\mathrm{n}}^2
$$
となり、制御ゲインとの関係も以下のように表せる。
$$
\begin{aligned}
K &= K_{\mathrm{p}}^{-1} K_{\mathrm{f}}\\
\omega_{\mathrm{n}} &= \sqrt{K_{\mathrm{p}}}\\
\zeta &= \frac{1}{2} \sqrt{K_{\mathrm{p}}^{-1}} K_{\mathrm{d}}
\end{aligned}
$$
制御系の自然角周波数$\omega_{\mathrm{n}}$と減衰定数$\zeta$が位置制御のフィードバックゲインによって決定されることがわかる。

# モード空間でのバイラテラル制御系の設計

バイラテラル制御は、2つの制御対象（リーダーとフォロワー）を制御的に結合し、その結合系の運動を制御することで遠隔操作を実現する技術である。
バイラテラル制御の制御系は、操作者や環境から見たリーダーとフォロワーとの機械的振舞いを制御することから、インピーダンス制御として設計するのが直感的である。

このとき、リーダーとフォロワーのそれぞれの運動を個別に扱うよりも、結合系の機能的単位ごとに制御器を設計するほうが直感的である（機能性に基づく制御系設計（*Tsuji et al., 2006; Tsuji et al., 2007*））。
バイラテラル制御においては、リーダー・フォロワーの相対位置を一定にしつつ、操作者や環境から見た重心系の運動が軽いことが好ましい。
相対運動は両者の位置の差で表され、重心運動は両者の位置の和で表される。
よって、リーダーとフォロワーそれぞれの座標で記述される座標系の代わりに、それらの差（相対運動）と和（重心運動）との座標で記述されるモード座標系で制御系を扱うほうがわかりやすい。
各モードの運動が所望のものになるようにそれぞれ制御インピーダンスを設計することで、加速度制御を通じて理想的なバイラテラル制御が実現できる。

## 座標変換

リーダーとフォロワーの位置をそれぞれ$x_{\mathrm{L}}$、$x_{\mathrm{F}}$とおく。
また、差のモードの位置を$x_{\mathrm{d}}$、和のモードの位置を$x_{\mathrm{s}}$とおく。
その他の変数についても同様の命名規則で添え字をつける。

リーダー・フォロワーの座標系からモード座標系への変換を次式のように定義する。
$$
\begin{aligned}
x_{\mathrm{d}} &\triangleq x_{\mathrm{L}} - x_{\mathrm{F}}\\
x_{\mathrm{s}} &\triangleq \frac{1}{2} (x_{\mathrm{L}} + x_{\mathrm{F}})
\end{aligned}
$$
$x_{\mathrm{d}}$はフォロワーからみたリーダーの相対位置を表し、$x_{\mathrm{s}}$はリーダーとフォロワーの幾何中心の位置を表す。
ここではリーダーとフォロワーのノミナル慣性が同じであると仮定し、幾何中心が重心と一致するものとして扱う。
この逆変換は以下のようになる。
$$
\begin{aligned}
x_{\mathrm{L}} &= x_{\mathrm{s}} + \frac{1}{2} x_{\mathrm{d}}\\
x_{\mathrm{F}} &= x_{\mathrm{s}} - \frac{1}{2} x_{\mathrm{d}}
\end{aligned}
$$

また、座標変換に対して仕事$W$が不変であることから、モード座標に対応する力（$f_{\mathrm{d}}$と$f_{\mathrm{s}}$）について以下の関係が成り立つ。
$$
\begin{aligned}
W &\triangleq x_{\mathrm{L}}^{\top} f_{\mathrm{L}} + x_{\mathrm{F}}^{\top} f_{\mathrm{F}}\\
&= \left( x_{\mathrm{s}} + \frac{1}{2} x_{\mathrm{d}} \right)^{\top} f_{\mathrm{L}} + \left( x_{\mathrm{s}} - \frac{1}{2} x_{\mathrm{d}} \right)^{\top} f_{\mathrm{F}}\\
&= x_{\mathrm{d}}^{\top} \left( \frac{1}{2} f_{\mathrm{L}} - \frac{1}{2} f_{\mathrm{F}} \right) + x_{\mathrm{s}}^{\top} \left( f_{\mathrm{L}} + f_{\mathrm{F}} \right)\\
&\equiv x_{\mathrm{d}}^{\top} f_{\mathrm{d}} + x_{\mathrm{s}}^{\top} f_{\mathrm{s}}
\end{aligned}
$$
よって、力の座標変換は以下のように表される。
$$
\begin{aligned}
f_{\mathrm{d}} &= \frac{1}{2} (f_{\mathrm{L}} - f_{\mathrm{F}})\\
f_{\mathrm{s}} &= f_{\mathrm{L}} + f_{\mathrm{F}}
\end{aligned}
$$

## 差のモードの運動制御

まずは、差のモードの運動方程式を考える。
$$
m_{\mathrm{d}} \ddot{x}_{\mathrm{d}} + d_{\mathrm{d}} \dot{x}_{\mathrm{d}} + k_{\mathrm{d}} x_{\mathrm{d}} = f_{\mathrm{d}}
$$
リーダーとフォロワーの相対位置は常に一定であってほしいので、差のモードでは運動が完全に静止していることが望ましい。
初期位置と初期速度がどちらもゼロの場合、これは仮想慣性を無限大にするだけで実現できる。
$$
\ddot{x}_{\mathrm{d}} = - m_{\mathrm{d}}^{-1} k_{\mathrm{d}} x_{\mathrm{d}} - m_{\mathrm{d}}^{-1} d_{\mathrm{d}} \dot{x}_{\mathrm{d}} + m_{\mathrm{d}}^{-1} f_{\mathrm{d}} \rightarrow 0
$$
すなわち、差のモードの加速度指令値を単純にゼロにすれば、リーダーとフォロワーとの相対位置の加速度がゼロになるので、理想的には完全な同期が実現できる。

しかし、初期位置と初期速度はゼロとは限らず、加えて現実の加速度制御では高周波帯域の外乱を完全には抑圧できないので、加速度指令値をゼロにするだけだと位置や速度のドリフトが生じるおそれがある。
よって、仮想弾性と仮想粘性も無限大に近づけて剛体の運動を再現する必要がある。

$k$、$d$、$m$を無限大にしていくとき、各定数の関係が以下のとおりになるようにする。
$$
\begin{aligned}
  m_{\mathrm{d}}^{-1} &\rightarrow 0 \\
  m_{\mathrm{d}}^{-1} k_{\mathrm{d}} &\rightarrow K_{\mathrm{p}} \\
  m_{\mathrm{d}}^{-1} d_{\mathrm{d}} &\rightarrow K_{\mathrm{v}}
\end{aligned}
$$
すると、加速度指令値は位置のPD制御の形で計算されるようになる。
$$
\begin{aligned}
  \ddot{x}_{\mathrm{d}}^{\mathrm{ref}} &= - m_{\mathrm{d}}^{-1} k_{\mathrm{d}} x_{\mathrm{d}} - m_{\mathrm{d}}^{-1} d_{\mathrm{d}} \dot{x}_{\mathrm{d}} + m_{\mathrm{d}}^{-1} f_{\mathrm{d}} \\
  &\rightarrow  - K_{\mathrm{p}} x_{\mathrm{d}} - K_{\mathrm{v}} \dot{x}_{\mathrm{d}}
\end{aligned}
$$

## 和のモードの運動制御

和のモードについても運動方程式を考える。
$$
m_{\mathrm{s}} \ddot{x}_{\mathrm{s}} + d_{\mathrm{s}} \dot{x}_{\mathrm{s}} + k_{\mathrm{s}} x_{\mathrm{s}} = f_{\mathrm{s}}
$$
和のモードの運動は、リーダーとフォロワーとの幾何中心（両者の慣性が同じなら重心でもある）の運動とみなせる。
和のモードの運動に弾性と粘性がまったくなく、慣性が十分に小さいとき、操作者はリーダとフォロワーが存在しないかのように感じられる。
これを理想的な挙動として、仮想質量の逆数を以下のように置き換える。
$$
\begin{aligned}
  m_{\mathrm{s}}^{-1} &\rightarrow K_{\mathrm{f}} \\
  k_{\mathrm{d}} &\rightarrow 0 \\
  d_{\mathrm{d}} &\rightarrow 0
\end{aligned}
$$
すると、加速度指令値は力の比例制御の形で計算されるようになる。
$$
\begin{aligned}
  \ddot{x}_{\mathrm{s}}^{\mathrm{ref}} &= - m_{\mathrm{s}}^{-1} k_{\mathrm{s}} x_{\mathrm{s}} - m_{\mathrm{s}}^{-1} d_{\mathrm{s}} \dot{x}_{\mathrm{s}} + m_{\mathrm{s}}^{-1} f_{\mathrm{s}} \\
  &\rightarrow K_{\mathrm{f}} f_{\mathrm{s}}
\end{aligned}
$$
ここで、力のフィードバックゲイン$K_{\mathrm{f}}$は仮想慣性の逆数なので、値を大きくするほど重心系は軽い運動をする。
特に$K_{\mathrm{f}} \rightarrow \infty$のとき、操作者はリーダーとフォロワーとを介して環境と接触しているにもかかわらず、リーダー・フォロワーが存在しないかのように環境からの反力を感じることができる。

もうひとつの例として、和のモードでの仮想慣性が重心系のノミナル慣性と一致する場合を考える。
リーダーとフォロワーの元々の慣性を$m_{\mathrm{n}}$とおくと、重心系の元の慣性は$2 m_{\mathrm{n}}$となる。
よって、$K_{\mathrm{f}} = \frac{1}{2} m_{\mathrm{n}}^{-1}$と設定すると、和のモードの仮想慣性は元の重心系の慣性と同一になる。

## 元の座標系での記述

差のモードと和のモードでそれぞれ設計された制御系を元の座標系に変換すると、以下のようになる。
$$
\begin{aligned}
  \ddot{x}_{\mathrm{L}}^{\mathrm{ref}} &= \frac{1}{2} \ddot{x}_{\mathrm{d}} + \ddot{x}_{\mathrm{s}} \\
  &= - \frac{1}{2} K_{\mathrm{p}} x_{\mathrm{d}} - \frac{1}{2} K_{\mathrm{v}} \dot{x}_{\mathrm{d}} + K_{\mathrm{f}} f_{\mathrm{s}} \\
  &= \frac{1}{2} K_{\mathrm{p}} (x_{\mathrm{F}} - x_{\mathrm{L}}) + \frac{1}{2} K_{\mathrm{v}} (\dot{x}_{\mathrm{F}} - \dot{x}_{\mathrm{L}}) + K_{\mathrm{f}} (f_{\mathrm{L}} + f_{\mathrm{F}})
\end{aligned}
$$
$$
\begin{aligned}
  \ddot{x}_{\mathrm{F}}^{\mathrm{ref}} &= -\frac{1}{2} \ddot{x}_{\mathrm{d}} + \ddot{x}_{\mathrm{s}} \\
  &= \frac{1}{2} K_{\mathrm{p}} x_{\mathrm{d}} + \frac{1}{2} K_{\mathrm{v}} \dot{x}_{\mathrm{d}} + K_{\mathrm{f}} f_{\mathrm{s}} \\
  &= \frac{1}{2} K_{\mathrm{p}} (x_{\mathrm{L}} - x_{\mathrm{F}}) + \frac{1}{2} K_{\mathrm{v}} (\dot{x}_{\mathrm{L}} - \dot{x}_{\mathrm{F}}) + K_{\mathrm{f}} (f_{\mathrm{L}} + f_{\mathrm{F}})
\end{aligned}
$$

# 参考文献

1. J. Luh, M. Walker, and R. Paul, "Resolved-acceleration control of mechanical manipulators," IEEE Transactions on Automatic Control, vol. 25, no. 3, pp. 468--474, 1980.
1. 堀 洋一, "加速度制御形サーボ系," 電気学会論文誌Ｄ（産業応用部門誌）, vol. 108, no. 7, pp. 672--677, 1988.
1. K. Ohnishi, M. Shibata, and T. Murakami, "Motion Control for Advanced Mechatronics," IEEE/ASME Transactions on Mechatronics, vol. 1, no. 1, pp. 56-67, 1996.
1. N. Hogan, "Impedance Control: An Approach to Manipulation: Part I—Theory," Journal of Dynamic Systems, Measurement, and Control, vol. 107, no. 1, pp. 1--7, 1985.
1. K. Ohishi, K. Ohnishi, and K. Miyachi, "Torque-Speed Regulation of DC Motor Based on Load Torque Estimation Method," in Proceedings of the IEEJ International Power Electronics Conference, 1983, vol. 2, pp. 1209--1218.
1. T. Tsuji, K. Natori, H. Nishi, and K. Ohnishi, "A Controller Design Method of Bilateral Control System," EPE Journal, vol. 16, no. 2, pp. 22--27, 2006.
1. T. Tsuji, K. Ohnishi, and A. Sabanovic, "A Controller Design Method Based on Functionality," IEEE Transactions on Industrial Electronics, vol. 54, no. 6, pp. 3335--3343, 2007.
