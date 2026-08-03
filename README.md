# Smart Clinic Database System

## Project Status

**Completed**

The Smart Clinic Database System has been fully designed, implemented, tested, and documented for the Introduction to Database course project. The final solution includes the EER model, relational schema, MySQL implementation, Saudi-context sample data, required SQL operations, execution evidence, project reflection, progress report, and final report.

## Project Overview

A private outpatient clinic previously managed patient information manually, making it difficult to organize appointments, treatments, prescriptions, medicine inventory, and payments. This project provides a normalized relational database that improves data organization, retrieval, consistency, and reporting.

The system was implemented in **MySQL 8.0.16 or later** and tested through **MySQL Workbench**. It uses the InnoDB storage engine, `utf8mb4` character encoding, foreign-key enforcement, transactions, views, and triggers.

## Project Objectives

- Design a complete ER/EER model for a smart clinic.
- Convert the conceptual model into a normalized relational schema.
- Implement the database using MySQL.
- Apply primary keys, foreign keys, unique constraints, checks, and controlled values.
- Populate every main table with at least five logically connected fictional Saudi records.
- Execute and verify the required SQL operations.
- Provide readable MySQL Workbench evidence for tables and query results.
- Maintain an organized GitHub repository with meaningful commit history.

## Team Members

| Student Name | Student ID | Primary Contribution |
|---|---:|---|
| JOMANAH SAEED OTAIF | 250042243 | Group Leader, Repository Management, File Organization, README Updates, and Integration Review |
| Cyrine Abdullah Alghamdi | 240015574 | Database Design, Entity Analysis, Relationships, Cardinalities, EER Structure, Assumptions, and Normalization Review |
| Leen Sultan Al Shmmari | 240016807 | MySQL Schema Review, SQL Operations, View, Trigger, Transactions, Testing, and Execution Verification |
| Bedour Hamad Alrasheedi | 230009312 | MySQL Workbench Screenshots, Testing Evidence, Report Formatting, Quality Review, and Submission Checklist |

## Database Design

The database contains **11 normalized tables**:

| Table | Purpose |
|---|---|
| `person` | Stores shared identity and contact information. |
| `patient` | Stores patient registration, blood type, allergies, and emergency-contact details. |
| `employee` | Stores shared employment information for clinic staff. |
| `doctor` | Stores doctor licenses, specialties, rooms, and consultation fees. |
| `receptionist` | Stores receptionist shifts and extension numbers. |
| `appointment` | Links patients and doctors at scheduled times. |
| `treatment` | Stores diagnoses, treatment notes, and follow-up dates. |
| `prescription` | Stores prescriptions issued for treatments. |
| `prescription_item` | Resolves the prescription-to-medicine relationship and stores dosage details. |
| `medicine` | Stores medicine details, stock quantities, reorder levels, and prices. |
| `payment` | Stores one or more payments associated with appointments. |

## EER Specialization

The project implements a two-level specialization hierarchy:

```text
Person
|-- Patient
`-- Employee
    |-- Doctor
    `-- Receptionist
```

The specialization is modeled as **total and disjoint**. Subtype identifiers are reused as both primary keys and foreign keys, which avoids repeating identity and contact attributes.

## Main Relationships

- One patient can have many appointments.
- One doctor can attend many appointments.
- One appointment can create one or more treatment records.
- One treatment can have zero or one prescription.
- One prescription contains one or more prescription items.
- One medicine can appear in many prescription items.
- One appointment can have zero, one, or multiple payment records.

## Main Features

- Eleven normalized MySQL tables.
- Primary-key and foreign-key enforcement.
- `NOT NULL`, `UNIQUE`, `CHECK`, and `ENUM` constraints.
- Unique doctor scheduling at the same timestamp.
- Fictional Saudi names, `+966` telephone formats, Gmail addresses, and Saudi cities.
- Multiple payments per appointment for partial, insurance, and mixed-payment scenarios.
- Composite primary key in `prescription_item`.
- Transaction-based testing using `START TRANSACTION` and `ROLLBACK`.
- MySQL Workbench screenshots for database creation, table population, SQL code, and query results.

## SQL Operations Completed

The final SQL script includes and verifies:

- Basic `SELECT` statements.
- Multi-table `JOIN` queries.
- Nested queries.
- Aggregate functions with `GROUP BY`.
- `UPDATE` statements.
- `DELETE` statements.
- A reporting `VIEW`.
- A stock-control `TRIGGER`.

### Reporting View

```text
vw_appointment_summary
```

The view provides one reporting row per appointment with patient, doctor, specialty, reason, appointment status, consultation fee, amount paid, and calculated payment status.

### Stock-Control Trigger

```text
trg_prescription_item_before_insert
```

Before inserting a prescription item, the trigger:

1. Reads the current medicine stock.
2. Rejects an invalid medicine reference.
3. Rejects non-positive prescription quantities.
4. Prevents a prescription quantity from exceeding available stock.
5. Deducts the approved quantity from medicine inventory.

## System Workflow

1. A person record is created.
2. The person is registered as either a patient or an employee.
3. An employee is further registered as either a doctor or receptionist.
4. An appointment links one patient with one doctor at a scheduled date and time.
5. A treatment record is created for a valid appointment.
6. A prescription may be issued for the treatment.
7. Prescription items identify the required medicines, dosage, frequency, duration, and quantity.
8. The trigger validates and deducts medicine stock automatically.
9. One or more payments may be recorded for the appointment.
10. The reporting view combines appointment, patient, doctor, and payment information.

## Business Rules and Assumptions

- The clinic operates as one physical branch with one shared medicine inventory.
- Every appointment belongs to exactly one patient and one doctor.
- A doctor cannot have two appointments at the same timestamp.
- A treatment must belong to a valid appointment.
- A treatment has at most one prescription.
- A prescription may contain multiple medicines.
- Partial payments and multiple payments are allowed.
- Medicine stock is reduced when a prescription item is inserted.
- `person_type` and `employee_role` support subtype integrity.

## Repository Structure

```text
Smart-Clinic-Database-System/
|-- README.md
|-- database/
|   `-- smart_clinic_database.sql
|-- docs/
|   |-- Smart_Clinic_Mid_Project_Progress_Report.docx
|   |-- Smart_Clinic_Mid_Project_Progress_Report.pdf
|   |-- Introduction to DB-Course Project v2 (Finale Report).docx
|   `-- Introduction to DB-Course Project v2 (Finale Report).pdf
|-- diagrams/
|   `-- smart_clinic_erd.png
`-- evidence/
    `-- screenshots/
```

## How to Run the Project

1. Install MySQL Server 8.0.16 or later.
2. Install and open MySQL Workbench.
3. Open `database/smart_clinic_database.sql`.
4. Connect using an account with permission to create databases, tables, views, and triggers.
5. Execute the script from top to bottom.
6. Confirm that the database `smart_clinic_db` is created.
7. Confirm that the database contains 11 tables.
8. Run the verification statements at the end of the script.
9. Confirm that `vw_appointment_summary` and `trg_prescription_item_before_insert` exist.
10. Review the evidence in `evidence/screenshots/`.

## Testing and Evidence

The implementation was executed in MySQL Workbench. The evidence includes:

- Database and table creation.
- Supertype and subtype definitions.
- Foreign keys and constraints.
- Population of all main tables.
- Verification of 11 database tables.
- SELECT, JOIN, nested, and GROUP BY results.
- UPDATE and DELETE demonstrations.
- Transaction rollback verification.
- View output.
- Trigger creation and medicine-stock deduction testing.

## Project Deliverables

- Complete MySQL database script.
- ER/EER diagram.
- Mid-project progress report in Word and PDF formats.
- Final project report in Word and PDF formats.
- MySQL Workbench execution screenshots.
- GitHub repository with meaningful commit history.

## Project Artifacts

- **GitHub Repository:** https://github.com/ProjectGroup-alt/Smart-Clinic-Database-System
- **Live Report Folder:** https://drive.google.com/drive/folders/1D4glyIDAZpNQ6mAKQrBYw34vhKFkBGym
- **Google Colab:** Not applicable.

## Academic Notice

All patient, employee, appointment, treatment, medicine, prescription, and payment data in this repository are fictional and were created only for academic coursework.
