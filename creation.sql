DROP SCHEMA IF EXISTS SAE CASCADE;
CREATE SCHEMA SAE;
SET search_path TO SAE;

DROP TABLE IF EXISTS SITUATION;
DROP TABLE IF EXISTS ETUDIANT;
DROP TABLE IF EXISTS ACCORD;

-- Table étudiant

CREATE TABLE ETUDIANT (
    id_etudiant SERIAL PRIMARY KEY,
    numEtu VARCHAR(50) NOT NULL,
    numINE VARCHAR(50) NOT NULL,
    civiliteEtu VARCHAR(50) NOT NULL,
    prenomEtu VARCHAR(50) NOT NULL,
    nomEtu VARCHAR(50) NOT NULL,
    emailEtu VARCHAR(100) UNIQUE NOT NULL,
    ddnEtu DATE NOT NULL,
    departementEtu VARCHAR(30) NOT NULL,
    diplome VARCHAR(50) NOT NULL CHECK (diplome IN ('BUT informatique', 'BUT GEA', 'BUT MMI', 'BUT TC', 'DUT santé')),
    anneeDiplome INT NOT NULL,
    telephoneEtu VARCHAR(30) NOT NULL,
    adresseEtu VARCHAR(30) NOT NULL,
    UNIQUE (numEtu, numINE)
);



-- Table situation
CREATE TABLE SITUATION (
    id_situation SERIAL PRIMARY KEY,
    id_etudiant INT NOT NULL REFERENCES ETUDIANT(id_etudiant) ON DELETE CASCADE,
    type_situation VARCHAR(30) NOT NULL
        CHECK (type_situation IN ('Employé', 'En étude', 'Sans emploi')),
    poste TEXT,
    entreprise TEXT,
    diplomePrepare VARCHAR(50)
        CHECK (diplomePrepare IN (
            'Master',
            'Licence professionnelle',
            'École d’ingénieur',
            'Doctorat',
            'Autre'
        )),
    date_maj DATE DEFAULT CURRENT_DATE
);


-- Table accord
CREATE TABLE ACCORD (
    id_accord SERIAL PRIMARY KEY,
    id_etudiant INT UNIQUE REFERENCES ETUDIANT(id_etudiant) ON DELETE CASCADE,
    accord_vacataire BOOLEAN NOT NULL,
    accord_stage BOOLEAN NOT NULL,
    accord_ceremonie BOOLEAN NOT NULL
);

-- Insertion de données

INSERT INTO ETUDIANT (
    numEtu, numINE, civiliteEtu, prenomEtu, nomEtu,
    emailEtu, ddnEtu, departementEtu, diplome,
    anneeDiplome, telephoneEtu, adresseEtu
) VALUES
('E2021001', 'INE123456A', 'Monsieur', 'Lucas', 'Durand',
 'lucas.durand@mail.fr', '2001-05-12', 'Informatique',
 'BUT informatique', 2023, '0612345678', '12 rue de Lille'),

('E2021002', 'INE654321B', 'Madame', 'Emma', 'Martin',
 'emma.martin@mail.fr', '2000-09-03', 'Gestion',
 'BUT GEA', 2022, '0698765432', '8 avenue de Lens'),

('E2021003', 'INE789456C', 'Monsieur', 'Hugo', 'Lefevre',
 'hugo.lefevre@mail.fr', '1999-11-20', 'Multimédia',
 'BUT MMI', 2021, '0601020304', '5 boulevard Jean Jaurès'),
 
 ('E2021004', 'INE321654D', 'Madame', 'Chloé', 'Moreau',
 'chloe.moreau@mail.fr', '2002-02-14', 'Commerce',
 'BUT TC', 2023, '0611223344', '10 rue de Paris'),

('E2021005', 'INE987654E', 'Monsieur', 'Nathan', 'Petit',
 'nathan.petit@mail.fr', '2001-07-22', 'Santé',
 'DUT santé', 2022, '0655667788', '15 avenue Victor Hugo'),

('E2021006', 'INE456123F', 'Monsieur', 'Leo', 'Roux',
 'leo.roux@mail.fr', '2000-12-01', 'Informatique',
 'BUT informatique', 2023, '0677889900', '22 rue de Lyon'),

('E2021007', 'INE654987G', 'Madame', 'Léa', 'Fournier',
 'lea.fournier@mail.fr', '2001-04-18', 'Gestion',
 'BUT GEA', 2022, '0622334455', '3 boulevard Gambetta'),

('E2021008', 'INE321987H', 'Monsieur', 'Mathis', 'Gauthier',
 'mathis.gauthier@mail.fr', '2000-10-30', 'Multimédia',
 'BUT MMI', 2021, '0612341122', '7 rue Nationale'),

('E2021009', 'INE789123I', 'Madame', 'Camille', 'Blanc',
 'camille.blanc@mail.fr', '2002-06-15', 'Commerce',
 'BUT TC', 2023, '0633445566', '9 avenue de la République'),

('E2021010', 'INE147258J', 'Monsieur', 'Alexis', 'Dupont',
 'alexis.dupont@mail.fr', '2001-09-09', 'Santé',
 'DUT santé', 2022, '0644556677', '11 rue de Strasbourg'),

('E2021011', 'INE258369K', 'Madame', 'Sarah', 'Faure',
 'sarah.faure@mail.fr', '2000-01-25', 'Informatique',
 'BUT informatique', 2023, '0611223345', '14 rue de Metz'),

('E2021012', 'INE369258L', 'Monsieur', 'Tom', 'Mercier',
 'tom.mercier@mail.fr', '2001-03-12', 'Gestion',
 'BUT GEA', 2022, '0699887766', '18 avenue de Nancy'),

('E2021013', 'INE741852M', 'Madame', 'Julie', 'Henry',
 'julie.henry@mail.fr', '2000-11-05', 'Multimédia',
 'BUT MMI', 2021, '0611226677', '6 boulevard Saint-Martin'),

('E2021014', 'INE852963N', 'Monsieur', 'Louis', 'Vidal',
 'louis.vidal@mail.fr', '2002-08-21', 'Commerce',
 'BUT TC', 2023, '0655778899', '2 rue Lafayette'),

('E2021015', 'INE963852O', 'Madame', 'Inès', 'Perrot',
 'ines.perrot@mail.fr', '2001-05-07', 'Santé',
 'DUT santé', 2022, '0644332211', '20 avenue Jean Moulin');


INSERT INTO SITUATION (
id_etudiant, type_situation, poste, entreprise, diplomePrepare
) VALUES
-- Diplômés en emploi
(1, 'Employé', 'Développeur Java', 'Capgemini', NULL),
(5, 'Employé', 'Infirmier', 'Hôpital Saint-Louis', NULL),
(6, 'Employé', 'Développeur Web', 'Atos', NULL),
(10, 'Employé', 'Assistant médical', 'Clinique de Lille', NULL),
(11, 'Employé', 'Développeur Java', 'Sopra Steria', NULL),
(15, 'Employé', 'Aide-soignante', 'Centre Hospitalier', NULL),

-- Diplômés poursuivant des études (post-BUT / post-DUT)
(2, 'En étude', NULL, NULL, 'Master'),
(4, 'En étude', NULL, NULL, 'Licence professionnelle'),
(7, 'En étude', NULL, NULL, 'Master'),
(9, 'En étude', NULL, NULL, 'École d’ingénieur'),
(12, 'En étude', NULL, NULL, 'Master'),
(14, 'En étude', NULL, NULL, 'Licence professionnelle'),

-- Diplômés sans emploi
(3, 'Sans emploi', NULL, NULL, NULL),
(8, 'Sans emploi', NULL, NULL, NULL),
(13, 'Sans emploi', NULL, NULL, NULL);

INSERT INTO ACCORD (
    id_etudiant,
    accord_vacataire,
    accord_stage,
    accord_ceremonie
) VALUES
(1, TRUE,  TRUE,  FALSE),   
(2, FALSE, TRUE,  TRUE),    
(3, FALSE, FALSE, FALSE),
(4, FALSE, TRUE, TRUE),
(5, TRUE, TRUE, FALSE),
(6, TRUE, FALSE, FALSE),
(7, FALSE, TRUE, TRUE),
(8, FALSE, FALSE, FALSE),
(9, TRUE, TRUE, TRUE),
(10, TRUE, FALSE, TRUE),
(11, TRUE, TRUE, FALSE),
(12, FALSE, TRUE, TRUE),
(13, FALSE, FALSE, FALSE),
(14, FALSE, TRUE, TRUE),
(15, TRUE, TRUE, TRUE);


\echo '***************************************************************************'
\echo '=====> Voici le contenu de la table ETUDIANT'
\echo '***************************************************************************'

SELECT * FROM ETUDIANT;

\echo '***************************************************************************'
\echo '=====> Voici le contenu de la table SITUATION'
\echo '***************************************************************************'

SELECT * FROM SITUATION;

\echo '***************************************************************************'
\echo '=====> Voici le contenu de la table ACCORD'
\echo '***************************************************************************'

SELECT * FROM ACCORD;

