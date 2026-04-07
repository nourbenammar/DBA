----------------------------------------------------
-- TP 4 - PL/SQL
----------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE resultatsFactoriels';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE resultatFactoriel';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE emp';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE client';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_client';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE pkg_gestion_client';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION puissance_rec';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

----------------------------------------------------
-- EXERCICE 1
----------------------------------------------------

-- 1) Somme de deux entiers
BEGIN
    DBMS_OUTPUT.PUT_LINE('Somme = ' || (5 + 7));
END;
/

-- 2) Table de multiplication de 4
BEGIN
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE('4 x ' || i || ' = ' || (4 * i));
    END LOOP;
END;
/

-- 3) Fonction récursive x^n
CREATE OR REPLACE FUNCTION puissance_rec(p_x NUMBER, p_n NUMBER)
RETURN NUMBER
IS
BEGIN
    IF p_n < 0 OR p_x < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'x et n doivent etre positifs.');
    ELSIF p_n = 0 THEN
        RETURN 1;
    ELSIF p_n = 1 THEN
        RETURN p_x;
    ELSE
        RETURN p_x * puissance_rec(p_x, p_n - 1);
    END IF;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('2^5 = ' || puissance_rec(2, 5));
END;
/

-- 4) Factorielle de 5 stockee dans resultatFactoriel
CREATE TABLE resultatFactoriel (
    n NUMBER PRIMARY KEY,
    factorielle NUMBER
);
/

DECLARE
    v_n NUMBER := 5;
    v_fact NUMBER := 1;
BEGIN
    FOR i IN 1..v_n LOOP
        v_fact := v_fact * i;
    END LOOP;

    INSERT INTO resultatFactoriel(n, factorielle)
    VALUES (v_n, v_fact);

    DBMS_OUTPUT.PUT_LINE('Factorielle de ' || v_n || ' = ' || v_fact);
END;
/

-- 5) Stocker les factorielles des 20 premiers entiers
CREATE TABLE resultatsFactoriels (
    n NUMBER PRIMARY KEY,
    factorielle NUMBER
);
/

DECLARE
    v_fact NUMBER := 1;
BEGIN
    FOR i IN 1..20 LOOP
        v_fact := v_fact * i;
        INSERT INTO resultatsFactoriels(n, factorielle)
        VALUES (i, v_fact);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Les 20 premieres factorielles ont ete inserees.');
END;
/

----------------------------------------------------
-- EXERCICE 2
----------------------------------------------------

CREATE TABLE emp (
    matr NUMBER(10) NOT NULL,
    nom VARCHAR2(50) NOT NULL,
    sal NUMBER(7,2),
    adresse VARCHAR2(96),
    dep NUMBER(10) NOT NULL,
    CONSTRAINT emp_pk PRIMARY KEY (matr)
);
/

INSERT INTO emp VALUES (1, 'Ali', 1800, 'Alger', 92000);
INSERT INTO emp VALUES (2, 'Sonia', 2200, 'Paris', 75000);
INSERT INTO emp VALUES (3, 'Nadia', 2000, 'Lyon', 10);
INSERT INTO emp VALUES (5, 'Karim', 2600, 'Marseille', 92000);
INSERT INTO emp VALUES (6, 'Lina', 2400, 'Boulevard Voltaire', 75000);
COMMIT;
/

-- 1) Insertion d'un employe
DECLARE
    v_employe emp%ROWTYPE;
BEGIN
    v_employe.matr    := 4;
    v_employe.nom     := 'Youcef';
    v_employe.sal     := 2500;
    v_employe.adresse := 'avenue de la Republique';
    v_employe.dep     := 92002;

    INSERT INTO emp VALUES v_employe;

    DBMS_OUTPUT.PUT_LINE('Employe insere avec succes.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : matricule deja existant.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
END;
/

-- 2) Suppression des employes du departement 10
DECLARE
    v_nb_lignes NUMBER;
BEGIN
    DELETE FROM emp
    WHERE dep = 10;

    v_nb_lignes := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Nombre de lignes supprimees : ' || v_nb_lignes);
END;
/

-- 3) Somme des salaires avec curseur explicite
DECLARE
    v_salaire emp.sal%TYPE;
    v_total emp.sal%TYPE := 0;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;
    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;
        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
        END IF;
    END LOOP;
    CLOSE c_salaires;

    DBMS_OUTPUT.PUT_LINE('Somme des salaires = ' || v_total);
END;
/

-- 4) Salaire moyen avec curseur explicite
DECLARE
    v_salaire emp.sal%TYPE;
    v_total NUMBER := 0;
    v_count NUMBER := 0;
    v_moyenne NUMBER := 0;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;
    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;
        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    CLOSE c_salaires;

    IF v_count > 0 THEN
        v_moyenne := v_total / v_count;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Salaire moyen = ' || v_moyenne);
END;
/

-- 5) Somme et moyenne avec FOR IN
DECLARE
    v_total NUMBER := 0;
    v_count NUMBER := 0;
    v_moyenne NUMBER := 0;
BEGIN
    FOR rec IN (SELECT sal FROM emp) LOOP
        IF rec.sal IS NOT NULL THEN
            v_total := v_total + rec.sal;
            v_count := v_count + 1;
        END IF;
    END LOOP;

    IF v_count > 0 THEN
        v_moyenne := v_total / v_count;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Somme (FOR IN) = ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Moyenne (FOR IN) = ' || v_moyenne);
END;
/

-- 6) Curseur parametre
DECLARE
    CURSOR c(p_dep emp.dep%TYPE) IS
        SELECT dep, nom
        FROM emp
        WHERE dep = p_dep;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Employes du departement 92000 :');
    FOR v_employe IN c(92000) LOOP
        DBMS_OUTPUT.PUT_LINE(' - ' || v_employe.nom);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Employes du departement 75000 :');
    FOR v_employe IN c(75000) LOOP
        DBMS_OUTPUT.PUT_LINE(' - ' || v_employe.nom);
    END LOOP;
END;
/

----------------------------------------------------
-- EXERCICE 3
----------------------------------------------------

CREATE TABLE client (
    id_client NUMBER PRIMARY KEY,
    nom VARCHAR2(100) NOT NULL,
    adresse VARCHAR2(200)
);
/

CREATE SEQUENCE seq_client START WITH 1 INCREMENT BY 1;
/

CREATE OR REPLACE PACKAGE pkg_gestion_client AS
    PROCEDURE ajouter_client(
        p_id_client IN client.id_client%TYPE,
        p_nom       IN client.nom%TYPE,
        p_adresse   IN client.adresse%TYPE
    );

    PROCEDURE ajouter_client(
        p_nom       IN client.nom%TYPE,
        p_adresse   IN client.adresse%TYPE
    );
END pkg_gestion_client;
/

CREATE OR REPLACE PACKAGE BODY pkg_gestion_client AS

    PROCEDURE ajouter_client(
        p_id_client IN client.id_client%TYPE,
        p_nom       IN client.nom%TYPE,
        p_adresse   IN client.adresse%TYPE
    )
    IS
    BEGIN
        IF p_id_client IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'ID client obligatoire.');
        ELSIF p_nom IS NULL THEN
            RAISE_APPLICATION_ERROR(-20011, 'Nom client obligatoire.');
        END IF;

        INSERT INTO client(id_client, nom, adresse)
        VALUES (p_id_client, p_nom, p_adresse);

        DBMS_OUTPUT.PUT_LINE('Client ajoute avec id fourni : ' || p_id_client);

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : un client avec cet ID existe deja.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur dans ajouter_client(id, nom, adresse) : ' || SQLERRM);
    END ajouter_client;

    PROCEDURE ajouter_client(
        p_nom       IN client.nom%TYPE,
        p_adresse   IN client.adresse%TYPE
    )
    IS
        v_id client.id_client%TYPE;
    BEGIN
        IF p_nom IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'Nom client obligatoire.');
        END IF;

        SELECT seq_client.NEXTVAL
        INTO v_id
        FROM dual;

        INSERT INTO client(id_client, nom, adresse)
        VALUES (v_id, p_nom, p_adresse);

        DBMS_OUTPUT.PUT_LINE('Client ajoute avec ID automatique : ' || v_id);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur dans ajouter_client(nom, adresse) : ' || SQLERRM);
    END ajouter_client;

END pkg_gestion_client;
/

BEGIN
    pkg_gestion_client.ajouter_client(100, 'Client A', 'Alger Centre');
    pkg_gestion_client.ajouter_client('Client B', 'Oran');
    pkg_gestion_client.ajouter_client('Client C', 'Constantine');
END;
/

COMMIT;
/

SELECT * FROM resultatFactoriel ORDER BY n;
SELECT * FROM resultatsFactoriels ORDER BY n;
SELECT * FROM emp ORDER BY matr;
SELECT * FROM client ORDER BY id_client;
