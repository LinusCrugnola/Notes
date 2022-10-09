# Circuit & Système

Valeur moyenne: $F_m = \frac{1}{T}\int_0^{T} f(t)\ dt$

Valeur efficace: $F = \sqrt{\frac{1}{T}\int_0^{T} f^2(t)\ dt}$

$\int_0^T \sin^2(\omega t) = [\frac{1}{2}t-\frac{T}{8\pi}\sin(\frac{4\pi t}{T})]_0^T = \frac{1}{2}T$

## Complexe

### Capacité
$\underline{Z} = \frac{1}{j\omega C}\frac{1}{j\omega C} = \frac{-j}{\omega C} = X_C$

$\underline{Y} = j\omega C$

### Inductance
$\underline{Z} = j\omega L = X_L$

$\underline{Y} = \frac{1}{j\omega L}$



$j\omega L +\frac{1}{j\omega C} = j(\frac{\omega^2 L C-1}{\omega C})$

Résoudre pour n'avoir qu'un seul $j$

$\underline{Y} = \frac{1}{\underline{Z}}$

Si plusieurs fréquences différentes, on ne peut pas additionner les phaseurs

## Puissance
Toujours prendre la valeur efficace (sinus -> $\frac{\hat{U}}{\sqrt{2}}$)

Puissance efficace: $S\ [VA]$

Puissance active: $P\ [W]$ Toujours positive

Puissance réactive: $Q\ [VAR]$ Attention au signe !!!

### Déphasage
Courant en retard: inductif

Courant en avance: capacitif

## Triphasé
Formulaire page 36

![Triangle étoile](triangle-étoile.JPG)
## Transitoire

$i_c(t) = C\frac{dU}{dt}$

$u_c(t) = U_0 + \frac{1}{C}\int_0^t i_c(\tau) d\tau$

$u_l(t) = L\frac{di}{dt}$

$i_l(t) = i_0+ \frac{1}{L} \int_0^t u(\tau) d\tau$ 

## Quadripole
Matrice de transmission (chaine) : $\begin{bmatrix}
           U_1 \\\\
           I_1
         \end{bmatrix}
    =
\left( \begin{array}{cc}
A & B \\\\
C & D \end{array} \right)
\begin{bmatrix}
           U_2 \\\\
           -I_2
         \end{bmatrix}
 $
![conversion](conversion.JPG)
![simple](chaine%20simple.JPG)

## Diagramme de bode
$G_{dB} = 10\log_{10} \frac{P_2}{P_1} = 10\log_{10} \frac{U_2^2/R_2}{U_1^2/R_1} = 20\log_{10}\frac{U_2}{U_1}- 10\log_{10} \frac{R_2}{R_1}$

Si $R_1 = R_2$ alors 0

### Fonction de transfert

L'origine est en 1 :)

pente positive: $(1+\frac{j\omega}{a})$, $a$ est un zéro

pente négative: $\frac{1}{(1+\frac{j\omega}{a})}$, $a$ est un pôle

zéro de la pente à l'origine : $j\omega$

const: $20\log(C)$

<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
<script type="text/x-mathjax-config">
    MathJax.Hub.Config({ tex2jax: {inlineMath: [['$', '$']]}, messageStyle: "none" });
</script>