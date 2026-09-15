<div id="top">

<!-- HEADER STYLE: CONSOLE -->
<div align="center">

```console
 ████    ██          ██████ ████   ████   
██      ████         ██   █ ██  ██ ██  ██ 
 ████  ██  ██ ██████ ██████ ██  ██ ██  ██ 
    ██ ██████        ██   █ ██  ██ ██  ██ 
█████  ██  ██        ██████ ████   ████   


```

</div>

<!-- BADGES -->
<img src="https://img.shields.io/github/license/LTherage/SA-BDD?style=flat-square&logo=opensourceinitiative&logoColor=white&color=336791" alt="license">
<img src="https://img.shields.io/github/last-commit/LTherage/SA-BDD?style=flat-square&logo=git&logoColor=white&color=336791" alt="last-commit">
<img src="https://img.shields.io/github/languages/top/LTherage/SA-BDD?style=flat-square&color=336791" alt="repo-top-language">
<img src="https://img.shields.io/github/languages/count/LTherage/SA-BDD?style=flat-square&color=336791" alt="repo-language-count">

<em>Built with the tools and technologies:</em>


</div>
<br>

## 🌈 Table of Contents

<details>
<summary>Table of Contents</summary>

- [🌈 Table of Contents](#-table-of-contents)
- [🔴 Overview](#-overview)
- [🟠 Features](#-features)
- [🟡 Project Structure](#-project-structure)
    - [🟢 Project Index](#-project-index)
- [🔵 Getting Started](#-getting-started)
    - [🟣 Prerequisites](#-prerequisites)
    - [⚫ Installation](#-installation)
    - [⚪ Usage](#-usage)
    - [🟤 Testing](#-testing)
- [🌟 Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)
- [✨ Acknowledgments](#-acknowledgments)

</details>

---

## 🔴 Overview

`SA-BDD` is a PostgreSQL database project designed to manage student information and career follow-up within a university context. The schema centralizes student records, their employment or study situation, and their consent to contact for vocational or academic follow-up.

The project uses SQL and PL/pgSQL to model the business rules of an IUT/departmental administrative environment: automatic updates, validation triggers, counts by year, insertion rate, and default situations. It also contains a dataset of sample students and a trace log showing the execution of the main functions.

---

## 🟠 Features

<code>❯ PostgreSQL schema with ETUDIANT, SITUATION and ACCORD tables</code>
<code>❯ Automatic triggers for validation, default values and data consistency</code>
<code>❯ PL/pgSQL functions for statistics and business checks</code>
<code>❯ Sample data for a student cohort and their employment status</code>
<code>❯ Execution trace showing tests and expected errors</code>

---

## 🟡 Project Structure

```sh
└── SA-BDD/
   ├── creation.sql
   ├── fonctions.sql
   └── trace.txt
```

### 🟢 Project Index

<details open>
	<summary><b><code>SA-BDD/</code></b></summary>
	<!-- __root__ Submodule -->
	<details>
		<summary><b>__root__</b></summary>
		<blockquote>
			<div class='directory-path' style='padding: 8px 0; color: #666;'>
				<code><b>⦿ __root__</b></code>
			<table style='width: 100%; border-collapse: collapse;'>
			<thead>
				<tr style='background-color: #f8f9fa;'>
					<th style='width: 30%; text-align: left; padding: 8px;'>File Name</th>
					<th style='text-align: left; padding: 8px;'>Summary</th>
				</tr>
			</thead>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/LTherage/SA-BDD/blob/master/trace.txt'>trace.txt</a></b></td>
					<td style='padding: 8px;'><code>❯ Execution log showing the SQL script output, validation checks and function results.</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/LTherage/SA-BDD/blob/master/fonctions.sql'>fonctions.sql</a></b></td>
					<td style='padding: 8px;'><code>❯ Business functions, triggers and constraints in PL/pgSQL for student tracking.</code></td>
				</tr>
				<tr style='border-bottom: 1px solid #eee;'>
					<td style='padding: 8px;'><b><a href='https://github.com/LTherage/SA-BDD/blob/master/creation.sql'>creation.sql</a></b></td>
					<td style='padding: 8px;'><code>❯ Creation of the SAE schema, tables and initial database dataset.</code></td>
				</tr>
			</table>
		</blockquote>
	</details>
</details>

---

## 🔵 Getting Started

### 🟣 Prerequisites

This project requires the following dependencies:

- **Database:** PostgreSQL with `psql`
- **Language:** SQL / PL/pgSQL
- **Optional:** a PostgreSQL client or application connected to the database

### ⚫ Installation

Build `SA-BDD` from the source and initialize the database:

1. **Clone the repository:**

   ```sh
   ❯ git clone https://github.com/LTherage/SA-BDD
   ```

2. **Navigate to the project directory:**

   ```sh
   ❯ cd SA-BDD
   ```

3. **Create the database and run the SQL scripts:**

   ```sh
   ❯ createdb sae
   ❯ psql -d sae -f creation.sql
   ❯ psql -d sae -f fonctions.sql
   ```

### ⚪ Usage

Run queries against the `SAE` schema, for example:

```sql
SELECT * FROM ETUDIANT;
SELECT * FROM SITUATION;
SELECT * FROM ACCORD;
SELECT nb_diplomes_par_annee(2023);
SELECT * FROM taux_insertion_par_departement();
```

The project is designed to demonstrate both data modeling and business logic in PostgreSQL.

### 🟤 Testing

The repository includes a validation flow directly in SQL scripts. To test the project:

```sh
❯ psql -d sae -f creation.sql
❯ psql -d sae -f fonctions.sql
```

The output in `trace.txt` records the execution of the main functions and the expected error cases for triggers and business constraints.

---

## 🌟 Roadmap

- [X] **`Schema`**: Create the `ETUDIANT`, `SITUATION` and `ACCORD` tables.
- [X] **`Data`**: Insert sample student data and representative situations.
- [X] **`Business logic`**: Implement PL/pgSQL functions and triggers.
- [X] **`Validation`**: Check data consistency, email format, annual graduation year, and default situation creation.
- [ ] **`Reporting`**: Add a more advanced dashboard or exports for institutional statistics.

---

## 🤝 Contributing

- **💬 [Join the Discussions](https://github.com/LTherage/SA-BDD/discussions)**: Share your insights, provide feedback, or ask questions.
- **🐛 [Report Issues](https://github.com/LTherage/SA-BDD/issues)**: Submit bugs found or log feature requests for the `SA-BDD` project.
- **💡 [Submit Pull Requests](https://github.com/LTherage/SA-BDD/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your GitHub account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/LTherage/SA-BDD
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b feature/student-status-report
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Add student status reporting SQL logic'
   ```
6. **Push to GitHub**: Push the changes to your forked repository.
   ```sh
   git push origin feature/student-status-report
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch.
</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="left">
   <a href="https://github.com/LTherage/SA-BDD/graphs/contributors">
      <img src="https://contrib.rocks/image?repo=LTherage/SA-BDD">
   </a>
</p>
</details>

---

## 📜 License

This repository does not currently include a dedicated `LICENSE` file. The project is therefore distributed without an explicit license declaration in the repository itself.

---

## ✨ Acknowledgments

- PostgreSQL and PL/pgSQL for the database engine and trigger system.
- The SAÉ/SQL project context for modeling a real university student follow-up use case.
- The project contributors and the educational environment that inspired the business rules.

<div align="right">

[![][back-to-top]](#top)

</div>


[back-to-top]: https://img.shields.io/badge/-BACK_TO_TOP-151515?style=flat-square


---
