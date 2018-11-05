(* mathcomp analysis (c) 2017 Inria and AIST. License: CeCILL-C.              *)
Require Import Reals.
From mathcomp Require Import ssreflect ssrfun ssrbool ssrnat eqtype choice.
From mathcomp Require Import seq fintype bigop ssralg ssrint ssrnum finmap.
From mathcomp Require Import matrix interval zmodp.
Require Import boolp reals Rstruct Rbar.
Require Import classical_sets posnum topology.

(******************************************************************************)
(* This file extends the topological hierarchy with norm-related notions.     *)
(*                                                                            *)
(* * Rings with absolute value :                                              *)
(*                    absRingType == interface type for a ring with absolute  *)
(*                                   value structure.                         *)
(*     AbsRingMixin abs0 absN1 absD absM abseq0 == builds the mixin for a     *)
(*                                   ring with absolute value from the        *)
(*                                   algebraic properties of the absolute     *)
(*                                   value; the carrier type must have a      *)
(*                                   ringType structure.                      *)
(*      [absRingType of T for cT] == T-clone of the absRingType structure cT. *)
(*             [absRingType of T] == clone of a canonical absRingType         *)
(*                                   structure on T.                          *)
(*                           `|x| == the absolute value of x.                 *)
(*                         ball N == balls defined by the norm/absolute value *)
(*                                   N.                                       *)
(*                   entourage_ N == entourages defined by the norm/absolute  *)
(*                                   value N.                                 *)
(*                                                                            *)
(* * Normed modules :                                                         *)
(*                normedModType K == interface type for a normed module       *)
(*                                   structure over the ring with absolute    *)
(*                                   value K.                                 *)
(* NormedModMixin normD normZ entn normeq0 == builds the mixin for a normed   *)
(*                                   module from the algebraic properties of  *)
(*                                   the norm and the compatibility between   *)
(*                                   the norm and entourages; the carrier     *)
(*                                   type must have a lmodType K structure    *)
(*                                   for K an absRingType.                    *)
(*            NormedModType K T m == packs the mixin m to build a             *)
(*                                   normedModType K; T must have canonical   *)
(*                                   lmodType K and uniformType structures.   *)
(*  [normedModType K of T for cT] == T-clone of the normedModType K structure *)
(*                                   cT.                                      *)
(*         [normedModType K of T] == clone of a canonical normedModType K     *)
(*                                   structure on T.                          *)
(*                         `|[x]| == the norm of x.                           *)
(*                        bounded == set of bounded sets.                     *)
(*                                                                            *)
(* * Complete normed modules :                                                *)
(*        completeNormedModType K == interface type for a complete normed     *)
(*                                   module structure over the ring with      *)
(*                                   absolute value K.                        *)
(* [completeNormedModType K of T] == clone of a canonical complete normed     *)
(*                                   module structure over K on T.            *)
(*                                                                            *)
(* * Filters :                                                                *)
(*          at_left x, at_right x == filters on real numbers for predicates   *)
(*                                   that locally hold on the left/right of   *)
(*                                   x.                                       *)
(*                Rbar_locally' x == filter on extended real numbers that     *)
(*                                   corresponds to locally' x if x is a real *)
(*                                   number and to predicates that are        *)
(*                                   eventually true if x is +oo/-oo.         *)
(*                 Rbar_locally x == same as Rbar_locally' where locally' is  *)
(*                                   replaced with locally.                   *)
(*                 Rbar_loc_seq x == sequence that converges to x in the set  *)
(*                                   of extended real numbers.                *)
(*                                                                            *)
(* --> We used these definitions to prove the intermediate value theorem and  *)
(*     the Heine-Borel theorem, which states that the compact sets of R^n are *)
(*     the closed and bounded sets.                                           *)
(******************************************************************************)

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.
Import GRing.Theory Num.Def Num.Theory.

Local Open Scope classical_set_scope.

(** rings with an absolute value *)

Module AbsRing.

Record mixin_of (D : ringType) := Mixin {
  abs : D -> R;
  ax1 : abs 0 = 0 ;
  ax2 : abs (- 1) = 1 ;
  ax3 : forall x y : D, abs (x + y) <= abs x + abs y ;
  ax4 : forall x y : D, abs (x * y) = abs x * abs y ;
  ax5 : forall x : D, abs x = 0 -> x = 0
}.

Section ClassDef.

Record class_of (K : Type) := Class {
  base : Num.NumDomain.class_of K ;
  mixin : mixin_of (Num.NumDomain.Pack base K)
}.
Local Coercion base : class_of >-> Num.NumDomain.class_of.
Local Coercion mixin : class_of >-> mixin_of.

Structure type := Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (T : Type) (cT : type).
Definition class := let: Pack _ c _ := cT return class_of cT in c.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).
Definition clone c of phant_id class c := @Pack T c T.
Definition pack b0 (m0 : mixin_of (@Num.NumDomain.Pack T b0 T)) :=
  fun bT b & phant_id (Num.NumDomain.class bT) b =>
  fun    m & phant_id m0 m => Pack (@Class T b m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition zmodType := @GRing.Zmodule.Pack cT xclass xT.
Definition ringType := @GRing.Ring.Pack cT xclass xT.
Definition comRingType := @GRing.ComRing.Pack cT xclass xT.
Definition unitRingType := @GRing.UnitRing.Pack cT xclass xT.
Definition comUnitRingType := @GRing.ComUnitRing.Pack cT xclass xT.
Definition idomainType := @GRing.IntegralDomain.Pack cT xclass xT.
Definition numDomainType := @Num.NumDomain.Pack cT xclass xT.

End ClassDef.

Module Exports.

Coercion base : class_of >-> Num.NumDomain.class_of.
Coercion mixin : class_of >-> mixin_of.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> GRing.Zmodule.type.
Canonical zmodType.
Coercion ringType : type >-> GRing.Ring.type.
Canonical ringType.
Coercion comRingType : type >-> GRing.ComRing.type.
Canonical comRingType.
Coercion unitRingType : type >-> GRing.UnitRing.type.
Canonical unitRingType.
Coercion comUnitRingType : type >-> GRing.ComUnitRing.type.
Canonical comUnitRingType.
Coercion idomainType : type >-> GRing.IntegralDomain.type.
Canonical idomainType.
Coercion numDomainType : type >-> Num.NumDomain.type.
Canonical numDomainType.
Notation AbsRingMixin := Mixin.
Notation AbsRingType T m := (@pack T _ m _ _ id _ id).
Notation "[ 'absRingType' 'of' T 'for' cT ]" := (@clone T cT _ idfun)
  (at level 0, format "[ 'absRingType'  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'absRingType' 'of' T ]" := (@clone T _ _ id)
  (at level 0, format "[ 'absRingType'  'of'  T ]") : form_scope.
Notation absRingType := type.

End Exports.

End AbsRing.

Export AbsRing.Exports.

Definition abs {K : absRingType} : K -> R := @AbsRing.abs _ (AbsRing.class K).
Notation "`| x |" := (abs x%R) : R_scope.
Notation "`| x |" := (abs x%R) : real_scope.

Section AbsRing1.

Context {K : absRingType}.
Implicit Types x : K.

Lemma absr0 : `|0 : K| = 0. Proof. exact: AbsRing.ax1. Qed.

Lemma absrN1: `|- 1 : K| = 1.
Proof. exact: AbsRing.ax2. Qed.

Lemma ler_abs_add (x y : K) :  `|x + y| <= `|x|%real + `|y|%real.
Proof. exact: AbsRing.ax3. Qed.

Lemma absrM (x y : K) : `|x * y| = `|x|%real * `|y|%real.
Proof. exact: AbsRing.ax4. Qed.

Lemma absr0_eq0 (x : K) : `|x| = 0 -> x = 0.
Proof. exact: AbsRing.ax5. Qed.

Lemma absrN x : `|- x| = `|x|.
Proof.
gen have le_absN1 : x / `|- x| <= `|x|.
  by rewrite -mulN1r absrM absrN1 mul1r.
by apply/eqP; rewrite eqr_le le_absN1 /= -{1}[x]opprK le_absN1.
Qed.

Lemma absrB (x y : K) : `|x - y| = `|y - x|.
Proof. by rewrite -absrN opprB. Qed.

Lemma absr1 : `|1 : K| = 1. Proof. by rewrite -absrN absrN1. Qed.

Lemma absr_ge0 x : 0 <= `|x|.
Proof.
rewrite -(@pmulr_rge0 _ 2) // mulr2n mulrDl !mul1r.
by rewrite -{2}absrN (ler_trans _ (ler_abs_add _ _)) // subrr absr0.
Qed.

Lemma absr_eq0 x : (`|x| == 0) = (x == 0).
Proof. by apply/eqP/eqP=> [/absr0_eq0//|->]; rewrite absr0. Qed.

Lemma absr1_gt0 : `|1 : K| > 0.
Proof. by rewrite ltr_def absr1 oner_eq0 /=. Qed.

Lemma absrX x n : `|x ^+ n| <= `|x|%real ^+ n.
Proof.
elim: n => [|n IH]; first  by rewrite !expr0 absr1.
by rewrite !exprS absrM ler_pmul // absr_ge0.
Qed.

End AbsRing1.
Hint Resolve absr_ge0.
Hint Resolve absr1_gt0.

Definition ball (V : zmodType) (norm : V -> R) (x : V)
  (e : R) := [set y | norm (x - y) < e].
Arguments ball {V} norm x e%R y /.

Definition entourage_ (V : zmodType) (norm : V -> R) :=
  filter_from [set e : R | e > 0] (fun e => [set xy | norm (xy.1 - xy.2) < e]).

Section NormedUniformity.

Variable (V : zmodType) (norm : V -> R).
Hypothesis (norm0 : norm 0 = 0).
Hypothesis (normB : forall x y, norm (x - y) = norm (y - x)).
Hypothesis (ler_dist_add : forall z x y,
  norm (x - y) <= norm (x - z) + norm (z - y)).

Program Definition uniformityOfNormMixin :=
  @Uniform.Mixin V (locally_ (entourage_ norm)) (entourage_ norm) _ _ _ _ _.
Next Obligation.
apply: filter_from_filter; first by exists 1.
move=> _ _ /posnumP[e1] /posnumP[e2]; exists (minr e1%:num e2%:num) => // xy.
by rewrite ltr_minr => /andP.
Qed.
Next Obligation.
by case: H => _/posnumP[e] sA xy xey; apply: sA; rewrite xey subrr norm0.
Qed.
Next Obligation.
case: H => _/posnumP[e] sA; exists e%:num => // xy; rewrite normB => xey.
exact: sA.
Qed.
Next Obligation.
case: H => _/posnumP[e] sA; exists [set xy | norm (xy.1 - xy.2) < e%:num / 2].
  by exists (e%:num / 2).
move=> xz [y /= xy yz]; apply: sA; apply: ler_lt_trans (ler_dist_add y _ _) _.
by rewrite [e%:num]splitr ltr_add.
Qed.

End NormedUniformity.

(* :TODO: DANGEROUS ! Must change this to include uniform type et al inside absring *)
Coercion absRing_pointedType (K : absRingType) := PointedType K 0.
Canonical absRing_pointedType.
Coercion absRing_filteredType (K : absRingType) :=
   FilteredType K K (locally_ (entourage_ abs)).
Canonical absRing_filteredType.

(* :TODO: to math-comp *)
Lemma subr_trans (M : zmodType) (z x y : M) : x - y = (x - z) + (z - y).
Proof. by rewrite addrA addrNK. Qed.

Lemma ler_dist_abs_add (K : absRingType) (z x y : K) :
  `|x - y| <= `|x - z|%real + `|z - y|%real.
Proof. by rewrite (subr_trans z) ler_abs_add. Qed.

Definition AbsRingUniformMixin (K : absRingType) :=
  uniformityOfNormMixin absr0 absrB (@ler_dist_abs_add K).

Coercion absRing_topologicalType (K : absRingType) :=
  TopologicalType K (topologyOfEntourageMixin (AbsRingUniformMixin K)).
Canonical absRing_topologicalType.
Coercion absRing_UniformType (K : absRingType) :=
  UniformType K (AbsRingUniformMixin K).
Canonical absRing_UniformType.

(** real numbers *)

Program Definition R_AbsRingMixin :=
 @AbsRing.Mixin _ normr (normr0 _) (normrN1 _) (@ler_norm_add _) _ (@normr0_eq0 _).
Next Obligation. by rewrite normrM. Qed.
Canonical R_absRingType := AbsRingType R R_AbsRingMixin.

Canonical R_pointedType := [pointedType of R for R_absRingType].
Canonical R_filteredType := [filteredType R of R for R_absRingType].
Canonical R_topologicalType := [topologicalType of R for R_absRingType].
Canonical R_uniformType := [uniformType of R for R_absRingType].
Canonical Ro_pointedType := [pointedType of R^o for R_absRingType].
Canonical Ro_filteredType := [filteredType R^o of R^o for R_absRingType].
Canonical Ro_topologicalType := [topologicalType of R^o for R_absRingType].
Canonical Ro_uniformType := [uniformType of R^o for R_absRingType].

(** ** Modules with a norm *)

Reserved Notation  "`|[ x ]|" (at level 0, x at level 99, format "`|[ x ]|").

Module NormedModule.

Record mixin_of (K : absRingType) (V : lmodType K) loc
  (m : @Uniform.mixin_of V loc) := Mixin {
  norm : V -> R ;
  ax1 : forall (x y : V), norm (x + y) <= norm x + norm y ;
  ax2 : forall (l : K) (x : V), norm (l *: x) = `|l|%real * norm x;
  ax3 : Uniform.entourage m = entourage_ norm;
  ax4 : forall x : V, norm x = 0 -> x = 0
}.

Section ClassDef.

Variable K : absRingType.

Record class_of (T : Type) := Class {
  base : GRing.Lmodule.class_of K T ;
  pointed_mixin : Pointed.point_of T ;
  locally_mixin : Filtered.locally_of T T ;
  topological_mixin : @Topological.mixin_of T locally_mixin ;
  uniform_mixin : @Uniform.mixin_of T locally_mixin;
  mixin : @mixin_of _ (@GRing.Lmodule.Pack K (Phant K) T base T) _ uniform_mixin
}.
Local Coercion base : class_of >-> GRing.Lmodule.class_of.
Definition base2 T (c : class_of T) :=
  @Uniform.Class _
    (@Topological.Class _
      (Filtered.Class
       (Pointed.Class (@base T c) (pointed_mixin c))
       (locally_mixin c))
      (topological_mixin c))
    (uniform_mixin c).
Local Coercion base2 : class_of >-> Uniform.class_of.
Local Coercion mixin : class_of >-> mixin_of.

Structure type (phK : phant K) :=
  Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (phK : phant K) (T : Type) (cT : type phK).

Definition class := let: Pack _ c _ := cT return class_of cT in c.
Definition clone c of phant_id class c := @Pack phK T c T.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition pack b0 l0 um0 (m0 : @mixin_of _ (@GRing.Lmodule.Pack K (Phant K) T b0 T) l0 um0) :=
  fun bT b & phant_id (@GRing.Lmodule.class K phK bT) b =>
  fun ubT (ub : Uniform.class_of _) & phant_id (@Uniform.class ubT) ub =>
  fun   m & phant_id m0 m => Pack phK (@Class T b ub ub ub ub m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition zmodType := @GRing.Zmodule.Pack cT xclass xT.
Definition lmodType := @GRing.Lmodule.Pack K phK cT xclass xT.
Definition pointedType := @Pointed.Pack cT xclass xT.
Definition filteredType := @Filtered.Pack cT cT xclass xT.
Definition topologicalType := @Topological.Pack cT xclass xT.
Definition uniformType := @Uniform.Pack cT xclass xT.
Definition join_zmodType := @GRing.Zmodule.Pack uniformType xclass xT.
Definition join_lmodType := @GRing.Lmodule.Pack K phK uniformType xclass xT.
End ClassDef.

Module Exports.

Coercion base : class_of >-> GRing.Lmodule.class_of.
Coercion base2 : class_of >-> Uniform.class_of.
Coercion mixin : class_of >-> mixin_of.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> GRing.Zmodule.type.
Canonical zmodType.
Coercion lmodType : type >-> GRing.Lmodule.type.
Canonical lmodType.
Coercion pointedType : type >-> Pointed.type.
Canonical pointedType.
Coercion filteredType : type >-> Filtered.type.
Canonical filteredType.
Coercion topologicalType : type >-> Topological.type.
Canonical topologicalType.
Coercion uniformType : type >-> Uniform.type.
Canonical uniformType.
Canonical join_zmodType.
Canonical join_lmodType.

Notation normedModType K := (type (Phant K)).
Notation NormedModType K T m := (@pack _ (Phant K) T _ _ _ m _ _ id _ _ id _ id).
Notation NormedModMixin := Mixin.
Notation "[ 'normedModType' K 'of' T 'for' cT ]" := (@clone _ (Phant K) T cT _ idfun)
  (at level 0, format "[ 'normedModType'  K  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'normedModType' K 'of' T ]" := (@clone _ (Phant K) T _ _ id)
  (at level 0, format "[ 'normedModType'  K  'of'  T ]") : form_scope.

End Exports.

End NormedModule.

Export NormedModule.Exports.

Definition norm {K : absRingType} {V : normedModType K} : V -> R :=
  NormedModule.norm (NormedModule.class _).
Notation "`|[ x ]|" := (norm x) : ring_scope.

(** Rings with absolute values are normed modules *)

Lemma entourage_absE (K : absRingType) : entourage = entourage_ (@abs K).
Proof. by []. Qed.

Definition AbsRing_NormedModMixin (K : absRingType) :=
  @NormedModule.Mixin K _ _ _ (abs : K^o -> R) ler_abs_add absrM
  (entourage_absE K) absr0_eq0.
Canonical AbsRing_NormedModType (K : absRingType) :=
  NormedModType K K^o (AbsRing_NormedModMixin _).

Section NormedModule1.
Context {K : absRingType} {V : normedModType K}.
Implicit Types (l : K) (x y : V) (eps : posreal).

Lemma ler_normm_add x y : `|[x + y]| <= `|[x]| + `|[y]|.
Proof. exact: NormedModule.ax1. Qed.

Lemma normmZ l x : `|[l *: x]| = `|l|%real * `|[x]|.
Proof. exact: NormedModule.ax2. Qed.

Notation entourage_norm := (entourage_ (@norm K V)).

Notation locally_norm := (locally_ entourage_norm).

Lemma entourage_normE : entourage_norm = entourage.
Proof. by rewrite -NormedModule.ax3. Qed.

Lemma normm0_eq0 x : `|[x]| = 0 -> x = 0.
Proof. exact: NormedModule.ax4. Qed.

Lemma normmN x : `|[- x]| = `|[x]|.
Proof.
gen have le_absN1 : x / `|[- x]| <= `|[x]|.
  by rewrite -scaleN1r normmZ absrN1 mul1r.
by apply/eqP; rewrite eqr_le le_absN1 /= -{1}[x]opprK le_absN1.
Qed.

Lemma normmB x y : `|[x - y]| = `|[y - x]|.
Proof. by rewrite -normmN opprB. Qed.

Lemma normm0 : `|[0 : V]| = 0.
Proof.
apply/eqP; rewrite eqr_le; apply/andP; split.
  by rewrite -{1}(scale0r 0) normmZ absr0 mul0r.
by rewrite -(ler_add2r `|[0 : V]|) add0r -{1}[0 : V]add0r ler_normm_add.
Qed.
Hint Resolve normm0.

Lemma normm_eq0 x : (`|[x]| == 0) = (x == 0).
Proof. by apply/eqP/eqP=> [/normm0_eq0|->//]. Qed.

Lemma normm_ge0 x : 0 <= `|[x]|.
Proof.
rewrite -(@pmulr_rge0 _ 2) // mulr2n mulrDl !mul1r.
by rewrite -{2}normmN (ler_trans _ (ler_normm_add _ _)) // subrr normm0.
Qed.

Lemma normm_gt0 x : (0 < `|[x]|) = (x != 0).
Proof. by rewrite ltr_def normm_eq0 normm_ge0 andbT. Qed.

Lemma normm_lt0 x : (`|[x]| < 0) = false.
Proof. by rewrite ltrNge normm_ge0. Qed.

Lemma normm_le0 x : (`|[x]| <= 0) = (x == 0).
Proof. by rewrite lerNgt normm_gt0 negbK. Qed.

Lemma absRE (x : R) : `|x|%real = `|x|%R.
Proof. by []. Qed.

Lemma ler_distm_dist x y : `| `|[x]| - `|[y]| | <= `|[x - y]|.
Proof.
wlog gt_xy : x y / `|[x]| >= `|[y]| => [hw|].
  by have [/hw//|/ltrW/hw] := lerP `|[y]| `|[x]|; rewrite absRE distrC normmB.
rewrite absRE ger0_norm ?subr_ge0 // ler_subl_addr.
by rewrite -{1}[x](addrNK y) ler_normm_add.
Qed.

Lemma entourage_ball (e : posreal) :
  entourage [set xy : V * V | `|[xy.1 - xy.2]| < e%:num].
Proof. by rewrite -entourage_normE; apply: in_filter_from. Qed.
Hint Resolve entourage_ball.

Lemma distm_lt_split z x y (e : R) :
  `|[x - z]| < (e / 2)%R -> `|[z - y]| < (e / 2)%R -> `|[x - y]| < e.
Proof.
move=> xz zy; rewrite -(subrK z x) -addrA (ler_lt_trans (ler_normm_add _ _)) //.
by rewrite [e]splitr ltr_add.
Qed.

Lemma distm_lt_splitr z x y (e : R) :
  `|[z - x]| < (e / 2)%R -> `|[z - y]| < (e / 2)%R -> `|[x - y]| < e.
Proof. by rewrite normmB; apply: distm_lt_split. Qed.

Lemma distm_lt_splitl z x y (e : R) :
  `|[x - z]| < (e / 2)%R -> `|[y - z]| < (e / 2)%R -> `|[x - y]| < e.
Proof. by rewrite (normmB y); apply: distm_lt_split. Qed.

Lemma normm_leW x (e : R) : e > 0 -> `|[x]| <= (e / 2)%R -> `|[x]| < e.
Proof.
move=> /posnumP[{e}e] /ler_lt_trans ->//.
by rewrite [X in _ < X]splitr ltr_spaddl.
Qed.

Lemma normm_lt_split  x y (e : R) :
  `|[x]| < (e / 2)%R -> `|[y]| < (e / 2)%R -> `|[x + y]| < e.
Proof.
by move=> xlt ylt; rewrite -[y]opprK (@distm_lt_split 0) ?subr0 ?opprK ?add0r.
Qed.

Lemma closeE x y : close x y = (x = y).
Proof.
rewrite propeqE; split => [cl_xy|->//]; have [//|neq_xy] := eqVneq x y.
have dxy_gt0 : `|[x - y]| > 0 by rewrite normm_gt0 subr_eq0.
have dxy_ge0 := ltrW dxy_gt0.
have /cl_xy /= := (entourage_ball ((PosNum dxy_gt0)%:num / 2)%:pos).
rewrite -subr_lt0 ler_gtF // -[X in X - _]mulr1 -mulrBr mulr_ge0 //.
by rewrite subr_ge0 -(@ler_pmul2r _ 2) // mulVf // mul1r ler1n.
Qed.
Lemma eq_close x y : close x y -> x = y. by rewrite closeE. Qed.

Lemma locally_le_locally_norm x : flim (locally x) (locally_norm x).
Proof.
move=> P [A entA sAB]; apply/locallyP; exists A => //.
by rewrite -entourage_normE.
Qed.

Lemma locally_norm_le_locally x : flim (locally_norm x) (locally x).
Proof.
by move=> P /locallyP [A entA sAP]; exists A => //; rewrite entourage_normE.
Qed.

(* NB: this lemmas was not here before *)
Lemma locally_locally_norm : locally_norm = locally.
Proof.
by rewrite funeqE => x; rewrite /locally_norm entourage_normE
  filter_from_entourageE.
Qed.

Lemma filter_from_norm_locally x :
  @filter_from R _ [set x : R | 0 < x] (ball norm x) = locally x.
Proof.
rewrite predeqE => A; split=> [[_/posnumP[e] sxeA] |].
  by rewrite -locally_entourageE; exists [set xy | `|[xy.1 - xy.2]| < e%:num].
rewrite -locally_locally_norm => - [B [_/posnumP[e] seB] sBA].
by exists e%:num => // y xye; apply/sBA/seB.
Qed.

Lemma locally_normP x P :
  locally x P <-> @filter_from R _ [set x : R | 0 < x] (ball norm x) P.
Proof. by rewrite filter_from_norm_locally. Qed.

Lemma locally_normE (x : V) (P : set V) :
  locally_norm x P = \near x, P x.
Proof. by rewrite locally_locally_norm near_simpl. Qed.

Lemma filter_from_normE (x : V) (P : set V) :
  @filter_from R _ [set x : R | 0 < x] (ball norm x) P = \near x, P x.
Proof. by rewrite filter_from_norm_locally. Qed.

Lemma near_locally_norm (x : V) (P : set V) :
  (\forall x \near locally_norm x, P x) = \near x, P x.
Proof. exact: locally_normE. Qed.

Lemma locally_norm_ball x (e : posreal) :
  locally_norm x (ball norm x e%:num).
Proof.
by rewrite locally_locally_norm -filter_from_norm_locally; exists e%:num.
Qed.

Lemma locally_ball (x : V) (e : posreal) : locally x (ball norm x e%:num).
Proof. rewrite -locally_locally_norm; apply: locally_norm_ball. Qed.

Lemma ball_triangle (x y z : V) (e1 e2 : R) :
  ball norm x e1 y -> ball norm y e2 z -> ball norm x (e1 + e2) z.
Proof.
rewrite /ball => H1 H2; rewrite (subr_trans y).
by rewrite (ler_lt_trans (ler_normm_add _ _)) ?ltr_add.
Qed.

Lemma ball_center (x : V) (e : posreal) : ball norm x e%:num x.
Proof. by rewrite /ball subrr normm0. Qed.

Lemma ball_dec x y (e : R) : {ball norm x e y} + {~ ball norm x e y}.
Proof. exact: pselect. Qed.

Lemma ball_sym x y (e : R) : ball norm x e y -> ball norm y e x.
Proof. by rewrite /ball -opprB normmN. Qed.

Lemma ball_norm_le x (e1 e2 : R) :
  e1 <= e2 -> ball norm x e1 `<=` ball norm x e2.
Proof. by move=> e1e2 y /ltr_le_trans; apply. Qed.

Lemma norm_close x y :
  close x y = (forall e : posreal, ball norm x e%:num y).
Proof.
rewrite propeqE; split; first by move=> xy e; have /xy := entourage_ball e.
by move=> xy A; rewrite -entourage_normE => - [_/posnumP[e]]; apply; apply: xy.
Qed.

Lemma ball_norm_eq x y : (forall eps : posreal, ball norm x eps%:num y) -> x = y.
Proof. by rewrite -norm_close closeE. Qed.

Lemma flim_unique {F} {FF : ProperFilter F} :
  is_prop [set x : V | F --> x].
Proof. by move=> Fx Fy; rewrite -closeE; apply: flim_close. Qed.

Lemma locally_flim_unique (x y : V) : x --> y -> x = y.
Proof. by rewrite -closeE; apply: flim_close. Qed.

Lemma lim_id (x : V) : lim x = x.
Proof. by symmetry; apply: locally_flim_unique; apply/cvg_ex; exists x. Qed.

Lemma flim_lim {F} {FF : ProperFilter F} (l : V) :
  F --> l -> lim F = l.
Proof. by move=> Fl; have Fcv := cvgP Fl; apply: flim_unique. Qed.

Lemma flim_map_lim {T : Type} {F} {FF : ProperFilter F} (f : T -> V) (l : V) :
  f @ F --> l -> lim (f @ F) = l.
Proof. exact: flim_lim. Qed.

End NormedModule1.

Hint Resolve normm_ge0.
Hint Resolve entourage_ball.
Hint Resolve ball_center.

Module Export LocallyNorm.
Definition locally_simpl := (locally_simpl,@locally_locally_norm,@filter_from_norm_locally).
End LocallyNorm.

Module Export NearNorm.
Definition near_simpl := (@near_simpl, @locally_normE,
   @filter_from_normE, @near_locally_norm).
Ltac near_simpl := rewrite ?near_simpl.
End NearNorm.

Lemma locallyN (R : absRingType) (x : R) :
  locally (- x) = [set [set - y | y in A] | A in locally x].
Proof.
rewrite predeqE -!(@filter_from_norm_locally _ [normedModType R of R^o]) => A.
split=> [[e egt0 oppxe_A] | [B [e egt0 xe_B] <-]]; last first.
  exists e => // y xe_y; exists (- y); last by rewrite opprK.
  by apply/xe_B; rewrite /ball opprK -normmN -mulN1r mulrDr !mulN1r.
exists [set - y | y in A]; last first.
  rewrite predeqE => y; split=> [[z [t At <- <-]] |Ay]; first by rewrite opprK.
  by exists (- y); [exists y|rewrite opprK].
exists e => // y xe_y; exists (- y); last by rewrite opprK.
by apply/oppxe_A; rewrite /ball normmB opprK addrC.
Qed.

Lemma openN (R : absRingType) (A : set R) :
  open A -> open [set - x | x in A].
Proof.
move=> Aop; rewrite openE => _ [x /Aop x_A <-].
by rewrite /interior locallyN; exists A.
Qed.

Lemma closedN (R : absRingType) (A : set R) :
  closed A -> closed [set - x | x in A].
Proof.
move=> Acl x clNAx.
suff /Acl : closure A (- x) by exists (- x)=> //; rewrite opprK.
move=> B oppx_B; have : [set - x | x in A] `&` [set - x | x in B] !=set0.
  by apply: clNAx; rewrite -[x]opprK locallyN; exists B.
move=> [y [[z Az oppzey] [t Bt opptey]]]; exists (- y).
by split; [rewrite -oppzey opprK|rewrite -opptey opprK].
Qed.

Section NormedModule2.

Context {T : Type} {K : absRingType} {V : normedModType K}.

Lemma flimi_unique {F} {FF : ProperFilter F} (f : T -> set V) :
  {near F, is_fun f} -> is_prop [set x : V | f `@ F --> x].
Proof. by move=> ffun fx fy; rewrite -closeE; apply: flimi_close. Qed.

Lemma flim_normP {F : set (set V)} {FF : Filter F} (y : V) :
  F --> y <-> forall eps : R, 0 < eps -> \forall y' \near F, `|[y - y']| < eps.
Proof. by rewrite -filter_fromP /= !locally_simpl. Qed.

Lemma flim_normW {F : set (set V)} {FF : Filter F} (y : V) :
  (forall eps : R, 0 < eps -> \forall y' \near F, `|[y - y']| <= eps) ->
  F --> y.
Proof.
move=> cv; apply/flim_normP => _/posnumP[e]; near=> x.
by apply: normm_leW => //; near: x; apply: cv.
Grab Existential Variables. all: end_near. Qed.

Lemma flim_norm {F : set (set V)} {FF : Filter F} (y : V) :
  F --> y -> forall eps, eps > 0 -> \forall y' \near F, `|[y - y']| < eps.
Proof. by move=> /flim_normP. Qed.

Lemma flimi_map_lim {F} {FF : ProperFilter F} (f : T -> V -> Prop) (l : V) :
  F (fun x : T => is_prop (f x)) ->
  f `@ F --> l -> lim (f `@ F) = l.
Proof.
move=> f_prop f_l; apply: get_unique => // l' f_l'.
exact: flimi_unique _ f_l' f_l.
Qed.

End NormedModule2.
Arguments flim_norm {_ _ F FF}.

Lemma continuous_flim_norm {K : absRingType} (V W : normedModType K) (f : V -> W) x l :
  continuous f -> x --> l -> forall e : posreal, `|[f l - f x]| < e.
Proof.
move=> cf xl e.
have /flim_norm /(_ _ [gt0 of e%:num]) /locally_normP [_/posnumP[d]] := (cf l).
apply; have /flim_norm /(_ _ [gt0 of d%:num]) := xl.
by move=> /locally_normP [_/posnumP[d']]; apply.
Qed.

Section Locally.

Context {K : absRingType} {V : normedModType K}.

Lemma forallN {U} (P : set U) : (forall x, ~ P x) = ~ exists x, P x.
Proof. (*boolP*)
rewrite propeqE; split; first by move=> fP [x /fP].
by move=> nexP x Px; apply: nexP; exists x.
Qed.

Lemma eqNNP (P : Prop) : (~ ~ P) = P. (*boolP*)
Proof. by rewrite propeqE; split=> [/contrapT|?]. Qed.

Lemma existsN {U} (P : set U) : (exists x, ~ P x) = ~ forall x, P x. (*boolP*)
Proof.
rewrite propeqE; split=> [[x Px] Nall|Nall]; first exact: Px.
by apply: contrapT; rewrite -forallN => allP; apply: Nall => x; apply: contrapT.
Qed.

Lemma ex_ball_sig (x : V) (P : set V) :
  ~ (forall eps : posreal, ~ (ball norm x eps%:num `<=` ~` P)) ->
    {d : posreal | ball norm x d%:num `<=` ~` P}.
Proof.
rewrite forallN eqNNP => exNP.
pose D := [set d : R | d > 0 /\ ball norm x d `<=` ~` P].
have [|d_gt0] := @getPex _ D; last by exists (PosNum d_gt0).
by move: exNP => [e eP]; exists e%:num.
Qed.

Lemma locallyC (x : V) (P : set V) :
  ~ (forall eps : posreal, ~ (ball norm x eps%:num `<=` ~` P)) ->
  locally x (~` P).
Proof. by move=> /ex_ball_sig [e] ?; apply/locally_normP; exists e%:num. Qed.

Lemma locallyC_ball (x : V) (P : set V) :
  locally x (~` P) -> {d : posreal | ball norm x d%:num `<=` ~` P}.
Proof.
move=> /locally_normP xNP; apply: ex_ball_sig.
by have [_ /posnumP[e] eP /(_ _ eP)] := xNP.
Qed.

Lemma locally_ex (x : V) (P : V -> Prop) : locally x P ->
  {d : posreal | forall y, ball norm x d%:num y -> P y}.
Proof.
move=> /locally_normP xP.
pose D := [set d : R | d > 0 /\ forall y, ball norm x d y -> P y].
have [|d_gt0 dP] := @getPex _ D; last by exists (PosNum d_gt0).
by move: xP => [e bP]; exists e.
Qed.

End Locally.

Lemma unif_contP (K K' : absRingType) (V : normedModType K)
  (V' : normedModType K') (f : V -> V') :
  unif_cont f <->
  forall e, e > 0 -> exists2 d, d > 0 &
    forall x, ball norm x.1 d x.2 -> ball norm (f x.1) e (f x.2).
Proof.
have fappF : Filter ((fun xy => (f xy.1, f xy.2)) @ entourage_ norm).
  by rewrite entourage_normE; apply: filtermap_filter.
by rewrite /unif_cont -!entourage_normE filter_fromP.
Qed.

Section Locally_fct.

Context {T : Type} {K : absRingType} {V : normedModType K}.

Lemma near_ball (y : V) (eps : posreal) :
   \forall y' \near y, ball norm y eps%:num y'.
Proof. exact: locally_ball. Qed.

Lemma flim_ballP {F} {FF : Filter F} (y : V) :
  F --> y <-> forall eps, 0 < eps -> \forall y' \near F, ball norm y eps y'.
Proof. exact: flim_normP. Qed.
Definition flim_locally := @flim_ballP.

Lemma flim_ballPpos {F} {FF : Filter F} (y : V) :
  F --> y <->
  forall eps : posreal, \forall y' \near F, ball norm y eps%:num y'.
Proof.
by split => [/flim_ballP|] pos; [case|apply/flim_ballP=> _/posnumP[eps] //].
Qed.

Lemma flim_ball {F} {FF : Filter F} (y : V) :
  F --> y -> forall eps, 0 < eps -> \forall y' \near F, ball norm y eps y'.
Proof. by move/flim_ballP. Qed.

Lemma app_flim_locally {F} {FF : Filter F} (f : T -> V) y :
  f @ F --> y <->
  forall eps, 0 < eps -> \forall x \near F, ball norm y eps (f x).
Proof. exact: flim_ballP. Qed.

Lemma flimi_ballP {F} {FF : Filter F} (f : T -> V -> Prop) y :
  f `@ F --> y <->
  forall eps, 0 < eps ->
    \forall x \near F, exists z, f x z /\ ball norm y eps z.
Proof.
split=> [Fy _/posnumP[eps] |Fy P] /=; first exact/Fy/locally_ball.
move=> /locally_normP[_ /posnumP[eps] subP].
rewrite near_simpl near_mapi; near=> x.
have [//|z [fxz yz]] := near (Fy _ (posnum_gt0 eps)) x.
by exists z => //; split => //; apply: subP.
Unshelve. all: end_near. Qed.
Definition flimi_locally := @flimi_ballP.

Lemma flimi_ball {F} {FF : Filter F} (f : T -> V -> Prop) y :
  f `@ F --> y ->
  forall eps, 0 < eps -> F [set x | exists z, f x z /\ ball norm y eps z].
Proof. by move/flimi_ballP. Qed.

End Locally_fct.

Lemma ler_addgt0Pr (R : realFieldType) (x y : R) :
  reflect (forall e, e > 0 -> x <= y + e) (x <= y).
Proof.
apply/(iffP idP)=> [lexy _/posnumP[e] | lexye]; first by rewrite ler_paddr.
case: (lerP x y) => // ltyx.
have /midf_lt [_] := ltyx; rewrite ltrNge -eqbF_neg => /eqP<-.
suff -> : (y + x) / 2 = y + (x - y) / 2.
  by apply/lexye/divr_gt0 => //; rewrite subr_gt0.
by rewrite !mulrDl addrC -mulN1r -mulrA mulN1r [RHS]addrC {3}(splitr y)
  [RHS]GRing.subrKA.
Qed.

Lemma ler_addgt0Pl (R : realFieldType) (x y : R) :
  reflect (forall e, e > 0 -> x <= e + y) (x <= y).
Proof.
by apply/(equivP (ler_addgt0Pr x y)); split=> lexy e /lexy; rewrite addrC.
Qed.

Lemma in_segment_addgt0Pr (R : realFieldType) (x y z : R) :
  reflect (forall e, e > 0 -> y \in `[(x - e), (z + e)]) (y \in `[x, z]).
Proof.
apply/(iffP idP)=> [xyz _/posnumP[e] | xyz_e].
  rewrite inE; apply/andP; split; last by rewrite ler_paddr // (itvP xyz).
  by rewrite ler_subl_addr ler_paddr // (itvP xyz).
rewrite inE; apply/andP.
by split; apply/ler_addgt0Pr => ? /xyz_e /andP []; rewrite ler_subl_addr.
Qed.

Lemma in_segment_addgt0Pl (R : realFieldType) (x y z : R) :
  reflect (forall e, e > 0 -> y \in `[(- e + x), (e + z)]) (y \in `[x, z]).
Proof.
apply/(equivP (in_segment_addgt0Pr x y z)).
by split=> zxy e /zxy; rewrite [z + _]addrC [_ + x]addrC.
Qed.

Lemma Rhausdorff : hausdorff [topologicalType of R].
Proof.
move=> x y clxy.
apply/eqP; rewrite eqr_le; apply/in_segment_addgt0Pr => _ /posnumP[e].
rewrite inE -ler_distl; set he := (e%:num / 2)%:pos.
have [z []] := clxy _ _ (locally_ball (x : R^o) he) (locally_ball (y : R^o) he).
rewrite /ball normmB => zx yz; apply: ler_trans (ler_dist_add z _ _) _.
by rewrite ltrW // [e%:num]splitr ltr_add.
Qed.

Lemma normedModType_hausdorff (K : absRingType) (V : normedModType K) :
  hausdorff V.
Proof.
move=> p q clp_q; apply/subr0_eq/normm0_eq0/Rhausdorff => A B pq_A.
rewrite -(@normm0 _ V) -(subrr p) => pp_B.
suff loc_preim r C :
  locally `|[p - r]| C -> locally r ((fun r => `|[p - r]|) @^-1` C).
  have [r []] := clp_q _ _ (loc_preim _ _ pp_B) (loc_preim _ _ pq_A).
  by exists `|[p - r]|.
move=> /(@locally_normP _ [normedModType R of R^o]) [_/posnumP[e] sC].
apply/locally_normP; exists e%:num=> // s re_s; apply/sC.
apply: ler_lt_trans (ler_distm_dist _ _) _.
by rewrite opprB addrC -subr_trans normmB.
Qed.

(** * Some Topology on [Rbar] *)

(* NB: already defined in R_scope in Rbar.v *)

Notation "'+oo'" := p_infty : real_scope.
Notation "'-oo'" := m_infty : real_scope.
Definition Rbar_locally' (a : Rbar) (P : R -> Prop) :=
  match a with
    | Finite a => locally' a P
    | +oo => exists M : R, forall x, M < x -> P x
    | -oo => exists M : R, forall x, x < M -> P x
  end.
Definition Rbar_locally (a : Rbar) (P : R -> Prop) :=
  match a with
    | Finite a => locally a P
    | +oo => exists M : R, forall x, M < x -> P x
    | -oo => exists M : R, forall x, x < M -> P x
  end.

Canonical Rbar_eqType := EqType Rbar gen_eqMixin.
Canonical Rbar_choiceType := ChoiceType Rbar gen_choiceMixin.
Canonical Rbar_pointed := PointedType Rbar (+oo).
Canonical Rbar_filter := FilteredType R Rbar (Rbar_locally).

Global Instance Rlocally'_proper (x : R^o) : ProperFilter (locally' x).
Proof.
apply: Build_ProperFilter => A; rewrite /locally' -filter_from_norm_locally.
move=> [_/posnumP[e] sA]; exists (x + e%:num / 2); apply: sA; last first.
  by rewrite eq_sym addrC -subr_eq subrr eq_sym.
rewrite /= opprD addrA subrr sub0r normmN [ `|[_]| ]ger0_norm //.
by rewrite {2}(splitr e%:num) ltr_spaddl.
Qed.

Global Instance Rbar_locally'_filter : forall x, ProperFilter (Rbar_locally' x).
Proof.
case=> [x||]; first exact: Rlocally'_proper.
  apply Build_ProperFilter.
    by move=> P [M gtMP]; exists (M + 1); apply: gtMP; rewrite ltr_addl.
  split=> /= [|P Q [MP gtMP] [MQ gtMQ] |P Q sPQ [M gtMP]]; first by exists 0.
    by exists (maxr MP MQ) => ?; rewrite ltr_maxl => /andP [/gtMP ? /gtMQ].
  by exists M => ? /gtMP /sPQ.
apply Build_ProperFilter.
  by move=> P [M ltMP]; exists (M - 1); apply: ltMP; rewrite gtr_addl oppr_lt0.
split=> /= [|P Q [MP ltMP] [MQ ltMQ] |P Q sPQ [M ltMP]]; first by exists 0.
  by exists (minr MP MQ) => ?; rewrite ltr_minr => /andP [/ltMP ? /ltMQ].
by exists M => ? /ltMP /sPQ.
Qed.
Typeclasses Opaque Rbar_locally'.

Global Instance Rbar_locally_filter : forall x, ProperFilter (Rbar_locally x).
Proof.
case=> [x||].
by apply/locally_filter.
exact: (Rbar_locally'_filter +oo).
exact: (Rbar_locally'_filter -oo).
Qed.
Typeclasses Opaque Rbar_locally.

Lemma near_pinfty_div2 (A : set R) :
  (\forall k \near +oo, A k) -> (\forall k \near +oo, A (k / 2)).
Proof.
by move=> [M AM]; exists (M * 2) => x; rewrite -ltr_pdivl_mulr //; apply: AM.
Qed.

Lemma locally_pinfty_gt c : \forall x \near +oo, c < x.
Proof. by exists c. Qed.

Lemma locally_pinfty_ge c : \forall x \near +oo, c <= x.
Proof. by exists c; apply: ltrW. Qed.

Hint Extern 0 (is_true (0 < _)) => match goal with
  H : ?x \is_near (locally +oo) |- _ =>
    solve[near: x; exists 0 => _/posnumP[x] //] end : core.

Lemma flim_bounded (K : absRingType) (V : normedModType K) {F : set (set V)}
  {FF : Filter F} (y : V) :
  F --> y -> \forall M \near +oo, \forall y' \near F, `|[y']|%real < M.
Proof.
move=> /flim_norm Fy; exists `|[y]| => M.
rewrite -subr_gt0 => subM_gt0; have := Fy _ subM_gt0.
apply: filterS => y' yy'; rewrite -(@ltr_add2r _ (- `|[y]|)).
rewrite (ler_lt_trans _ yy') //.
by rewrite (ler_trans _ (ler_distm_dist _ _)) // absRE distrC ler_norm.
Qed.
Arguments flim_bounded {_ _ F FF}.

Section Bigmaxr.

Variable (R : realDomainType).

Lemma bigmaxr_mkcond I r (P : pred I) (F : I -> R) x :
  \big[maxr/x]_(i <- r | P i) F i =
     \big[maxr/x]_(i <- r) (if P i then F i else x).
Proof.
rewrite unlock; elim: r x => //= i r ihr x.
case P; rewrite ihr // maxr_r //; elim: r {ihr} => //= j r ihr.
by rewrite ler_maxr ihr orbT.
Qed.

Lemma bigminr_maxr I r (P : pred I) (F : I -> R) x :
  \big[minr/x]_(i <- r | P i) F i = - \big[maxr/- x]_(i <- r | P i) - F i.
Proof.
by elim/big_rec2: _ => [|i y _ _ ->]; rewrite ?oppr_max opprK.
Qed.

Lemma bigminr_mkcond I r (P : pred I) (F : I -> R) x :
  \big[minr/x]_(i <- r | P i) F i =
     \big[minr/x]_(i <- r) (if P i then F i else x).
Proof.
rewrite !bigminr_maxr bigmaxr_mkcond; congr (- _).
by apply: eq_bigr => i _; case P.
Qed.

Lemma bigmaxr_split I r (P : pred I) (F1 F2 : I -> R) x :
  \big[maxr/x]_(i <- r | P i) (maxr (F1 i) (F2 i)) =
  maxr (\big[maxr/x]_(i <- r | P i) F1 i) (\big[maxr/x]_(i <- r | P i) F2 i).
Proof.
by elim/big_rec3: _ => [|i y z _ _ ->]; rewrite ?maxrr // maxrCA -!maxrA maxrCA.
Qed.

Lemma bigminr_split I r (P : pred I) (F1 F2 : I -> R) x :
  \big[minr/x]_(i <- r | P i) (minr (F1 i) (F2 i)) =
  minr (\big[minr/x]_(i <- r | P i) F1 i) (\big[minr/x]_(i <- r | P i) F2 i).
Proof.
rewrite !bigminr_maxr -oppr_max -bigmaxr_split; congr (- _).
by apply: eq_bigr => i _; rewrite oppr_min.
Qed.

Lemma filter_andb I r (a P : pred I) :
  [seq i <- r | P i && a i] = [seq i <- [seq j <- r | P j] | a i].
Proof. by elim: r => //= i r ->; case P. Qed.

Lemma bigmaxr_idl I r (P : pred I) (F : I -> R) x :
  \big[maxr/x]_(i <- r | P i) F i = maxr x (\big[maxr/x]_(i <- r | P i) F i).
Proof.
rewrite -big_filter; elim: [seq i <- r | P i] => [|i l ihl].
  by rewrite big_nil maxrr.
by rewrite big_cons maxrCA -ihl.
Qed.

Lemma bigminr_idl I r (P : pred I) (F : I -> R) x :
  \big[minr/x]_(i <- r | P i) F i = minr x (\big[minr/x]_(i <- r | P i) F i).
Proof. by rewrite !bigminr_maxr {1}bigmaxr_idl oppr_max opprK. Qed.

Lemma bigmaxrID I r (a P : pred I) (F : I -> R) x :
  \big[maxr/x]_(i <- r | P i) F i =
  maxr (\big[maxr/x]_(i <- r | P i && a i) F i)
    (\big[maxr/x]_(i <- r | P i && ~~ a i) F i).
Proof.
rewrite -!(big_filter _ (fun _ => _ && _)) !filter_andb !big_filter.
rewrite ![in RHS](bigmaxr_mkcond _ _ F) !big_filter -bigmaxr_split.
have eqmax : forall i, P i ->
  maxr (if a i then F i else x) (if ~~ a i then F i else x) = maxr (F i) x.
  by move=> i _; case: (a i) => //=; rewrite maxrC.
rewrite [RHS](eq_bigr _ eqmax) -!(big_filter _ P).
elim: [seq j <- r | P j] => [|j l ihl]; first by rewrite !big_nil.
by rewrite !big_cons -maxrA -bigmaxr_idl ihl.
Qed.

Lemma bigminrID I r (a P : pred I) (F : I -> R) x :
  \big[minr/x]_(i <- r | P i) F i =
  minr (\big[minr/x]_(i <- r | P i && a i) F i)
    (\big[minr/x]_(i <- r | P i && ~~ a i) F i).
Proof. by rewrite !bigminr_maxr -oppr_max -bigmaxrID. Qed.

Lemma bigmaxr_seq1 I (i : I) (F : I -> R) x :
  \big[maxr/x]_(j <- [:: i]) F j = maxr (F i) x.
Proof. by rewrite unlock /=. Qed.

Lemma bigminr_seq1 I (i : I) (F : I -> R) x :
  \big[minr/x]_(j <- [:: i]) F j = minr (F i) x.
Proof. by rewrite unlock /=. Qed.

Lemma bigmaxr_pred1_eq (I : finType) (i : I) (F : I -> R) x :
  \big[maxr/x]_(j | j == i) F j = maxr (F i) x.
Proof. by rewrite -big_filter filter_index_enum enum1 bigmaxr_seq1. Qed.

Lemma bigminr_pred1_eq (I : finType) (i : I) (F : I -> R) x :
  \big[minr/x]_(j | j == i) F j = minr (F i) x.
Proof. by rewrite bigminr_maxr bigmaxr_pred1_eq oppr_max !opprK. Qed.

Lemma bigmaxr_pred1 (I : finType) i (P : pred I) (F : I -> R) x :
  P =1 pred1 i -> \big[maxr/x]_(j | P j) F j = maxr (F i) x.
Proof. by move/(eq_bigl _ _)->; apply: bigmaxr_pred1_eq. Qed.

Lemma bigminr_pred1 (I : finType) i (P : pred I) (F : I -> R) x :
  P =1 pred1 i -> \big[minr/x]_(j | P j) F j = minr (F i) x.
Proof. by move/(eq_bigl _ _)->; apply: bigminr_pred1_eq. Qed.

Lemma bigmaxrD1 (I : finType) j (P : pred I) (F : I -> R) x :
  P j -> \big[maxr/x]_(i | P i) F i
    = maxr (F j) (\big[maxr/x]_(i | P i && (i != j)) F i).
Proof.
move=> Pj; rewrite (bigmaxrID _ (pred1 j)) [in RHS]bigmaxr_idl maxrA.
by congr maxr; apply: bigmaxr_pred1 => i; rewrite /= andbC; case: eqP => //->.
Qed.

Lemma bigminrD1 (I : finType) j (P : pred I) (F : I -> R) x :
  P j -> \big[minr/x]_(i | P i) F i
    = minr (F j) (\big[minr/x]_(i | P i && (i != j)) F i).
Proof.
by move=> Pj; rewrite !bigminr_maxr (bigmaxrD1 _ _ Pj) oppr_max opprK.
Qed.

Lemma ler_bigmaxr_cond (I : finType) (P : pred I) (F : I -> R) x i0 :
  P i0 -> F i0 <= \big[maxr/x]_(i | P i) F i.
Proof. by move=> Pi0; rewrite (bigmaxrD1 _ _ Pi0) ler_maxr lerr. Qed.

Lemma bigminr_ler_cond (I : finType) (P : pred I) (F : I -> R) x i0 :
  P i0 -> \big[minr/x]_(i | P i) F i <= F i0.
Proof. by move=> Pi0; rewrite (bigminrD1 _ _ Pi0) ler_minl lerr. Qed.

Lemma ler_bigmaxr (I : finType) (F : I -> R) (i0 : I) x :
  F i0 <= \big[maxr/x]_i F i.
Proof. exact: ler_bigmaxr_cond. Qed.

Lemma bigminr_ler (I : finType) (F : I -> R) (i0 : I) x :
  \big[minr/x]_i F i <= F i0.
Proof. exact: bigminr_ler_cond. Qed.

Lemma bigmaxr_lerP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (x <= m /\ forall i, P i -> F i <= m)
    (\big[maxr/x]_(i | P i) F i <= m).
Proof.
apply: (iffP idP) => [|[lexm leFm]]; last first.
  by elim/big_ind: _ => // ??; rewrite ler_maxl =>->.
rewrite bigmaxr_idl ler_maxl => /andP[-> leFm]; split=> // i Pi.
by apply: ler_trans leFm; apply: ler_bigmaxr_cond.
Qed.

Lemma bigminr_gerP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (m <= x /\ forall i, P i -> m <= F i)
    (m <= \big[minr/x]_(i | P i) F i).
Proof.
rewrite bigminr_maxr ler_oppr; apply: (iffP idP).
  by move=> /bigmaxr_lerP [? lemF]; split=> [|??]; rewrite -ler_opp2 ?lemF.
by move=> [? lemF]; apply/bigmaxr_lerP; split=> [|??]; rewrite ler_opp2 ?lemF.
Qed.

Lemma bigmaxr_sup (I : finType) i0 (P : pred I) m (F : I -> R) x :
  P i0 -> m <= F i0 -> m <= \big[maxr/x]_(i | P i) F i.
Proof. by move=> Pi0 ?; apply: ler_trans (ler_bigmaxr_cond _ _ Pi0). Qed.

Lemma bigminr_inf (I : finType) i0 (P : pred I) m (F : I -> R) x :
  P i0 -> F i0 <= m -> \big[minr/x]_(i | P i) F i <= m.
Proof. by move=> Pi0 ?; apply: ler_trans (bigminr_ler_cond _ _ Pi0) _. Qed.

Lemma bigmaxr_ltrP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (x < m /\ forall i, P i -> F i < m)
    (\big[maxr/x]_(i | P i) F i < m).
Proof.
apply: (iffP idP) => [|[ltxm ltFm]]; last first.
  by elim/big_ind: _ => // ??; rewrite ltr_maxl =>->.
rewrite bigmaxr_idl ltr_maxl => /andP[-> ltFm]; split=> // i Pi.
by apply: ler_lt_trans ltFm; apply: ler_bigmaxr_cond.
Qed.

Lemma bigminr_gtrP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (m < x /\ forall i, P i -> m < F i)
    (m < \big[minr/x]_(i | P i) F i).
Proof.
rewrite bigminr_maxr ltr_oppr; apply: (iffP idP).
  by move=> /bigmaxr_ltrP [? ltmF]; split=> [|??]; rewrite -ltr_opp2 ?ltmF.
by move=> [? ltmF]; apply/bigmaxr_ltrP; split=> [|??]; rewrite ltr_opp2 ?ltmF.
Qed.

Lemma bigmaxr_gerP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (m <= x \/ exists2 i, P i & m <= F i)
  (m <= \big[maxr/x]_(i | P i) F i).
Proof.
apply: (iffP idP) => [|[lemx|[i Pi lemFi]]]; last 2 first.
- by rewrite bigmaxr_idl ler_maxr lemx.
- by rewrite (bigmaxrD1 _ _ Pi) ler_maxr lemFi.
rewrite lerNgt => /bigmaxr_ltrP /asboolPn.
rewrite asbool_and negb_and => /orP [/asboolPn/negP|/existsp_asboolPn [i]].
  by rewrite -lerNgt; left.
by move=> /asboolPn/imply_asboolPn [Pi /negP]; rewrite -lerNgt; right; exists i.
Qed.

Lemma bigminr_lerP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (x <= m \/ exists2 i, P i & F i <= m)
  (\big[minr/x]_(i | P i) F i <= m).
Proof.
rewrite bigminr_maxr ler_oppl; apply: (iffP idP).
  by move=> /bigmaxr_gerP [?|[i ??]]; [left|right; exists i => //];
    rewrite -ler_opp2.
by move=> [?|[i ??]]; apply/bigmaxr_gerP; [left|right; exists i => //];
  rewrite ler_opp2.
Qed.

Lemma bigmaxr_gtrP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (m < x \/ exists2 i, P i & m < F i)
  (m < \big[maxr/x]_(i | P i) F i).
Proof.
apply: (iffP idP) => [|[ltmx|[i Pi ltmFi]]]; last 2 first.
- by rewrite bigmaxr_idl ltr_maxr ltmx.
- by rewrite (bigmaxrD1 _ _ Pi) ltr_maxr ltmFi.
rewrite ltrNge => /bigmaxr_lerP /asboolPn.
rewrite asbool_and negb_and => /orP [/asboolPn/negP|/existsp_asboolPn [i]].
  by rewrite -ltrNge; left.
by move=> /asboolPn/imply_asboolPn [Pi /negP]; rewrite -ltrNge; right; exists i.
Qed.

Lemma bigminr_ltrP (I : finType) (P : pred I) m (F : I -> R) x :
  reflect (x < m \/ exists2 i, P i & F i < m)
  (\big[minr/x]_(i | P i) F i < m).
Proof.
rewrite bigminr_maxr ltr_oppl; apply: (iffP idP).
  by move=> /bigmaxr_gtrP [?|[i ??]]; [left|right; exists i => //];
    rewrite -ltr_opp2.
by move=> [?|[i ??]]; apply/bigmaxr_gtrP; [left|right; exists i => //];
  rewrite ltr_opp2.
Qed.

End Bigmaxr.

Arguments bigmaxr_mkcond {R I r}.
Arguments bigmaxrID {R I r}.
Arguments bigmaxr_pred1 {R I} i {P F}.
Arguments bigmaxrD1 {R I} j {P F}.
Arguments ler_bigmaxr_cond {R I P F}.
Arguments ler_bigmaxr {R I F}.
Arguments bigmaxr_sup {R I} i0 {P m F}.
Arguments bigminr_mkcond {R I r}.
Arguments bigminrID {R I r}.
Arguments bigminr_pred1 {R I} i {P F}.
Arguments bigminrD1 {R I} j {P F}.
Arguments bigminr_ler_cond {R I P F}.
Arguments bigminr_ler {R I F}.
Arguments bigminr_inf {R I} i0 {P m F}.

(** ** Matrices *)

Section matrix_normedMod.

Variables (K : absRingType) (m n : nat).

Definition mx_norm (x : 'M[K]_(m, n)) := \big[maxr/0]_ij `|x ij.1 ij.2|.

Program Definition matrix_NormedModMixin :=
  @NormedModMixin _ _
    (@locally _ [filteredType 'M[K]_(m, n) of 'M[K]_(m, n)])
    (Uniform.mixin (Uniform.class _)) mx_norm _ _ _ _.
Next Obligation.
apply/bigmaxr_lerP; split.
  by apply: addr_ge0; apply/bigmaxr_gerP; left.
move=> ij _; rewrite mxE; apply: ler_trans (ler_abs_add _ _) _.
apply: ler_add; apply: ler_bigmaxr.
Qed.
Next Obligation.
apply/eqP; rewrite eqr_le; apply/andP; split.
  apply/bigmaxr_lerP; split.
    by apply: mulr_ge0 => //; apply/bigmaxr_gerP; left.
  by move=> ij _; rewrite mxE absrM ler_wpmul2l //; apply: ler_bigmaxr.
case: (ler0P `|l|%real) => l0.
  have : `|l| == 0 by rewrite eqr_le l0 absr_ge0.
  rewrite absr_eq0 => /eqP->; rewrite scale0r absr0 mul0r; apply/bigmaxr_gerP.
  by left.
rewrite -ler_pdivl_mull //; apply/bigmaxr_lerP; split.
  by apply: mulr_ge0; rewrite ?invr_ge0 //; apply/bigmaxr_gerP; left.
by move=> ij _; rewrite ler_pdivl_mull // -absrM (bigmaxr_sup ij) // mxE.
Qed.
Next Obligation.
rewrite predeqE => A; split; last first.
  move=> [_/posnumP[e] sA]; exists (fun _ _ => [set p | `|p.1 - p.2| < e%:num]).
    by move=> _ _; exists e%:num.
  move=> [x y] /= xy; apply: sA => /=.
  by apply/bigmaxr_ltrP; split=> // ij _; rewrite !mxE.
move=> [P entP sPA]; set sP := fun i j => [set e | 0 < e /\
  [set pq | `|pq.1 - pq.2| < e] `<=` P i j].
have {entP} entP : forall i j, sP i j !=set0.
  by move=> i j; have [e] := entP i j; exists e.
exists (\big[minr/1]_ij get (sP ij.1 ij.2)).
  by apply/bigminr_gtrP; split=> // ij _; have /getPex [] := entP ij.1 ij.2.
move=> [x y] /= /bigminr_gtrP [_ xy]; apply: sPA => i j /=.
have /getPex [_] := entP i j; apply => /=.
by have /bigmaxr_ltrP [_ /(_ (i,j))] := xy (i,j) erefl; rewrite !mxE; apply.
Qed.
Next Obligation.
have /eqP := H; rewrite eqr_le => /andP [/bigmaxr_lerP [_ x0] _].
apply/matrixP => i j; rewrite mxE; apply/eqP.
by rewrite -absr_eq0 eqr_le absr_ge0 (x0 (i,j)).
Qed.

Canonical matrix_normedModType :=
  NormedModType K 'M[K]_(m, n) matrix_NormedModMixin.

End matrix_normedMod.

Lemma coord_continuous {K : absRingType} m n i j :
  continuous (fun M : 'M[K]_(m, n) => M i j).
Proof.
move=> M A /= /(@locally_normP _ [normedModType K of K^o]) [_/posnumP[e] sA].
apply/locally_normP; exists e%:num => // N MN; apply/sA.
by have /bigmaxr_ltrP [_ MeN] := MN; have:= (MeN (i,j)); rewrite !mxE; apply.
Qed.

(** ** Pairs *)

Section prod_NormedModule.

Context {K : absRingType} {U V : normedModType K}.

Definition prod_norm (x : U * V) := maxr `|[x.1]| `|[x.2]|.

Lemma prod_norm_triangle x y : prod_norm (x + y) <= prod_norm x + prod_norm y.
Proof.
by rewrite ler_maxl /=; apply/andP; split;
  apply: ler_trans (ler_normm_add _ _) _; apply: ler_add;
  rewrite ler_maxr lerr // orbC.
Qed.

Lemma prod_norm_scal (l : K) (x : U * V) :
  prod_norm (l *: x) = abs l * prod_norm x.
Proof. by rewrite /prod_norm !normmZ maxr_pmulr. Qed.

Lemma entourage_prod_normE : entourage = entourage_ prod_norm.
Proof.
rewrite predeqE => A; split; last first.
  move=> [_/posnumP[e] sA]; exists ([set u | `|[u.1 - u.2]| < e%:num],
    [set v | `|[v.1 - v.2]| < e%:num]) => //=.
  move=> /= uv [uv1e uv2e]; exists ((uv.1.1, uv.2.1), (uv.1.2, uv.2.2)).
    by apply: sA; rewrite ltr_maxl uv1e uv2e.
  by rewrite /= -!surjective_pairing.
move=> [PQ []]; rewrite -!entourage_normE.
move=> [_/posnumP[eP] sP] [_/posnumP[eQ] sQ] sPQA.
exists (minr eP%:num eQ%:num) => // xy.
rewrite ltr_maxl !ltr_minr => /andP [/andP [xy1P xy1Q] /andP [xy2P xy2Q]].
have PQxy1 : PQ.1 (xy.1.1, xy.2.1) by apply: sP.
have /(conj PQxy1) : PQ.2 (xy.1.2, xy.2.2) by apply: sQ.
move=> /(sPQA ((xy.1.1, xy.2.1), (xy.1.2, xy.2.2))) [uv Auv].
move=> /eqP /andP [/andP [/= /eqP uvxy11 /eqP uvxy21] /andP
  [/= /eqP uvxy12 /eqP uvxy22]].
rewrite [xy]surjective_pairing [_.2]surjective_pairing [_.1]surjective_pairing.
by rewrite -uvxy11 -uvxy12 -uvxy21 -uvxy22 -!surjective_pairing.
Qed.

Lemma prod_norm_eq0 (x : U * V) : prod_norm x = 0 -> x = 0.
Proof.
case: x => [xu xv]; rewrite /prod_norm /= => nx0.
suff /andP [/eqP -> /eqP ->] : (xu == 0) && (xv == 0) by [].
rewrite -!normm_eq0 !eqr_le !normm_ge0.
have : maxr `|[xu]| `|[xv]| <= 0 by rewrite nx0 lerr.
by rewrite ler_maxl => /andP [-> ->].
Qed.

End prod_NormedModule.

Definition prod_NormedModule_mixin (K : absRingType) (U V : normedModType K) :=
  @NormedModMixin K _ _ _ (@prod_norm K U V) prod_norm_triangle
  prod_norm_scal entourage_prod_normE prod_norm_eq0.

Canonical prod_NormedModule (K : absRingType) (U V : normedModType K) :=
  NormedModType K (U * V) (@prod_NormedModule_mixin K U V).

Section NormedModule3.

Context {T : Type} {K : absRingType} {U : normedModType K}
                   {V : normedModType K}.

Lemma flim_norm2P {F : set (set U)} {G : set (set V)}
  {FF : Filter F} {FG : Filter G} (y : U) (z : V):
  (F, G) --> (y, z) <->
  forall eps : R, 0 < eps ->
   \forall y' \near F & z' \near G, `|[(y, z) - (y', z')]| < eps.
Proof. exact: flim_normP. Qed.

(* Lemma flim_norm_supP {F : set (set U)} {G : set (set V)} *)
(*   {FF : Filter F} {FG : Filter G} (y : U) (z : V): *)
(*   (F, G) --> (y, z) <-> *)
(*   forall eps : posreal, {near F & G, forall y' z', *)
(*           (`|[y - y']| < eps) /\ (`|[z - z']| < eps) }. *)
(* Proof. *)
(* rewrite flim_ballP; split => [] P eps. *)
(* - have [[A B] /=[FA GB] ABP] := P eps; exists (A, B) => -//[a b] [/= Aa Bb]. *)
(*   apply/andP; rewrite -ltr_maxl. *)
(*   have /= := (@sub_ball_norm_rev _ _ (_, _)). *)

Lemma flim_norm2 {F : set (set U)} {G : set (set V)}
  {FF : Filter F} {FG : Filter G} (y : U) (z : V):
  (F, G) --> (y, z) ->
  forall eps : R, 0 < eps ->
   \forall y' \near F & z' \near G, `|[(y, z) - (y', z')]| < eps.
Proof. by rewrite flim_normP. Qed.

Lemma flim_ball2P {F : set (set U)} {G : set (set V)}
  {FF : Filter F} {FG : Filter G} (y : U) (z : V):
  (F, G) --> (y, z) <->
  forall eps, eps > 0 -> \forall y' \near F & z' \near G,
                ball norm y eps y' /\ ball norm z eps z'.
Proof.
by rewrite flim_norm2P; split=> FGyz e /FGyz;
  apply: filter_app; apply: filterE => x; rewrite ltr_maxl;
  [move=> /andP[] | move=> [-> ->]].
Qed.

End NormedModule3.
Arguments flim_norm2 {_ _ _ F G FF FG}.

(** Normed vector spaces have some continuous functions *)

Section NVS_continuity.

Context {K : absRingType} {V : normedModType K}.

Lemma add_continuous : continuous (fun z : V * V => z.1 + z.2).
Proof.
move=> [/=x y]; apply/flim_normP=> _/posnumP[e].
rewrite !near_simpl /=; near=> a b => /=; rewrite opprD addrACA.
by rewrite normm_lt_split //; [near: a|near: b]; apply: flim_norm.
Grab Existential Variables. all: end_near. Qed.

Lemma scale_continuous : continuous (fun z : K * V => z.1 *: z.2).
Proof.
move=> [k x]; apply/flim_normP=> _/posnumP[e].
rewrite !near_simpl /=; near +oo => M; near=> l z => /=.
rewrite (@distm_lt_split _ _ (k *: z)) // -?(scalerBr, scalerBl) normmZ.
  rewrite (ler_lt_trans (ler_pmul _ _ (_ : _ <= `|k|%real + 1) (lerr _)))
          ?ler_addl //.
  rewrite -ltr_pdivl_mull // ?(ltr_le_trans ltr01) ?ler_addr //; near: z.
  by apply: flim_norm; rewrite // mulr_gt0 // ?invr_gt0 ltr_paddl.
have zM: `|[z]| < M by near: z; near: M; apply: flim_bounded; apply: flim_refl.
rewrite (ler_lt_trans (ler_pmul _ _ (lerr _) (_ : _ <= M))) // ?ltrW//.
by rewrite -ltr_pdivl_mulr //; near: l; apply: (flim_norm (_ : K^o)).
Grab Existential Variables. all: end_near. Qed.

Arguments scale_continuous _ _ : clear implicits.

Lemma scaler_continuous k : continuous (fun x : V => k *: x).
Proof.
by move=> x; apply: (flim_comp2 (flim_const _) flim_id (scale_continuous (_, _))).
Qed.

Lemma scalel_continuous (x : V) : continuous (fun k : K => k *: x).
Proof.
by move=> k; apply: (flim_comp2 flim_id (flim_const _) (scale_continuous (_, _))).
Qed.

Lemma opp_continuous : continuous (@GRing.opp V).
Proof.
move=> x; rewrite -scaleN1r => P /scaler_continuous /=.
rewrite !locally_nearE near_map.
by apply: filterS => x'; rewrite scaleN1r.
Qed.

End NVS_continuity.

Section limit_composition.

Context {K : absRingType} {V : normedModType K} {T : topologicalType}.

Lemma lim_cst (a : V) (F : set (set V)) {FF : Filter F} : (fun=> a) @ F --> a.
Proof. exact: cst_continuous. Qed.
Hint Resolve lim_cst.

Lemma lim_add (F : set (set T)) (FF : Filter F) (f g : T -> V) (a b : V) :
  f @ F --> a -> g @ F --> b -> (f \+ g) @ F --> a + b.
Proof. by move=> ??; apply: lim_cont2 => //; exact: add_continuous. Qed.

Lemma continuousD (f g : T -> V) x :
  {for x, continuous f} -> {for x, continuous g} ->
  {for x, continuous (fun x => f x + g x)}.
Proof. by move=> ??; apply: lim_add. Qed.

Lemma lim_scale (F : set (set T)) (FF : Filter F) (f : T -> K) (g : T -> V)
  (k : K) (a : V) :
  f @ F --> k -> g @ F --> a -> (fun x => (f x) *: (g x)) @ F --> k *: a.
Proof. by move=> ??; apply: lim_cont2 => //; exact: scale_continuous. Qed.

Lemma lim_scalel (F : set (set T)) (FF : Filter F) (f : T -> K) (a : V) (k : K) :
  f @ F --> k -> (fun x => (f x) *: a) @ F --> k *: a.
Proof. by move=> ?; apply: lim_scale => //; exact: cst_continuous. Qed.

Lemma lim_scaler (F : set (set T)) (FF : Filter F) (f : T -> V) (k : K) (a : V) :
  f @ F --> a -> k \*: f  @ F --> k *: a.
Proof. by apply: lim_scale => //; exact: cst_continuous. Qed.

Lemma continuousZ (f : T -> V) k x :
  {for x, continuous f} -> {for x, continuous (k \*: f)}.
Proof. by move=> ?; apply: lim_scaler. Qed.

Lemma continuousZl (k : T -> K) (f : V) x :
  {for x, continuous k} -> {for x, continuous (fun z => k z *: f)}.
Proof. by move=> ?; apply: lim_scalel. Qed.

Lemma lim_opp (F : set (set T)) (FF : Filter F) (f : T -> V) (a : V) :
  f @ F --> a -> (fun x => - f x) @ F --> - a.
Proof. by move=> ?; apply: lim_cont => //; apply: opp_continuous. Qed.

Lemma continuousN (f : T -> V) x :
  {for x, continuous f} -> {for x, continuous (fun x => - f x)}.
Proof. by move=> ?; apply: lim_opp. Qed.

Lemma lim_mult (x y : K) : z.1 * z.2 @[z --> (x, y)] --> x * y.
Proof. exact: (@scale_continuous _ (AbsRing_NormedModType K)). Qed.

Lemma continuousM (f g : T -> K) x :
  {for x, continuous f} -> {for x, continuous g} ->
  {for x, continuous (fun x => f x * g x)}.
Proof. by move=> fc gc; apply: flim_comp2 fc gc _; apply: lim_mult. Qed.

(** Continuity of norm *)

Lemma continuous_norm : continuous (@norm _ V).
Proof.
move=> x A /= /(@locally_normP _ [normedModType R of R^o]) [_/posnumP[e] sA].
apply/locally_normP; exists e%:num => // ??; apply/sA.
exact: ler_lt_trans (ler_distm_dist _ _) _.
Qed.

(* :TODO: yet, not used anywhere?! *)
Lemma flim_norm0 {U} {F : set (set U)} {FF : Filter F} (f : U -> V) :
  (fun x => `|[f x]|) @ F --> (0 : R)
  -> f @ F --> (0 : V).
Proof.
move=> /(@flim_norm _ [normedModType R of R^o]) fx0.
apply/flim_normP => e egt0.
rewrite near_simpl; have := fx0 _ egt0; rewrite near_simpl.
by apply: filterS => x; rewrite !sub0r !normmN [ `|[_]| ]ger0_norm.
Qed.

(* TODO: simplify using extremumP when PR merged in mathcomp *)
Lemma cvg_seq_bounded (a : nat -> V) :
  [cvg a in V] -> {M : R | forall n, norm (a n) <= M}.
Proof.
move=> a_cvg; suff: exists M, forall n, norm (a n) <= M.
  by move=> /getPex; set M := get _; exists M.
near +oo => M.
have [//|N _ /(_ _ _) /ltrW a_leM] := !! near (flim_bounded _ a_cvg) M.
exists (maxr M (\big[maxr/M]_(n < N) `|[a (val (rev_ord n))]|)) => /= n.
rewrite ler_maxr; have [nN|nN] := leqP N n; first by rewrite a_leM.
apply/orP; right => {a_leM}; elim: N n nN=> //= N IHN n.
rewrite leq_eqVlt => /orP[/eqP[->] |/IHN a_le];
by rewrite big_ord_recl subn1 /= ler_maxr ?a_le ?lerr ?orbT.
Grab Existential Variables. all: end_near. Qed.

End limit_composition.

(** ** Complete Normed Modules *)

Section Cauchy.

Context {K : absRingType} {V : normedModType K}.

Definition cauchy_ball (F : set (set V)) :=
  forall e, e > 0 -> \forall x & y \near F, ball norm x e y.

Lemma cauchy_cauchy_ball (F : set (set V)) : cauchy F -> cauchy_ball F.
Proof. by move=> Fc _/posnumP[e]; apply: Fc (entourage_ball e). Qed.

Lemma cauchy_ballP (F : set (set V)) : Filter F -> cauchy_ball F <-> cauchy F.
Proof.
move=> FF; split=> [Fc A|/cauchy_cauchy_ball] //.
by rewrite -entourage_normE => -[_/posnumP[e] sA]; apply: filterS sA (Fc _ _).
Qed.

Definition cauchy_ex (F : set (set V)) :=
  forall eps, 0 < eps -> exists x, F (ball norm x eps).

Lemma cvg_cauchy_ex (F : set (set V)) : [cvg F in V] -> cauchy_ex F.
Proof. by move=> Fl _/posnumP[e]; exists (lim F); apply/Fl/locally_ball. Qed.

Lemma cauchy_exP (F : set (set V)) : Filter F -> cauchy_ex F -> cauchy F.
Proof.
move=> FF Fc A; rewrite -entourage_normE => -[_/posnumP[e] sA].
have /Fc [z /= Fze] := [gt0 of e%:num / 2]; near=> x y; apply: sA => /=.
by apply: (@distm_lt_splitr _ _ z); [near: x|near: y].
Grab Existential Variables. all: end_near. Qed.

Lemma cauchyP (F : set (set V)) : ProperFilter F -> cauchy F <-> cauchy_ex F.
Proof.
move=> FF; split=> [Fcauchy _/posnumP[e] |/cauchy_exP//].
near F => x; exists x; near: x; apply: (@nearP_dep _ _ F F); apply: Fcauchy.
exact: entourage_ball.
Grab Existential Variables. all: end_near. Qed.

End Cauchy.

Module CompleteNormedModule.

Section ClassDef.

Variable K : absRingType.

Record class_of (T : Type) := Class {
  base : NormedModule.class_of K T ;
  mixin : Complete.axiom (Uniform.Pack base T)
}.
Local Coercion base : class_of >-> NormedModule.class_of.
Definition base2 T (cT : class_of T) : Complete.class_of T :=
  @Complete.Class _ (@base T cT) (@mixin T cT).
Local Coercion base2 : class_of >-> Complete.class_of.

Structure type (phK : phant K) := Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (phK : phant K) (cT : type phK) (T : Type).

Definition class := let: Pack _ c _ := cT return class_of cT in c.

Definition pack :=
  fun bT b & phant_id (@NormedModule.class K phK bT) (b : NormedModule.class_of K T) =>
  fun mT m & phant_id (@Complete.class mT) (@Complete.Class T b m) =>
    Pack phK (@Class T b m) T.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition zmodType := @GRing.Zmodule.Pack cT xclass xT.
Definition lmodType := @GRing.Lmodule.Pack K phK cT xclass xT.
Definition pointedType := @Pointed.Pack cT xclass xT.
Definition filteredType := @Filtered.Pack cT cT xclass xT.
Definition topologicalType := @Topological.Pack cT xclass xT.
Definition uniformType := @Uniform.Pack cT xclass xT.
Definition completeType := @Complete.Pack cT xclass xT.
Definition join_zmodType := @GRing.Zmodule.Pack uniformType xclass xT.
Definition join_lmodType := @GRing.Lmodule.Pack K phK uniformType xclass xT.
Definition normedModType := @NormedModule.Pack K phK cT xclass xT.
Definition join_uniformType := @Uniform.Pack normedModType xclass xT.
End ClassDef.

Module Exports.

Coercion base : class_of >-> NormedModule.class_of.
Coercion base2 : class_of >-> Complete.class_of.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> GRing.Zmodule.type.
Canonical zmodType.
Coercion lmodType : type >-> GRing.Lmodule.type.
Canonical lmodType.
Coercion pointedType : type >-> Pointed.type.
Canonical pointedType.
Coercion filteredType : type >-> Filtered.type.
Canonical filteredType.
Coercion topologicalType : type >-> Topological.type.
Canonical topologicalType.
Coercion uniformType : type >-> Uniform.type.
Canonical uniformType.
Canonical join_zmodType.
Canonical join_lmodType.
Coercion completeType : type >-> Complete.type.
Canonical completeType.
Coercion normedModType : type >-> NormedModule.type.
Canonical normedModType.
Canonical join_uniformType.
Notation completeNormedModType K := (type (Phant K)).
Notation "[ 'completeNormedModType' K 'of' T ]" := (@pack _ (Phant K) T _ _ id _ _ id)
  (at level 0, format "[ 'completeNormedModType'  K  'of'  T ]") : form_scope.

End Exports.

End CompleteNormedModule.

Export CompleteNormedModule.Exports.

(** * Extended Types *)

(** * The topology on real numbers *)

(* :TODO: add to mathcomp *)
Lemma ltr_distW (R : realDomainType) (x y e : R):
   (`|x - y|%R < e) -> y - e < x.
Proof. by rewrite ltr_distl => /andP[]. Qed.

(* :TODO: add to mathcomp *)
Lemma ler_distW (R : realDomainType) (x y e : R):
   (`|x - y|%R <= e) -> y - e <= x.
Proof. by rewrite ler_distl => /andP[]. Qed.

Lemma R_complete (F : set (set R)) : ProperFilter F -> cauchy F -> cvg F.
Proof.
move=> FF Fc; apply/cvg_ex.
pose D := \bigcap_(A in F) (down (mem A)).
have /Fc := @entourage_ball _ [normedModType R of R^o] 1%:pos.
rewrite near_simpl -near2_pair => /nearP_dep /filter_ex /= [x0 x01].
have D_has_sup : has_sup (mem D); first split.
- exists (x0 - 1); rewrite in_setE => A FA.
  apply/existsbP; near F => x; first exists x.
    by rewrite ler_distW 1?distrC 1?ltrW ?andbT ?in_setE //; near: x.
- exists (x0 + 1); apply/forallbP => x; apply/implyP; rewrite in_setE.
  move=> /(_ _ x01) /existsbP [y /andP[]]; rewrite in_setE.
  by rewrite ltr_distl ltr_subl_addr=> /andP[/ltrW] /(ler_trans _) yx01 _ /yx01.
exists (sup (mem D)); apply: (@flim_normW _ [normedModType R of R^o]).
move=> _/posnumP[eps]; near=> x.
rewrite ler_distl sup_upper_bound //=.
  apply: sup_le_ub => //; first by case: D_has_sup.
  apply/forallbP => y; apply/implyP; rewrite in_setE.
  move=> /(_ (ball norm x eps%:num) _) /existsbP [].
    near: x; apply: nearP_dep; apply: Fc.
    exact: (@entourage_ball _ [normedModType R of R^o]).
  move=> z /andP[]; rewrite in_setE /ball ltr_distl ltr_subl_addr.
  by move=> /andP [/ltrW /(ler_trans _) le_xeps _ /le_xeps].
rewrite in_setE /D /= => A FA; near F => y.
apply/existsbP; exists y; apply/andP; split.
  by rewrite in_setE; near: y.
rewrite ler_subl_addl -ler_subl_addr ltrW //.
suff: `|x - y| < eps%:num by rewrite ltr_norml => /andP[_].
near: y; near: x; apply: nearP_dep; apply: Fc.
exact: (@entourage_ball _ [normedModType R of R^o]).
Grab Existential Variables. all: end_near. Qed.

Canonical R_completeType := CompleteType R R_complete.
Canonical R_NormedModule := [normedModType R of R^o].
Canonical R_CompleteNormedModule := [completeNormedModType R of R^o].

Definition at_left x := within (fun u : R => u < x) (locally x).
Definition at_right x := within (fun u : R => x < u) (locally x).
(* :TODO: We should have filter notation ^- and ^+ for these *)

Global Instance at_right_proper_filter (x : R) : ProperFilter (at_right x).
Proof.
apply: Build_ProperFilter'.
rewrite /at_right -(@filter_from_norm_locally _ [normedModType R of R^o]).
move=> [_/posnumP[e] /(_ (x + e%:num / 2))]; apply; last by rewrite ltr_addl.
rewrite /= opprD addrA subrr add0r [ `|[_]|]normrN normf_div !ger0_norm //.
by rewrite ltr_pdivr_mulr // ltr_pmulr // (_ : 1 = 1%:R) // ltr_nat.
Qed.

Global Instance at_left_proper_filter (x : R) : ProperFilter (at_left x).
Proof.
apply: Build_ProperFilter' => -[A [_/posnumP[d] sA]] /(_ (x - d%:num / 2)).
apply; last by rewrite ltr_subl_addl ltr_addr.
apply: sA; rewrite opprD !addrA subrr add0r opprK absRE normf_div !ger0_norm //.
by rewrite ltr_pdivr_mulr // ltr_pmulr // (_ : 1 = 1%:R) // ltr_nat.
Qed.
Typeclasses Opaque at_left at_right.

(** Some open sets of [R] *)

Lemma open_lt (y : R) : open (< y).
Proof.
rewrite openE => x /= ltxy; apply/(@locally_normP _ [normedModType R of R^o]).
exists (y - x); first by rewrite subr_gt0.
by move=> ?; rewrite /= normmB ltr_distl addrCA subrr addr0 => /andP[].
Qed.
Hint Resolve open_lt.

Lemma open_gt (y : R) : open (> y).
Proof.
rewrite openE => x /= gtxy; apply/(@locally_normP _ [normedModType R of R^o]).
exists (x - y); first by rewrite subr_gt0.
by move=> ?; rewrite /= normmB ltr_distl opprB addrCA subrr addr0 => /andP[].
Qed.
Hint Resolve open_gt.

Lemma open_neq (y : R) : open (xpredC (eq_op^~ y)).
Proof.
rewrite (_ : xpredC _ = (< y) `|` (> y) :> set _) /=.
  by apply: openU => //; apply: open_lt.
rewrite predeqE => x /=; rewrite eqr_le !lerNgt negb_and !negbK orbC.
by symmetry; apply (rwP orP).
Qed.

(** Some closed sets of [R] *)

Lemma closed_le (y : R) : closed (<= y).
Proof.
rewrite (_ : (<= _) = ~` (> y) :> set _).
  by apply: closedC; exact: open_gt.
by rewrite predeqE => x /=; rewrite lerNgt; split => /negP.
Qed.

Lemma closed_ge (y : R) : closed (>= y).
Proof.
rewrite (_ : (>= _) = ~` (< y) :> set _).
  by apply: closedC; exact: open_lt.
by rewrite predeqE => x /=; rewrite lerNgt; split => /negP.
Qed.

Lemma closed_eq (y : R) : closed (eq^~ y).
Proof.
rewrite [X in closed X](_ : (eq^~ _) = ~` (xpredC (eq_op^~ y))).
  by apply: closedC; exact: open_neq.
by rewrite predeqE /setC => x /=; rewrite (rwP eqP); case: eqP; split.
Qed.

(** properties of segments in [R] *)

Lemma segment_connected (a b : R) : connected [set x | x \in `[a, b]].
Proof.
move=> A [y Ay] Aop Acl.
move: Aop; apply: contrapTT; rewrite predeqE => /asboolPn /existsp_asboolPn [x].
wlog ltyx : a b (* leab *) A y Ay Acl x / y < x.
  move=> scon; case: (ltrP y x); first exact: scon.
  rewrite ler_eqVlt; case/orP=> [/eqP xey|ltxy].
    move: Acl => [B Bcl AeabB].
    have sAab : A `<=` [set x | x \in `[a, b]] by rewrite AeabB => ? [].
    move=> /asboolPn; rewrite asbool_and=> /nandP [/asboolPn /(_ (sAab _))|] //.
    by move=> /imply_asboolPn [abx nAx] [C Cop AeabC]; apply: nAx; rewrite xey.
  move=> Axneabx [C Cop AeabC].
  have setIN B : A = [set x | x \in `[a, b]] `&` B ->
    [set - x | x in A] = [set x | x \in `[(- b), (- a)]] `&` [set - x | x in B].
    move=> AeabB; rewrite predeqE => z; split.
      move=> [t At]; have := At; rewrite AeabB => - [abt Bt] <-.
      by split; [rewrite oppr_itvcc !opprK|exists t].
    move=> [abz [t Bt tez]]; exists t => //; rewrite AeabB; split=> //.
    by rewrite -[t]opprK tez oppr_itvcc.
  apply: (scon (- b) (- a) (* _ *) [set - x | x in A] (- y)) (- x) _ _ _.
  - by exists y.
  - move: Acl => [B Bcl AeabB]; exists [set - x | x in B]; first exact: closedN.
    exact: setIN.
  - by rewrite ltr_oppr opprK.
  - move=> Axeabx; apply: Axneabx; split=> [|abx].
      by rewrite AeabC => - [].
    have /Axeabx [z Az zex] : - x \in `[(- b), (- a)].
      by rewrite oppr_itvcc !opprK.
    by rewrite -[x]opprK -zex opprK.
  - by exists [set - x | x in C]; [apply: openN|apply: setIN].
move: Acl => [B Bcl AeabB].
have sAab : A `<=` [set x | x \in `[a, b]] by rewrite AeabB => ? [].
move=> /asboolPn; rewrite asbool_and => /nandP [/asboolPn /(_ (sAab _))|] //.
move=> /imply_asboolPn [abx nAx] [C Cop AeabC].
set Altx := fun y => y \in A `&` (< x).
have Altxn0 : reals.nonempty Altx by exists y; rewrite in_setE.
have xub_Altx : x \in ub Altx.
  by apply/ubP => ?; rewrite in_setE => - [_ /ltrW].
have Altxsup : has_sup Altx by apply/has_supP; split=> //; exists x.
set z := sup Altx.
have yxz : z \in `[y, x].
  rewrite inE; apply/andP; split; last exact: sup_le_ub.
  by apply/sup_upper_bound => //; rewrite in_setE.
have Az : A z.
  rewrite AeabB; split.
    suff : {subset `[y, x] <= `[a, b]} by apply.
    by apply/subitvP; rewrite /= (itvP abx); have /sAab/itvP-> := Ay.
  apply: Bcl => D /(@locally_normP _ [normedModType R of R^o])
    [_ /posnumP[e] ze_D].
  have [t] := sup_adherent Altxsup [gt0 of e%:num].
  rewrite in_setE => - [At lttx] ltzet.
  exists t; split; first by move: At; rewrite AeabB => - [].
  apply/ze_D; rewrite /ball /= ltr_distl.
  apply/andP; split; last by rewrite -ltr_subl_addr.
  rewrite ltr_subl_addr; apply: ltr_spaddr => //.
  by apply/sup_upper_bound => //; rewrite in_setE.
have ltzx : 0 < x - z.
  have : z <= x by rewrite (itvP yxz).
  by rewrite subr_gt0 ler_eqVlt => /orP [/eqP zex|] //; move: nAx; rewrite -zex.
have := Az; rewrite AeabC => - [_ /Cop /(@locally_normP _
  [normedModType R of R^o]) [_ /posnumP[e] ze_C]].
suff [t Altxt] : exists2 t, Altx t & z < t.
  by rewrite ltrNge => /negP; apply; apply/sup_upper_bound.
exists (z + (minr (e%:num / 2) ((PosNum ltzx)%:num / 2))); last first.
  by rewrite ltr_addl.
rewrite in_setE; split; last first.
  rewrite -[(< _) _]ltr_subr_addl ltr_minl; apply/orP; right.
  by rewrite ltr_pdivr_mulr // mulrDr mulr1 ltr_addl.
rewrite AeabC; split; last first.
  apply: ze_C; rewrite /ball ltr_distl.
  apply/andP; split; last by rewrite -addrA ltr_addl.
  rewrite -addrA gtr_addl subr_lt0 ltr_minl; apply/orP; left.
  by rewrite [X in _ < X]splitr ltr_addl.
rewrite inE; apply/andP; split.
  by apply: ler_paddr => //; have := Az; rewrite AeabB => - [/itvP->].
have : x <= b by rewrite (itvP abx).
apply: ler_trans; rewrite -ler_subr_addl ler_minl; apply/orP; right.
by rewrite ler_pdivr_mulr // mulrDr mulr1 ler_addl; apply: ltrW.
Qed.

Lemma segment_closed (a b : R) : closed [set x | x \in `[a, b]].
Proof.
have -> : [set x | x \in `[a, b]] = (>= a) `&` (<= b).
  by rewrite predeqE => ?; rewrite inE; split=> [/andP [] | /= [->]].
exact: closedI (@closed_ge _) (@closed_le _).
Qed.

Lemma segment_compact (a b : R) : compact [set x | x \in `[a, b]].
Proof.
case: (lerP a b) => [leab|ltba]; last first.
  by move=> F FF /filter_ex [x abx]; move: ltba; rewrite (itvP abx).
rewrite compact_cover => I D f fop sabUf.
set B := [set x | exists2 D' : {fset I}, {subset D' <= D} &
  [set y | y \in `[a, x]] `<=` \bigcup_(i in [set i | i \in D']) f i /\
  (\bigcup_(i in [set i | i \in D']) f i) x].
set A := [set x | x \in `[a, b]] `&` B.
suff Aeab : A = [set x | x \in `[a, b]].
  suff [_ [D' ? []]] : A b by exists D'.
  by rewrite Aeab inE; apply/andP.
apply: segment_connected.
- have aba : a \in `[a, b] by rewrite inE; apply/andP.
  exists a; split=> //; have /sabUf [i Di fia] := aba.
  exists [fset i]%fset; first by move=> ?; rewrite inE in_setE => /eqP->.
  split; last by exists i => //; rewrite inE.
  move=> x aex; exists i; [by rewrite inE|suff /eqP-> : x == a by []].
  by rewrite eqr_le !(itvP aex).
- exists B => //; rewrite openE => x [D' sD [saxUf [i Di fx]]].
  have : open (f i) by have /sD := Di; rewrite in_setE => /fop.
  rewrite openE => /(_ _ fx); rewrite !/(_^°) -!(@filter_from_norm_locally _
    [normedModType R of R^o]).
  move=> [e egt0 xe_fi]; exists e => // y xe_y.
  exists D' => //; split; last by exists i => //; apply/xe_fi.
  move=> z ayz; case: (lerP z x) => [lezx|ltxz].
    by apply/saxUf; rewrite inE (itvP ayz) lezx.
  exists i=> //; apply/xe_fi; rewrite /ball normmB [ `|[_]|]ger0_norm.
    have lezy : z <= y by rewrite (itvP ayz).
    rewrite ltr_subl_addl; apply: ler_lt_trans lezy _; rewrite -ltr_subl_addr.
    by have := xe_y; rewrite /ball => /ltr_distW.
  by rewrite subr_ge0; apply/ltrW.
exists A; last by rewrite predeqE => x; split=> [[] | []].
move=> x clAx; have abx : x \in `[a, b].
  by apply: segment_closed; have /closureI [] := clAx.
split=> //; have /sabUf [i Di fx] := abx.
have /fop := Di; rewrite openE => /(_ _ fx).
rewrite /(_^°) -(@filter_from_norm_locally _ [normedModType R of R^o]).
move=> [_ /posnumP[e] xe_fi].
have /clAx [y [[aby [D' sD [sayUf _]]] xe_y]] := locally_ball (x : R^o) e.
exists (i |` D')%fset; first by move=> j /fset1UP[->|/sD] //; rewrite in_setE.
split=> [z axz|]; last first.
  exists i; first by rewrite !inE eq_refl.
  exact/xe_fi/ball_center.
case: (lerP z y) => [lezy|ltyz].
  have /sayUf [j Dj fjz] : z \in `[a, y] by rewrite inE (itvP axz) lezy.
  by exists j => //; rewrite inE orbC Dj.
exists i; first by rewrite !inE eq_refl.
apply/xe_fi; rewrite /ball [ `|[_]|]ger0_norm; last first.
  by rewrite subr_ge0 (itvP axz).
rewrite ltr_subl_addl -ltr_subl_addr; apply: ltr_trans ltyz.
by apply: ltr_distW; rewrite distrC.
Qed.

Lemma ler0_addgt0P (R : realFieldType) (x : R) :
  reflect (forall e, e > 0 -> x <= e) (x <= 0).
Proof.
apply: (iffP idP) => [lex0 e egt0|lex0].
  by apply: ler_trans lex0 _; apply: ltrW.
case: (lerP x 0) => // lt0x.
have /midf_lt [_] := lt0x; rewrite ltrNge -eqbF_neg => /eqP<-.
by rewrite add0r; apply: lex0; rewrite -[x]/((PosNum lt0x)%:num).
Qed.

Lemma IVT (f : R -> R) (a b v : R) :
  a <= b -> {in `[a, b], continuous f} ->
  minr (f a) (f b) <= v <= maxr (f a) (f b) ->
  exists2 c, c \in `[a, b] & f c = v.
Proof.
move=> leab; wlog : f v / f a <= f b.
  move=> ivt; case: (lerP (f a) (f b)) => [|/ltrW lefba].
    exact: ivt.
  move=> fcont fabv; have [] := ivt (fun x => - f x) (- v).
  - by rewrite ler_oppr opprK.
  - by move=> x /fcont; apply: (@continuousN _ [normedModType R of R^o]).
  - by rewrite -oppr_max -oppr_min ler_oppr opprK ler_oppr opprK andbC.
  by move=> c cab /eqP; rewrite eqr_opp => /eqP; exists c.
move=> lefab fcont; rewrite minr_l // maxr_r // => /andP [].
rewrite ler_eqVlt => /orP [/eqP<- _|ltfav].
  by exists a => //; rewrite inE lerr leab.
rewrite ler_eqVlt => /orP [/eqP->|ltvfb].
  by exists b => //; rewrite inE lerr leab.
set A := [pred c | (c <= b) && (f c <= v)].
have An0 : reals.nonempty A by exists a; apply/andP; split=> //; apply: ltrW.
have supA : has_sup A.
  by apply/has_supP; split=> //; exists b; apply/ubP => ? /andP [].
have supAab : sup A \in `[a, b].
  rewrite inE; apply/andP; split; last first.
    by apply: sup_le_ub => //; apply/ubP => ? /andP [].
  by apply: sup_upper_bound => //; rewrite inE leab andTb ltrW.
exists (sup A) => //; have lefsupv : f (sup A) <= v.
  rewrite lerNgt; apply/negP => ltvfsup.
  have vltfsup : 0 < f (sup A) - v by rewrite subr_gt0.
  have /fcont /(_ _ (@locally_ball _ [normedModType R of R^o] _
    (PosNum vltfsup))) := supAab.
  rewrite locally_simpl => /= /(@locally_normP _ [normedModType R of R^o])
    [_/posnumP[d] supdfe].
  have [t At supd_t] := sup_adherent supA [gt0 of d%:num].
  suff /supdfe : ball norm (sup A : R^o) d%:num t.
    rewrite ltr_norml => /andP [_].
    by rewrite ltr_add2l ltr_oppr opprK ltrNge; have /andP [_ ->] := At.
  rewrite /ball [ `|[_]|]ger0_norm.
    by rewrite ltr_subl_addr -ltr_subl_addl.
  by rewrite subr_ge0 sup_upper_bound.
apply/eqP; rewrite eqr_le; apply/andP; split=> //.
rewrite -subr_le0; apply/ler0_addgt0P => _/posnumP[e].
rewrite ler_subl_addr -ler_subl_addl ltrW //.
have /fcont /(_ _ (@locally_ball _ [normedModType R of R^o] _ e)) := supAab.
rewrite locally_simpl /= => /(@locally_normP _ [normedModType R of R^o]).
move=> [_/posnumP[d] supdfe].
have atrF := at_right_proper_filter (sup A); near (at_right (sup A)) => x.
have /supdfe /= : ball norm (sup A : R^o) d%:num x.
  by near: x; apply/(@locally_normP _ [normedModType R of R^o]); exists d%:num.
move/ltr_distW; apply: ler_lt_trans.
rewrite ler_add2r ltrW //; suff : forall t, t \in `](sup A), b] -> v < f t.
  apply; rewrite inE; apply/andP; split.
    by near: x; apply/(@locally_normP _ [normedModType R of R^o]); exists 1.
  near:x; apply/(@locally_normP _ [normedModType R of R^o]); exists (b - sup A).
    rewrite subr_gt0 ltr_def (itvP supAab) andbT; apply/negP => /eqP besup.
    by move: lefsupv; rewrite lerNgt -besup ltvfb.
  move=> t lttb ltsupt; move: lttb; rewrite /ball normmB.
  by rewrite [ `|[_]|]gtr0_norm ?subr_gt0 // ltr_add2r; apply: ltrW.
move=> t /andP [ltsupt letb]; rewrite ltrNge; apply/negP => leftv.
move: ltsupt; rewrite ltrNge => /negP; apply; apply: sup_upper_bound => //.
by rewrite inE letb leftv.
Grab Existential Variables. all: end_near. Qed.

(** Local properties in [R] *)

Lemma locally_interval (P : R -> Prop) (x : R) (a b : Rbar) :
  Rbar_lt a x -> Rbar_lt x b ->
  (forall (y : R), Rbar_lt a y -> Rbar_lt y b -> P y) ->
  locally x P.
Proof.
move => Hax Hxb Hp; case: (Rbar_lt_locally _ _ _ Hax Hxb) => d Hd.
apply/(@locally_normP _ [normedModType R of R^o]); exists d%:num => //= y.
by rewrite /ball normmB => /Hd /andP[??]; apply: Hp.
Qed.

(** * Topology on [R]² *)

(* Lemma locally_2d_align : *)
(*   forall (P Q : R -> R -> Prop) x y, *)
(*   ( forall eps : posreal, (forall uv, ball (x, y) eps uv -> P uv.1 uv.2) -> *)
(*     forall uv, ball (x, y) eps uv -> Q uv.1 uv.2 ) -> *)
(*   {near x & y, forall x y, P x y} ->  *)
(*   {near x & y, forall x y, Q x y}. *)
(* Proof. *)
(* move=> P Q x y /= K => /locallyP [d _ H]. *)
(* apply/locallyP; exists d => // uv Huv. *)
(* by apply (K d) => //. *)
(* Qed. *)

(* Lemma locally_2d_1d_const_x : *)
(*   forall (P : R -> R -> Prop) x y, *)
(*   locally_2d x y P -> *)
(*   locally y (fun t => P x t). *)
(* Proof. *)
(* move=> P x y /locallyP [d _ Hd]. *)
(* exists d => // z Hz. *)
(* by apply (Hd (x, z)). *)
(* Qed. *)

(* Lemma locally_2d_1d_const_y : *)
(*   forall (P : R -> R -> Prop) x y, *)
(*   locally_2d x y P -> *)
(*   locally x (fun t => P t y). *)
(* Proof. *)
(* move=> P x y /locallyP [d _ Hd]. *)
(* apply/locallyP; exists d => // z Hz. *)
(* by apply (Hd (z, y)). *)
(* Qed. *)

(* Lemma locally_2d_1d_strong (P : R -> R -> Prop) (x y : R): *)
(*   (\near x & y, P x y) -> *)
(*   \forall u \near x & v \near y, *)
(*       forall (t : R), 0 <= t <= 1 -> *)
(*       \forall z \near t, \forall a \near (x + z * (u - x)) *)
(*                                & b \near (y + z * (v - y)), P a b. *)
(* Proof. *)
(* move=> P x y. *)
(* apply locally_2d_align => eps HP uv Huv t Ht. *)
(* set u := uv.1. set v := uv.2. *)
(* have Zm : 0 <= Num.max `|u - x| `|v - y| by rewrite ler_maxr 2!normr_ge0. *)
(* rewrite ler_eqVlt in Zm. *)
(* case/orP : Zm => Zm. *)
(* - apply filterE => z. *)
(*   apply/locallyP. *)
(*   exists eps => // pq. *)
(*   rewrite !(RminusE,RmultE,RplusE). *)
(*   move: (Zm). *)
(*   have : Num.max `|u - x| `|v - y| <= 0 by rewrite -(eqP Zm). *)
(*   rewrite ler_maxl => /andP[H1 H2] _. *)
(*   rewrite (_ : u - x = 0); last by apply/eqP; rewrite -normr_le0. *)
(*   rewrite (_ : v - y = 0); last by apply/eqP; rewrite -normr_le0. *)
(*   rewrite !(mulr0,addr0); by apply HP. *)
(* - have : Num.max (`|u - x|) (`|v - y|) < eps. *)
(*     rewrite ltr_maxl; apply/andP; split. *)
(*     - case: Huv => /sub_ball_abs /=; by rewrite mul1r absrB. *)
(*     - case: Huv => _ /sub_ball_abs /=; by rewrite mul1r absrB. *)
(*   rewrite -subr_gt0 => /RltP H1. *)
(*   set d1 := mkposreal _ H1. *)
(*   have /RltP H2 : 0 < pos d1 / 2 / Num.max `|u - x| `|v - y| *)
(*     by rewrite mulr_gt0 // invr_gt0. *)
(*   set d2 := mkposreal _ H2. *)
(*   exists d2 => // z Hz. *)
(*   apply/locallyP. *)
(*   exists [posreal of d1 / 2] => //= pq Hpq. *)
(*   set p := pq.1. set q := pq.2. *)
(*   apply HP; split. *)
(*   + apply/sub_abs_ball => /=. *)
(*     rewrite absrB. *)
(*     rewrite (_ : p - x = p - (x + z * (u - x)) + (z - t + t) * (u - x)); last first. *)
(*       by rewrite subrK opprD addrA subrK. *)
(*     apply: (ler_lt_trans (ler_abs_add _ _)). *)
(*     rewrite (_ : pos eps = pos d1 / 2 + (pos eps - pos d1 / 2)); last first. *)
(*       by rewrite addrCA subrr addr0. *)
(*     rewrite (_ : pos eps - _ = d1) // in Hpq. *)
(*     case: Hpq => /sub_ball_abs Hp /sub_ball_abs Hq. *)
(*     rewrite mul1r /= (_ : pos eps - _ = d1) // !(RminusE,RplusE,RmultE,RdivE) // in Hp, Hq. *)
(*     rewrite absrB in Hp. rewrite absrB in Hq. *)
(*     rewrite (ltr_le_add Hp) // (ler_trans (absrM _ _)) //. *)
(*     apply (@ler_trans _ ((pos d2 + 1) * Num.max `|u - x| `|v - y|)). *)
(*     apply ler_pmul; [by rewrite normr_ge0 | by rewrite normr_ge0 | | ]. *)
(*     rewrite (ler_trans (ler_abs_add _ _)) // ler_add //. *)
(*     move/sub_ball_abs : Hz; rewrite mul1r => tzd2; by rewrite absrB ltrW. *)
(*     rewrite absRE ger0_norm //; by case/andP: Ht. *)
(*     by rewrite ler_maxr lerr. *)
(*     rewrite /d2 /d1 /=. *)
(*     set n := Num.max _ _. *)
(*     rewrite mulrDl mul1r -mulrA mulVr ?unitfE ?lt0r_neq0 // mulr1. *)
(*     rewrite ler_sub_addr addrAC -mulrDl -mulr2n -mulr_natr. *)
(*     by rewrite -mulrA mulrV ?mulr1 ?unitfE // subrK. *)
(*   + apply/sub_abs_ball => /=. *)
(*     rewrite absrB. *)
(*     rewrite (_ : (q - y) = (q - (y + z * (v - y)) + (z - t + t) * (v - y))); last first. *)
(*       by rewrite subrK opprD addrA subrK. *)
(*     apply: (ler_lt_trans (ler_abs_add _ _)). *)
(*     rewrite (_ : pos eps = pos d1 / 2 + (pos eps - pos d1 / 2)); last first. *)
(*       by rewrite addrCA subrr addr0. *)
(*     rewrite (_ : pos eps - _ = d1) // in Hpq. *)
(*     case: Hpq => /sub_ball_abs Hp /sub_ball_abs Hq. *)
(*     rewrite mul1r /= (_ : pos eps - _ = d1) // !(RminusE,RplusE,RmultE,RdivE) // in Hp, Hq. *)
(*     rewrite absrB in Hp. rewrite absrB in Hq. *)
(*     rewrite (ltr_le_add Hq) // (ler_trans (absrM _ _)) //. *)
(*     rewrite (@ler_trans _ ((pos d2 + 1) * Num.max `|u - x| `|v - y|)) //. *)
(*     apply ler_pmul; [by rewrite normr_ge0 | by rewrite normr_ge0 | | ]. *)
(*     rewrite (ler_trans (ler_abs_add _ _)) // ler_add //. *)
(*     move/sub_ball_abs : Hz; rewrite mul1r => tzd2; by rewrite absrB ltrW. *)
(*     rewrite absRE ger0_norm //; by case/andP: Ht. *)
(*     by rewrite ler_maxr lerr orbT. *)
(*     rewrite /d2 /d1 /=. *)
(*     set n := Num.max _ _. *)
(*     rewrite mulrDl mul1r -mulrA mulVr ?unitfE ?lt0r_neq0 // mulr1. *)
(*     rewrite ler_sub_addr addrAC -mulrDl -mulr2n -mulr_natr. *)
(*     by rewrite -mulrA mulrV ?mulr1 ?unitfE // subrK. *)
(* Qed. *)
(* Admitted. *)

(* TODO redo *)
(* Lemma locally_2d_1d (P : R -> R -> Prop) x y : *)
(*   locally_2d x y P -> *)
(*   locally_2d x y (fun u v => forall t, 0 <= t <= 1 -> locally_2d (x + t * (u - x)) (y + t * (v - y)) P). *)
(* Proof. *)
(* move/locally_2d_1d_strong. *)
(* apply: locally_2d_impl. *)
(* apply locally_2d_forall => u v H t Ht. *)
(* specialize (H t Ht). *)
(* have : locally t (fun z => locally_2d (x + z * (u - x)) (y + z * (v - y)) P) by []. *)
(* by apply: locally_singleton. *)
(* Qed. *)

(* TODO redo *)
(* Lemma locally_2d_ex_dec : *)
(*   forall P x y, *)
(*   (forall x y, P x y \/ ~P x y) -> *)
(*   locally_2d x y P -> *)
(*   {d : posreal | forall u v, `|u - x| < d -> `|v - y| < d -> P u v}. *)
(* Proof. *)
(* move=> P x y P_dec H. *)
(* destruct (@locally_ex _ (x, y) (fun z => P (fst z) (snd z))) as [d Hd]. *)
(* - move: H => /locallyP [e _ H]. *)
(*   by apply/locallyP; exists e. *)
(* exists d=>  u v Hu Hv. *)
(* by apply (Hd (u, v)) => /=; split; apply sub_abs_ball; rewrite absrB. *)
(* Qed. *)

Definition bounded (K : absRingType) (V : normedModType K) (A : set V) :=
  \forall M \near +oo, A `<=` [set x | `|[x]| < M].

Lemma compact_bounded (K : absRingType) (V : normedModType K) (A : set V) :
  compact A -> bounded A.
Proof.
rewrite compact_cover => Aco.
have covA : A `<=` \bigcup_(n : int) [set p | `|[p]| < n%:~R].
  move=> p Ap; exists (ifloor `|[p]| + 1) => //.
  by rewrite rmorphD /= -floorE floorS_gtr.
have /Aco [] := covA.
  move=> n _; rewrite openE => p; rewrite -subr_gt0 => ltpn.
  apply/locally_normP; exists (n%:~R - `|[p]|) => // q.
  rewrite /ball ltr_subr_addr normmB; apply: ler_lt_trans.
  by rewrite -{1}(subrK p q) ler_normm_add.
move=> D _ DcovA.
exists (bigmaxr 0 [seq n%:~R | n <- enum_fset D]).
move=> x ltmaxx p /DcovA [n Dn /ltr_trans]; apply; apply: ler_lt_trans ltmaxx.
have ltin : (index n (enum_fset D) < size (enum_fset D))%N by rewrite index_mem.
rewrite -(nth_index 0 Dn) -(nth_map _ 0) //; apply: bigmaxr_ler.
by rewrite size_map.
Qed.

Lemma rV_compact (T : topologicalType) n (A : 'I_n -> set T) :
  (forall i, compact (A i)) ->
  compact [ set v : 'rV[T]_n | forall i, A i (v ord0 i)].
Proof.
move=> Aico.
have : @compact (product_topologicalType _) [set f | forall i, A i (f i)].
  by apply: tychonoff.
move=> Aco F FF FA.
set G := [set [set f : 'I_n -> T | B (\row_j f j)] | B in F].
have row_simpl (v : 'rV[T]_n) : \row_j (v ord0 j) = v.
  by apply/rowP => ?; rewrite mxE.
have row_simpl' (f : 'I_n -> T) : (\row_j f j) ord0 = f.
  by rewrite funeqE=> ?; rewrite mxE.
have [f [Af clGf]] : [set f | forall i, A i (f i)] `&`
  @cluster (product_topologicalType _) G !=set0.
  suff GF : ProperFilter G.
    apply: Aco; exists [set v : 'rV[T]_n | forall i, A i (v ord0 i)] => //.
    by rewrite predeqE => f; split => Af i; [have := Af i|]; rewrite row_simpl'.
  apply Build_ProperFilter.
    move=> _ [C FC <-]; have /filter_ex [v Cv] := FC.
    by exists (v ord0); rewrite row_simpl.
  split.
  - by exists setT => //; apply: filterT.
  - by move=> _ _ [C FC <-] [D FD <-]; exists (C `&` D) => //; apply: filterI.
  move=> C D sCD [E FE EeqC]; exists [set v : 'rV[T]_n | D (v ord0)].
    by apply: filterS FE => v Ev; apply/sCD; rewrite -EeqC row_simpl.
  by rewrite predeqE => ?; rewrite row_simpl'.
exists (\row_j f j); split; first by move=> i; rewrite mxE; apply: Af.
move=> C D FC f_D; have {f_D} f_D :
  locally (f : product_topologicalType _) [set g | D (\row_j g j)].
  have [E f_E sED] := f_D; rewrite locallyE.
  set Pj := fun j Bj => neigh (f j) Bj /\ Bj `<=` E ord0 j.
  have exPj : forall j, exists Bj, neigh (f j) Bj /\ Bj `<=` E ord0 j.
    move=> j; have := f_E ord0 j; rewrite locallyE => - [Bj].
    by rewrite row_simpl'; exists Bj.
  exists [set g | forall j, (get (Pj j)) (g j)]; split; last first.
    move=> g Pg; apply: sED => i j; rewrite ord1 row_simpl'.
    by have /getPex [_ /(_ _ (Pg j))] := exPj j.
  split; last by move=> j; have /getPex [[]] := exPj j.
  exists [set [set g | forall j, get (Pj j) (g j)]]; last first.
    rewrite predeqE => g; split=> [[? ->] | Pg] //.
    by exists [set g | forall j, get (Pj j) (g j)].
  move=> _ ->; set s := [seq (@^~ j) @^-1` (get (Pj j)) | j : 'I_n].
  exists [fset x in s]%fset.
    move=> B'; rewrite in_fset => /mapP [j _ ->]; rewrite inE.
    apply/asboolP; exists j => //; exists (get (Pj j)) => //.
    by have /getPex [[]] := exPj j.
  rewrite predeqE => g; split=> [Ig j|Ig B'].
    apply: (Ig ((@^~ j) @^-1` (get (Pj j)))).
    by rewrite in_fset; apply/mapP; exists j => //; rewrite mem_enum.
  by rewrite in_fset => /mapP [j _ ->]; apply: Ig.
have GC : G [set g | C (\row_j g j)] by exists C.
by have [g []] := clGf _ _ GC f_D; exists (\row_j (g j : T)).
Qed.

Lemma bounded_closed_compact n (A : set 'rV[R]_n) :
  bounded A -> closed A -> compact A.
Proof.
move=> [M normAltM] Acl.
have Mnco : compact
  [set v : 'rV[R]_n | (forall i, (v ord0 i) \in `[(- (M + 1)), (M + 1)])].
  apply: (@rV_compact _ _ (fun _ => [set x | x \in `[(- (M + 1)), (M + 1)]])).
  by move=> _; apply: segment_compact.
apply: subclosed_compact Acl Mnco _ => v /normAltM normvltM i.
suff /ltrW : `|[v ord0 i : R^o]| < M + 1 by rewrite ler_norml.
by apply: ler_lt_trans (ler_bigmaxr (_,_) _) (normvltM _ _); rewrite ltr_addl.
Qed.

(** Open sets in [Rbar] *)

Lemma open_Rbar_lt y : open (fun u : R => Rbar_lt u y).
Proof.
case: y => [y||] /=.
exact: open_lt.
by rewrite trueE; apply: openT.
by rewrite falseE; apply: open0.
Qed.

Lemma open_Rbar_gt y : open (fun u : R => Rbar_lt y u).
Proof.
case: y => [y||] /=.
exact: open_gt.
by rewrite falseE; apply: open0.
by rewrite trueE; apply: openT.
Qed.

Lemma open_Rbar_lt' x y : Rbar_lt x y -> Rbar_locally x (fun u => Rbar_lt u y).
Proof.
case: x => [x|//|] xy; first exact: open_Rbar_lt.
case: y => [y||//] /= in xy *.
exists y => /= x ? //.
by exists 0.
Qed.

Lemma open_Rbar_gt' x y : Rbar_lt y x -> Rbar_locally x (fun u => Rbar_lt y u).
Proof.
case: x => [x||] //=; do ?[exact: open_Rbar_gt];
  case: y => [y||] //=; do ?by exists 0.
by exists y => x yx //=.
Qed.

Lemma Rbar_locally'_le x : Rbar_locally' x --> Rbar_locally x.
Proof.
by move: x => [||] x P //=; rewrite locally_simpl /locally /= locallyE' => -[].
Qed.

Lemma Rbar_locally'_le_finite (x : R) : Rbar_locally' x --> locally x.
Proof.
move=> P; rewrite locally_simpl => /(@locally_normP _ [normedModType R of R^o]).
move=> [_/posnumP[e] sP] /=; apply/(@locally_normP _ [normedModType R of R^o]).
by exists e%:num => // ? /sP.
Qed.

(** * Some limits on real functions *)

Definition Rbar_loc_seq (x : Rbar) (n : nat) := match x with
    | Finite x => x + (INR n + 1)^-1
    | +oo => INR n
    | -oo => - INR n
  end.

Lemma flim_Rbar_loc_seq x : Rbar_loc_seq x --> Rbar_locally' x.
Proof.
move=> P; rewrite /Rbar_loc_seq.
case: x => /= [x /(@locally_normP _ [normedModType R of R^o])
  [_/posnumP[delta] Hp] |[delta Hp] |[delta Hp]]; last 2 first.
    have /ZnatP [N Nfloor] : ifloor (maxr delta 0) \is a Znat.
      by rewrite Znat_def ifloor_ge0 ler_maxr lerr orbC.
    exists N.+1 => // n ltNn; apply: Hp.
    have /ler_lt_trans : delta <= maxr delta 0 by rewrite ler_maxr lerr.
    apply; apply: ltr_le_trans (floorS_gtr _) _; rewrite floorE Nfloor.
    by rewrite -(@natrD [ringType of R] N 1) INRE ler_nat addn1.
  have /ZnatP [N Nfloor] : ifloor (maxr (- delta) 0) \is a Znat.
    by rewrite Znat_def ifloor_ge0 ler_maxr lerr orbC.
  exists N.+1 => // n ltNn; apply: Hp; rewrite ltr_oppl.
  have /ler_lt_trans : - delta <= maxr (- delta) 0 by rewrite ler_maxr lerr.
  apply; apply: ltr_le_trans (floorS_gtr _) _; rewrite floorE Nfloor.
  by rewrite -(@natrD [ringType of R] N 1) INRE ler_nat addn1.
have /ZnatP [N Nfloor] : ifloor (delta%:num^-1) \is a Znat.
  by rewrite Znat_def ifloor_ge0.
exists N => // n leNn; have gt0Sn : 0 < INR n + 1.
  by apply: ltr_spaddr => //; apply/RleP/pos_INR.
apply: Hp; last first.
  by rewrite eq_sym addrC -subr_eq subrr eq_sym; apply/invr_neq0/lt0r_neq0.
rewrite /ball opprD addrA subrr normmB subr0.
rewrite [ `|[_]|]gtr0_norm; last by rewrite invr_gt0.
rewrite -[X in X < _]mulr1 ltr_pdivr_mull // -ltr_pdivr_mulr // div1r.
apply: ltr_le_trans (floorS_gtr _) _; rewrite floorE Nfloor ler_add //.
by rewrite INRE ler_nat.
Qed.

(* TODO: express using ball?*)
Lemma continuity_pt_locally f x : continuity_pt f x <->
  forall eps : posreal, locally x (fun u => `|f u - f x| < eps).
Proof.
split=> [fcont e|fcont _/RltP/posnumP[e]]; last first.
  have /(@locally_normP _ [normedModType R of R^o]) [_/posnumP[d] xd_fxe] :=
  fcont e.
  exists d%:num; split; first by apply/RltP; have := [gt0 of d%:num].
  by move=> y [_ /RltP yxd]; apply/RltP/xd_fxe; rewrite /ball normmB.
apply/(@locally_normP _ [normedModType R of R^o]).
have /RltP egt0 := [gt0 of e%:num].
have [_ [/RltP/posnumP[d] dx_fxe]] := fcont e%:num egt0.
exists d%:num => // y xyd; case: (eqVneq x y) => [->|xney].
  by rewrite subrr absr0.
apply/RltP/dx_fxe; split; first by split=> //; apply/eqP.
by have /RltP := xyd; rewrite normmB.
Qed.

Lemma continuity_pt_flim (f : R -> R) (x : R) :
  continuity_pt f x <-> {for x, continuous f}.
Proof.
apply: iff_trans (continuity_pt_locally _ _) _; apply: iff_sym.
have FF : Filter (f @ x).
(* (* BUG: this should work *) *)
(*   by typeclasses eauto. *)
  by apply filtermap_filter; apply: @filter_filter' (locally_filter _).
apply: iff_trans (flim_normP (f x : R^o)) _; split=> [fx e|fx _/posnumP[e]].
  have /fx := [gt0 of e%:num].
  by apply: (@filter_app _ (locally x)); near=> y; rewrite /= normmB.
have := fx e; rewrite !near_simpl; apply: filter_app.
by near=> y; rewrite normmB.
Unshelve. all: end_near. Qed.

Lemma continuity_ptE (f : R -> R) (x : R) :
  continuity_pt f x <-> {for x, continuous f}.
Proof. exact: continuity_pt_flim. Qed.

Lemma continuity_pt_flim' f x :
  continuity_pt f x <-> f @ locally' x --> f x.
Proof. by rewrite continuity_ptE continuous_withinNx. Qed.

Lemma continuity_pt_locally' f x :
  continuity_pt f x <->
  forall eps : R, 0 < eps -> locally' x (fun u => `|f x - f u| < eps)%R.
Proof.
by rewrite continuity_pt_flim' (@flim_normP _ [normedModType R of R^o]).
Qed.

Lemma locally_pt_comp (P : R -> Prop) (f : R -> R) (x : R) :
  locally (f x) P -> continuity_pt f x -> \near x, P (f x).
Proof. by move=> Lf /continuity_pt_flim; apply. Qed.
