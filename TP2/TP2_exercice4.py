import itertools
from typing import Iterable, List, Set, Tuple, FrozenSet, Optional

# Une dépendance fonctionnelle est représentée par (alpha, beta)
# où alpha et beta sont des ensembles d'attributs.
FD = Tuple[Set[str], Set[str]]
FrozenFD = Tuple[FrozenSet[str], FrozenSet[str]]


def fmt_attrs(attrs: Iterable[str]) -> str:
    """Retourne une représentation lisible d'un ensemble d'attributs."""
    s = sorted(set(attrs))
    return "{" + ", ".join(s) + "}"


def fmt_fd(fd: FD) -> str:
    alpha, beta = fd
    return f"{fmt_attrs(alpha)} -> {fmt_attrs(beta)}"


# ---------------------------------------------------------------------
# 1) Afficher une liste de dépendances fonctionnelles
# ---------------------------------------------------------------------
def printDependencies(F: List[FD]) -> None:
    for alpha, beta in F:
        print(f"\t{fmt_attrs(alpha)} -> {fmt_attrs(beta)}")


# ---------------------------------------------------------------------
# 2) Afficher un ensemble de relations
# ---------------------------------------------------------------------
def printRelations(T: List[Set[str]]) -> None:
    for R in T:
        print(f"\t{fmt_attrs(R)}")


# ---------------------------------------------------------------------
# 3) Retourner tous les sous-ensembles non vides d'un ensemble
# ---------------------------------------------------------------------
def powerSet(inputset: Set[str]) -> List[Set[str]]:
    result: List[Set[str]] = []
    items = sorted(inputset)
    for r in range(1, len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(set(combo))
    return result


# ---------------------------------------------------------------------
# Outil : projeter F sur une relation R (on ne garde que les DF internes à R)
# ---------------------------------------------------------------------
def project_dependencies(F: List[FD], R: Set[str]) -> List[FD]:
    result: List[FD] = []
    for alpha, beta in F:
        if alpha.issubset(R) and beta.issubset(R):
            result.append((set(alpha), set(beta)))
    return result


# ---------------------------------------------------------------------
# 4) Fermeture d'un ensemble d'attributs K par rapport à F
# ---------------------------------------------------------------------
def closure(F: List[FD], K: Set[str]) -> Set[str]:
    Kplus = set(K)
    changed = True
    while changed:
        changed = False
        for alpha, beta in F:
            if alpha.issubset(Kplus) and not beta.issubset(Kplus):
                Kplus |= beta
                changed = True
    return Kplus


# ---------------------------------------------------------------------
# 5) Clôture de F : toutes les DF déductibles de F
#    On l'obtient en parcourant tous les sous-ensembles d'attributs.
# ---------------------------------------------------------------------
def fd_closure(F: List[FD]) -> List[FD]:
    universe = set()
    for alpha, beta in F:
        universe |= alpha | beta

    result: Set[FrozenFD] = set()
    subsets = [set()] + powerSet(universe)

    for X in subsets:
        Xplus = closure(F, X)
        for a in Xplus - X:
            result.add((frozenset(X), frozenset({a})))

    return [(set(alpha), set(beta)) for alpha, beta in sorted(
        result,
        key=lambda fd: (sorted(fd[0]), sorted(fd[1]))
    )]


# ---------------------------------------------------------------------
# 6) Vérifier si alpha détermine fonctionnellement beta
# ---------------------------------------------------------------------
def implies(F: List[FD], alpha: Set[str], beta: Set[str]) -> bool:
    return beta.issubset(closure(F, alpha))


# ---------------------------------------------------------------------
# 7) Vérifier si K est une super-clé de R
# ---------------------------------------------------------------------
def is_superkey(F: List[FD], R: Set[str], K: Set[str]) -> bool:
    return closure(F, K) >= R


# ---------------------------------------------------------------------
# 8) Vérifier si K est une clé candidate de R
# ---------------------------------------------------------------------
def is_candidate_key(F: List[FD], R: Set[str], K: Set[str]) -> bool:
    if not is_superkey(F, R, K):
        return False
    for attr in list(K):
        smaller = set(K)
        smaller.remove(attr)
        if is_superkey(F, R, smaller):
            return False
    return True


# ---------------------------------------------------------------------
# 9) Retourner toutes les clés candidates de R
# ---------------------------------------------------------------------
def candidate_keys(R: Set[str], F: List[FD]) -> List[Set[str]]:
    keys: List[Set[str]] = []
    for subset in sorted(powerSet(R), key=lambda s: (len(s), sorted(s))):
        if is_candidate_key(F, R, subset):
            keys.append(subset)
    return keys


# ---------------------------------------------------------------------
# 10) Retourner toutes les super-clés de R
# ---------------------------------------------------------------------
def superkeys(R: Set[str], F: List[FD]) -> List[Set[str]]:
    result: List[Set[str]] = []
    for subset in powerSet(R):
        if is_superkey(F, R, subset):
            result.append(subset)
    return sorted(result, key=lambda s: (len(s), sorted(s)))


# ---------------------------------------------------------------------
# 11) Retourner une clé candidate (la première trouvée)
# ---------------------------------------------------------------------
def one_candidate_key(F: List[FD], R: Set[str]) -> Optional[Set[str]]:
    keys = candidate_keys(R, F)
    return keys[0] if keys else None


# ---------------------------------------------------------------------
# 12) Vérifier si une relation R est en BCNF
#    Toute DF non triviale X -> Y doit avoir X super-clé.
# ---------------------------------------------------------------------
def is_bcnf(R: Set[str], F: List[FD]) -> bool:
    FR = project_dependencies(F, R)
    for alpha, beta in fd_closure(FR):
        if not beta.issubset(alpha):  # DF non triviale
            if not is_superkey(FR, R, alpha):
                return False
    return True


# ---------------------------------------------------------------------
# 13) Vérifier si un schéma (liste de relations) est en BCNF
# ---------------------------------------------------------------------
def schema_is_bcnf(T: List[Set[str]], F: List[FD]) -> bool:
    return all(is_bcnf(R, F) for R in T)


# ---------------------------------------------------------------------
# Outil : trouver une DF qui viole BCNF dans R
# ---------------------------------------------------------------------
def find_bcnf_violation(R: Set[str], F: List[FD]) -> Optional[FD]:
    FR = project_dependencies(F, R)
    for alpha, beta in fd_closure(FR):
        alpha_set, beta_set = set(alpha), set(beta)
        if not beta_set.issubset(alpha_set) and not is_superkey(FR, R, alpha_set):
            return alpha_set, beta_set
    return None


# ---------------------------------------------------------------------
# 14) Décomposition en BCNF
#    Si X -> Y viole BCNF dans R, on décompose R en :
#      R1 = X ∪ Y
#      R2 = R - (Y - X)
# ---------------------------------------------------------------------

def bcnf_decompose(F: List[FD], T: List[Set[str]]) -> List[Set[str]]:
    result = [set(R) for R in T]
    changed = True
    while changed:
        changed = False
        new_result: List[Set[str]] = []
        for R in result:
            violation = find_bcnf_violation(R, F)
            if violation is None:
                new_result.append(R)
            else:
                X, Y = violation
                R1 = X | Y
                R2 = R - (Y - X)
                new_result.append(R1)
                new_result.append(R2)
                changed = True
        result = new_result
    # éliminer les doublons éventuels
    unique: List[Set[str]] = []
    seen: Set[FrozenSet[str]] = set()
    for R in result:
        fR = frozenset(R)
        if fR not in seen:
            seen.add(fR)
            unique.append(R)
    return unique


# ---------------------------------------------------------------------
# Exemple d'utilisation avec les structures données dans l'énoncé
# ---------------------------------------------------------------------
if __name__ == "__main__":
    myrelations = [
        {'A', 'B', 'C', 'G', 'H', 'I'},
        {'X', 'Y'}
    ]

    mydependencies: List[FD] = [
        ({'A'}, {'B'}),      # A -> B
        ({'A'}, {'C'}),      # A -> C
        ({'C', 'G'}, {'H'}), # CG -> H
        ({'C', 'G'}, {'I'}), # CG -> I
        ({'B'}, {'H'})       # B -> H
    ]

    print("Dépendances :")
    printDependencies(mydependencies)

    print("\nRelations :")
    printRelations(myrelations)

    print("\nSous-ensembles de {A,B,C} :")
    for s in powerSet({'A', 'B', 'C'}):
        print(fmt_attrs(s))

    print("\nFermeture de {A, G} :")
    print(fmt_attrs(closure(mydependencies, {'A', 'G'})))

    R = {'A', 'B', 'C', 'G', 'H', 'I'}
    print("\nToutes les clés candidates de R :")
    for k in candidate_keys(R, mydependencies):
        print(fmt_attrs(k))

    print("\nToutes les super-clés de R :")
    for k in superkeys(R, mydependencies):
        print(fmt_attrs(k))

    print("\nR est-elle en BCNF ?", is_bcnf(R, mydependencies))

    print("\nDécomposition BCNF de [R] :")
    printRelations(bcnf_decompose(mydependencies, [R]))
