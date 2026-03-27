-- ============================================================
-- 1) Afficher le nom du département qui a le budget le plus élevé.
-- ============================================================
SELECT dept_name
FROM department
WHERE budget = (
    SELECT MAX(budget)
    FROM department
);

-- ============================================================
-- 2) Afficher les salaires et les noms des enseignants
--    qui gagnent plus que le salaire moyen.
-- ============================================================
SELECT name, salary
FROM instructor
WHERE salary > (
    SELECT AVG(salary)
    FROM instructor
)
ORDER BY salary DESC;

-- ============================================================
-- 3) Pour chaque enseignant, afficher tous les étudiants
--    qui ont suivi plus de deux cours dispensés par cet enseignant,
--    en utilisant HAVING.
-- ============================================================
SELECT i.ID   AS instructor_id,
       i.name AS instructor_name,
       s.ID   AS student_id,
       s.name AS student_name,
       COUNT(*) AS nb_cours_suivis_avec_cet_enseignant
FROM instructor i
JOIN teaches te
    ON i.ID = te.ID
JOIN takes ta
    ON te.course_id = ta.course_id
   AND te.sec_id    = ta.sec_id
   AND te.semester  = ta.semester
   AND te.year      = ta.year
JOIN student s
    ON s.ID = ta.ID
GROUP BY i.ID, i.name, s.ID, s.name
HAVING COUNT(*) > 2
ORDER BY i.name, nb_cours_suivis_avec_cet_enseignant DESC;

-- ============================================================
-- 4) Même question que (3), sans utiliser HAVING.
-- ============================================================
SELECT *
FROM (
    SELECT i.ID   AS instructor_id,
           i.name AS instructor_name,
           s.ID   AS student_id,
           s.name AS student_name,
           COUNT(*) AS nb_cours_suivis_avec_cet_enseignant
    FROM instructor i
    JOIN teaches te
        ON i.ID = te.ID
    JOIN takes ta
        ON te.course_id = ta.course_id
       AND te.sec_id    = ta.sec_id
       AND te.semester  = ta.semester
       AND te.year      = ta.year
    JOIN student s
        ON s.ID = ta.ID
    GROUP BY i.ID, i.name, s.ID, s.name
)
WHERE nb_cours_suivis_avec_cet_enseignant > 2
ORDER BY instructor_name, nb_cours_suivis_avec_cet_enseignant DESC;

-- ============================================================
-- 5) Afficher les identifiants et les noms des étudiants
--    qui n'ont pas suivi de cours avant 2010.
--    => aucun enregistrement takes avec year < 2010.
-- ============================================================
SELECT s.ID, s.name
FROM student s
WHERE NOT EXISTS (
    SELECT 1
    FROM takes t
    WHERE t.ID = s.ID
      AND t.year < 2010
)
ORDER BY s.ID;

-- ============================================================
-- 6) Afficher tous les enseignants dont les noms commencent par E.
-- ============================================================
SELECT *
FROM instructor
WHERE name LIKE 'E%'
ORDER BY name;

-- ============================================================
-- 7) Afficher les salaires et les noms des enseignants
--    qui perçoivent le 4ème salaire le plus élevé.
--    DENSE_RANK gère correctement les ex aequo.
-- ============================================================
SELECT name, salary
FROM (
    SELECT name,
           salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM instructor
)
WHERE rnk = 4
ORDER BY name;

-- ============================================================
-- 8) Afficher les noms et salaires des trois enseignants
--    qui perçoivent les salaires les moins élevés.
--    Les afficher par ordre décroissant.
--    Ici on prend 3 lignes après tri croissant,
--    puis on réaffiche le résultat en décroissant.
-- ============================================================
SELECT name, salary
FROM (
    SELECT name, salary
    FROM instructor
    ORDER BY salary ASC, name ASC
)
WHERE ROWNUM <= 3
ORDER BY salary DESC, name DESC;

-- Variante plus robuste en Oracle moderne :
-- SELECT name, salary
-- FROM (
--     SELECT name, salary,
--            ROW_NUMBER() OVER (ORDER BY salary ASC, name ASC) AS rn
--     FROM instructor
-- )
-- WHERE rn <= 3
-- ORDER BY salary DESC, name DESC;

-- ============================================================
-- 9) Afficher les noms des étudiants qui ont suivi un cours
--    en automne 2009, en utilisant IN.
-- ============================================================
SELECT name
FROM student
WHERE ID IN (
    SELECT ID
    FROM takes
    WHERE semester = 'Fall'
      AND year = 2009
)
ORDER BY name;

-- ============================================================
-- 10) Même question, en utilisant SOME.
-- ============================================================
SELECT name
FROM student
WHERE ID = SOME (
    SELECT ID
    FROM takes
    WHERE semester = 'Fall'
      AND year = 2009
)
ORDER BY name;

-- ============================================================
-- 11) Même question, en utilisant NATURAL INNER JOIN.
-- ============================================================
SELECT DISTINCT name
FROM student
NATURAL INNER JOIN (
    SELECT ID
    FROM takes
    WHERE semester = 'Fall'
      AND year = 2009
)
ORDER BY name;

-- ============================================================
-- 12) Même question, en utilisant EXISTS.
-- ============================================================
SELECT s.name
FROM student s
WHERE EXISTS (
    SELECT 1
    FROM takes t
    WHERE t.ID = s.ID
      AND t.semester = 'Fall'
      AND t.year = 2009
)
ORDER BY s.name;

-- ============================================================
-- 13) Afficher toutes les paires d'étudiants qui ont suivi
--     au moins un cours ensemble.
--     On évite les doublons avec s1.ID < s2.ID.
-- ============================================================
SELECT DISTINCT s1.ID   AS student1_id,
                s1.name AS student1_name,
                s2.ID   AS student2_id,
                s2.name AS student2_name
FROM takes t1
JOIN takes t2
    ON t1.course_id = t2.course_id
   AND t1.sec_id    = t2.sec_id
   AND t1.semester  = t2.semester
   AND t1.year      = t2.year
   AND t1.ID < t2.ID
JOIN student s1
    ON s1.ID = t1.ID
JOIN student s2
    ON s2.ID = t2.ID
ORDER BY student1_id, student2_id;

-- ============================================================
-- 14) Pour chaque enseignant ayant effectivement assuré un cours,
--     afficher le nombre total d'étudiants ayant suivi ses cours.
--     Si un étudiant suit deux cours différents avec le même enseignant,
--     on le compte deux fois.
-- ============================================================
SELECT i.ID   AS instructor_id,
       i.name AS instructor_name,
       COUNT(*) AS total_inscriptions
FROM instructor i
JOIN teaches te
    ON i.ID = te.ID
JOIN takes ta
    ON te.course_id = ta.course_id
   AND te.sec_id    = ta.sec_id
   AND te.semester  = ta.semester
   AND te.year      = ta.year
GROUP BY i.ID, i.name
ORDER BY total_inscriptions DESC, instructor_name;

-- ============================================================
-- 15) Même question, mais inclure aussi les enseignants
--     n'ayant assuré aucun cours.
-- ============================================================
SELECT i.ID   AS instructor_id,
       i.name AS instructor_name,
       COUNT(ta.ID) AS total_inscriptions
FROM instructor i
LEFT JOIN teaches te
    ON i.ID = te.ID
LEFT JOIN takes ta
    ON te.course_id = ta.course_id
   AND te.sec_id    = ta.sec_id
   AND te.semester  = ta.semester
   AND te.year      = ta.year
GROUP BY i.ID, i.name
ORDER BY total_inscriptions DESC, instructor_name;

-- ============================================================
-- 16) Pour chaque enseignant, afficher le nombre total de grades A
--     qu'il a attribués.
-- ============================================================
SELECT i.ID   AS instructor_id,
       i.name AS instructor_name,
       COUNT(*) AS nb_grades_A
FROM instructor i
JOIN teaches te
    ON i.ID = te.ID
JOIN takes ta
    ON te.course_id = ta.course_id
   AND te.sec_id    = ta.sec_id
   AND te.semester  = ta.semester
   AND te.year      = ta.year
WHERE ta.grade = 'A'
GROUP BY i.ID, i.name
ORDER BY nb_grades_A DESC, instructor_name;

-- Variante pour afficher aussi les enseignants avec 0 grade A :
-- SELECT i.ID AS instructor_id,
--        i.name AS instructor_name,
--        SUM(CASE WHEN ta.grade = 'A' THEN 1 ELSE 0 END) AS nb_grades_A
-- FROM instructor i
-- LEFT JOIN teaches te
--     ON i.ID = te.ID
-- LEFT JOIN takes ta
--     ON te.course_id = ta.course_id
--    AND te.sec_id    = ta.sec_id
--    AND te.semester  = ta.semester
--    AND te.year      = ta.year
-- GROUP BY i.ID, i.name
-- ORDER BY nb_grades_A DESC, instructor_name;

-- ============================================================
-- 17) Afficher toutes les paires enseignant-élève où un élève
--     a suivi le cours de l'enseignant, ainsi que le nombre de fois.
-- ============================================================
SELECT i.ID   AS instructor_id,
       i.name AS instructor_name,
       s.ID   AS student_id,
       s.name AS student_name,
       COUNT(*) AS nb_fois
FROM instructor i
JOIN teaches te
    ON i.ID = te.ID
JOIN takes ta
    ON te.course_id = ta.course_id
   AND te.sec_id    = ta.sec_id
   AND te.semester  = ta.semester
   AND te.year      = ta.year
JOIN student s
    ON s.ID = ta.ID
GROUP BY i.ID, i.name, s.ID, s.name
ORDER BY instructor_name, student_name;

-- ============================================================
-- 18) Afficher toutes les paires enseignant-élève où un élève
--     a suivi au moins deux cours dispensés par cet enseignant.
-- ============================================================
SELECT i.ID   AS instructor_id,
       i.name AS instructor_name,
       s.ID   AS student_id,
       s.name AS student_name,
       COUNT(*) AS nb_fois
FROM instructor i
JOIN teaches te
    ON i.ID = te.ID
JOIN takes ta
    ON te.course_id = ta.course_id
   AND te.sec_id    = ta.sec_id
   AND te.semester  = ta.semester
   AND te.year      = ta.year
JOIN student s
    ON s.ID = ta.ID
GROUP BY i.ID, i.name, s.ID, s.name
HAVING COUNT(*) >= 2
ORDER BY instructor_name, nb_fois DESC, student_name;

