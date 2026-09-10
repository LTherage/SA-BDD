SET search_path TO SAE;
DROP TRIGGER IF EXISTS trigger_maj_date ON SITUATION;
DROP TRIGGER IF EXISTS trigger_verif_annee ON ETUDIANT;
DROP TRIGGER IF EXISTS trigger_verif_situation ON SITUATION;
DROP TRIGGER IF EXISTS trigger_verif_email ON ETUDIANT;
DROP TRIGGER IF EXISTS trigger_creer_situation ON ETUDIANT;
DROP TRIGGER IF EXISTS trigger_nettoyage_situation ON SITUATION;
DROP TRIGGER IF EXISTS trigger_supprimer_donnees ON ETUDIANT; 
DROP TRIGGER IF EXISTS trigger_verif_coherence_situation ON SITUATION;

\echo '***************************************************************************'
\echo '=====> Compter le nombre d’étudiants diplômés par année'
\echo '==> Utilité : statistiques annuelles de l établissement'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION nb_diplomes_par_annee(p_annee INT)
RETURNS INT AS $$
DECLARE
    nb INT;
BEGIN
    SELECT COUNT(*) INTO nb
    FROM ETUDIANT
    WHERE anneeDiplome = p_annee;

    RETURN nb;
END;
$$ LANGUAGE plpgsql;

\echo '==> Test de nb_diplomes_par_annee : '
SELECT nb_diplomes_par_annee(2023);

\echo '***************************************************************************'
\echo '=====> Afficher la situation d un étudiant'
\echo '==> Utilité : affichage rapide de la situation'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION situation_etudiant(p_id INT)
RETURNS TEXT AS $$
DECLARE
    res TEXT;
BEGIN
    SELECT
        type_situation || 
        COALESCE(' - ' || poste, '') ||
        COALESCE(' - ' || entreprise, '') ||
        COALESCE(' - ' || diplomePrepare, '')
    INTO res
    FROM SITUATION
    WHERE id_etudiant = p_id;

    RETURN res;
END;
$$ LANGUAGE plpgsql;

\echo '==> Test de situation_etudiant : '
SELECT situation_etudiant(1);

\echo '***************************************************************************'
\echo '=====> Vérifier si un étudiant est contactable par l’IUT'
\echo '==> Utilité : respect du RGPD, logique métier claire'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION etudiant_contactable(p_id INT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM ACCORD
        WHERE id_etudiant = p_id
          AND (accord_vacataire OR accord_stage OR accord_ceremonie)
    );
END;
$$ LANGUAGE plpgsql;


\echo '==> Test de etudiant_contactable : '
SELECT etudiant_contactable(3);

\echo '***************************************************************************'
\echo '=====> Vérifier si un étudiant existe déjà'
\echo '==> Utilité : éviter les doublons d’étudiants et les erreurs de saisis'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION etudiant_existe(p_num TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    existe BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM ETUDIANT WHERE numEtu = p_num
    ) INTO existe;

    RETURN existe;
END;
$$ LANGUAGE plpgsql;


\echo '==> Test de etudiant_existe : '
SELECT etudiant_existe('E2021001');


\echo '***************************************************************************'
\echo '=====> Retourne l’âge d’un étudiant diplômé'
\echo '==> Utilité : études démographiques, très courant en base universitaire'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION age_etudiant(p_date_naissance DATE)
RETURNS INT AS $$
BEGIN
    RETURN DATE_PART('year', AGE(CURRENT_DATE, p_date_naissance));
END;
$$ LANGUAGE plpgsql;


\echo '==> Test de age_etudiant : '
SELECT age_etudiant('2001-05-12');


\echo '***************************************************************************'
\echo '=====> Nombre d’étudiants par type de situation'
\echo '==> Utilité : savoir combien sont en emploi / études ou sans emploi pour le taux d insertion pro'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION nb_etudiants_par_situation(p_type TEXT)
RETURNS INT AS $$
DECLARE
    nb INT;
BEGIN
	IF p_type NOT IN ('Employé', 'En étude', 'Sans emploi') THEN
        RAISE EXCEPTION 'Type de situation invalide: %. Types valides: Employé, En étude, Sans emploi', p_type;
    END IF;

    SELECT COUNT(*) INTO nb
    FROM situation
    WHERE type_situation = p_type;

    RETURN nb;
END;
$$ LANGUAGE plpgsql;


\echo '==> Test de nb_etudiants_par_situation : '
SELECT nb_etudiants_par_situation('Employé');


\echo '***************************************************************************'
\echo '=====> Affiche le taux d insertion pro par département après obtention du diplôme'
\echo '==> Utilité : Suivi de l’insertion professionnelle des diplômés'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION taux_insertion_par_departement()
RETURNS TABLE(
    departement VARCHAR,   
    taux_insertion NUMERIC(5,2)
) AS $$
BEGIN
	RETURN QUERY 
    SELECT
        e.departementEtu AS departement, 
        ROUND(
    		(COUNT(s.id_situation) FILTER (WHERE s.type_situation = 'Employé')::NUMERIC 
     		/ NULLIF(COUNT(e.id_etudiant), 0)) * 100, 2) AS taux_insertion 
    FROM ETUDIANT e
    LEFT JOIN SITUATION s ON e.id_etudiant = s.id_etudiant
    GROUP BY e.departementEtu
    ORDER BY e.departementEtu;
END;
$$ LANGUAGE plpgsql;


\echo '==> Test de taux_insertion_par_departement : '
SELECT * FROM taux_insertion_par_departement();



\echo '***************************************************************************'
\echo '=====> mise à jour automatique de la date'
\echo '==> Utilité : À chaque modification de la situation, la date est mise à jour automatiquement.'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION maj_date_situation()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_maj := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_maj_date
BEFORE UPDATE ON situation
FOR EACH ROW
EXECUTE FUNCTION maj_date_situation();


\echo '==> Test de maj_date_situation : '
UPDATE SITUATION
SET entreprise = 'Orange'
WHERE id_etudiant = 1;

SELECT * FROM situation WHERE id_etudiant = 1;


\echo '***************************************************************************'
\echo '=====> Empêcher une année de diplôme dans le futur'
\echo '==> Utilité : évite les incohérences dans la DB.'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION verif_annee_diplome()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.anneeDiplome > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'Année de diplôme invalide';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verif_annee
BEFORE INSERT OR UPDATE ON etudiant
FOR EACH ROW
EXECUTE FUNCTION verif_annee_diplome();


-- Test : tentative d’insertion d’une année future
\echo '==> Test de verif_annee_diplome (doit produire une erreur) : '
UPDATE ETUDIANT
SET anneeDiplome = 2027 -- Doit donner une erreur 
WHERE id_etudiant = 1;

SELECT * FROM situation WHERE id_etudiant = 1;



\echo '***************************************************************************'
\echo '=====> Empêcher une situation vide en plus du NOT NULL dans la table'
\echo '==> Utilité : Préciser que la situation doit être renseignée (Elle renforce la contrainte SQL et permet un message d’erreur plus explicite côté application Java.'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION verif_situation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type_situation IS NULL OR NEW.type_situation = '' THEN
        RAISE EXCEPTION 'La situation doit être renseignée';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_verif_situation
BEFORE INSERT OR UPDATE ON situation
FOR EACH ROW
EXECUTE FUNCTION verif_situation();


-- Test : tentative d’insertion d’un type null
\echo '==> Test de verif_situation (doit produire une erreur) : '
UPDATE SITUATION
SET type_situation = NULL -- Doit donner une erreur 
WHERE id_etudiant = 1;

SELECT * FROM situation WHERE id_etudiant = 1;


\echo '***************************************************************************'
\echo '=====> Vérifier le format de l’email'
\echo '==> Utilité : évite les emails invalides.'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION verifier_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.emailEtu IS NOT NULL AND NEW.emailEtu NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Adresse email invalide';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_verif_email
BEFORE INSERT OR UPDATE ON ETUDIANT
FOR EACH ROW
EXECUTE FUNCTION verifier_email();



-- Test : tentative d’insertion d’un adresse email sans '@'
\echo '==> Test de verifier_email (doit produire une erreur) : '
UPDATE ETUDIANT
SET emailEtu = 'therage.example.com' -- Doit donner une erreur 
WHERE id_etudiant = 2;

SELECT * FROM situation WHERE id_etudiant = 2;


\echo '***************************************************************************'
\echo '=====> Création automatique d’une situation lors de l’ajout d’un étudiant'
\echo '==> Utilité : Aucun étudiant sans situation -> par défaut : Sans emploi .'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION creer_situation_par_defaut()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO SITUATION (id_etudiant, type_situation)
    VALUES (NEW.id_etudiant, 'Sans emploi');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_creer_situation
AFTER INSERT ON ETUDIANT
FOR EACH ROW
EXECUTE FUNCTION creer_situation_par_defaut();


\echo '==> Test de creer_situation_par_defaut : '
DELETE FROM ETUDIANT WHERE numEtu = 'E2021999';

INSERT INTO ETUDIANT (
    numEtu, numINE, civiliteEtu, prenomEtu, nomEtu,
    emailEtu, ddnEtu, departementEtu, diplome,    
    anneeDiplome, telephoneEtu, adresseEtu
) VALUES (
    'E2021999', 'INE999999Z', 'Monsieur', 'Test', 'Trigger',
    'test.trigger@mail.fr', '2001-01-01', 'Informatique',
    'BUT informatique', 2023, '0600000000', 'Adresse test'
);


SELECT type_situation
FROM SITUATION
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021999'
);




\echo '***************************************************************************'
\echo '=====> Nettoyage/ajout automatique des champs selon la situation'
\echo '==> Utilité : Si l’étudiant est Sans emploi, alors : poste = NULL entreprise = NULL diplomePrepare = NULL'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION nettoyer_situation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type_situation = 'Sans emploi' THEN
        NEW.poste := NULL;
        NEW.entreprise := NULL;
        NEW.diplomePrepare := NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_nettoyage_situation
BEFORE INSERT OR UPDATE ON situation
FOR EACH ROW
EXECUTE FUNCTION nettoyer_situation();

\echo '==> Test de nettoyer_situation : '

UPDATE SITUATION
SET 
    type_situation = 'Employé',
    poste = 'Développeur Java',
    entreprise = 'Capgemini',
    diplomePrepare = 'Master'
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021999'
);

\echo '=====> Employé | Développeur Java | Capgemini | Master'
SELECT type_situation, poste, entreprise, diplomePrepare
FROM SITUATION
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021999'
);

\echo 'Maintenant testons si en passant cet enregistrement en sans emploi, tout est null :'

UPDATE SITUATION
SET type_situation = 'Sans emploi'
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021999'
);

SELECT type_situation, poste, entreprise, diplomePrepare
FROM SITUATION
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021999'
);


\echo '***************************************************************************'
\echo '=====> Quand un étudiant est supprimé → sa situation et ses accords sont supprimés'
\echo '==> Utilité : Évite toute incohérence dans le projet'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION supprimer_donnees_associees()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM situation WHERE id_etudiant = OLD.id_etudiant;
    DELETE FROM accord WHERE id_etudiant = OLD.id_etudiant;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_supprimer_donnees
BEFORE DELETE ON ETUDIANT
FOR EACH ROW
EXECUTE FUNCTION supprimer_donnees_associees();

\echo '==> Test de supprimer_donnees_associees : '

DELETE FROM ETUDIANT WHERE numEtu = 'E2021008';

SELECT *
FROM ACCORD
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021008'
);


SELECT *
FROM SITUATION
WHERE id_etudiant = (
    SELECT id_etudiant FROM ETUDIANT WHERE numEtu = 'E2021008'
);

\echo '***************************************************************************'
\echo '=====> Contraintes métier selon le type de situation'
\echo '==> Utilité : garantir la cohérence des informations selon la situation'
\echo '***************************************************************************'

CREATE OR REPLACE FUNCTION verif_coherence_situation()
RETURNS TRIGGER AS $$
BEGIN
    -- Cas Employé
    IF NEW.type_situation = 'Employé' THEN
        IF NEW.poste IS NULL OR NEW.entreprise IS NULL THEN
            RAISE EXCEPTION 
            'Pour une situation "Employé", le poste et l entreprise doivent être renseignés';
        END IF;
    END IF;

    -- Cas En étude
    IF NEW.type_situation = 'En étude' THEN
        IF NEW.diplomePrepare IS NULL THEN
            RAISE EXCEPTION 
            'Pour une situation "En étude", le diplôme préparé doit être renseigné';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verif_coherence_situation
BEFORE INSERT OR UPDATE ON SITUATION
FOR EACH ROW
EXECUTE FUNCTION verif_coherence_situation();


\echo '==> Test invalide : Employé sans poste (doit échouer)'

UPDATE SITUATION
SET type_situation = 'Employé',
    poste = NULL,
    entreprise = 'Capgemini'
WHERE id_etudiant = 1;

\echo '==> Test invalide : En étude sans diplôme (doit échouer)'

UPDATE SITUATION
SET type_situation = 'En étude',
    diplomePrepare = NULL
WHERE id_etudiant = 1;


\echo '==> Test valide : Employé avec toutes les informations'

UPDATE SITUATION
SET type_situation = 'Employé',
    poste = 'Développeur Java',
    entreprise = 'Capgemini'
WHERE id_etudiant = 1;

SELECT type_situation, poste, entreprise
FROM SITUATION
WHERE id_etudiant = 1;























