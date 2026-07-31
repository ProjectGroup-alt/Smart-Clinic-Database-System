# Smart Clinic Database System

A normalized MySQL database for a fictional private outpatient clinic in the Kingdom of Saudi Arabia. The system manages patients, staff, appointments, treatments, prescriptions, medicine inventory, and payments.

## Team Members

| Student Name | Student ID | Role |
|---|---:|---|
| JOMANAH SAEED OTAIF | 250042243 | Group Leader and Repository Manager |
| Cyrine Abdullah Alghamdi | 240015574 | Database Design and EER Documentation |
| Leen Sultan Al Shmmari | 240016807 | SQL Implementation and Testing |
| Bedour Hamad Alrasheedi | 230009312 | Screenshots, Reports, and Quality Review |

## Main Features

- EER specialization: `Person -> Patient / Employee` and `Employee -> Doctor / Receptionist`.
- Eleven normalized tables with primary keys, foreign keys, unique constraints, checks, and controlled values.
- At least five sample records in every table using fictional Saudi names and contact data.
- Required SQL operations: SELECT, JOIN, nested query, aggregate functions with GROUP BY, UPDATE, DELETE, VIEW, and TRIGGER.
- A reporting view named `vw_appointment_summary`.
- A trigger named `trg_prescription_item_before_insert` that validates and deducts medicine stock.
- Transaction and ROLLBACK evidence for reversible demonstrations.

## Repository Structure

```text
Smart-Clinic-Database-System/
|-- README.md
|-- database/
|   `-- smart_clinic_database.sql
|-- docs/
|   |-- Smart_Clinic_Final_Report.docx
|   |-- Smart_Clinic_Mid_Project_Progress_Report.docx
|   `-- Smart_Clinic_Team_Contribution_Record.docx
|-- diagrams/
|   `-- smart_clinic_erd.png
`-- evidence/
    `-- screenshots/
```

## How to Run

1. Install MySQL Server 8.0.16 or later and MySQL Workbench.
2. Open `database/smart_clinic_database.sql` in MySQL Workbench.
3. Connect using an account with permission to create databases, tables, views, and triggers.
4. Execute the full script from top to bottom.
5. Confirm that `smart_clinic_db` contains 11 tables and `vw_appointment_summary`.
6. Run the verification statements at the end of the script.

## Database Objects

`person`, `patient`, `employee`, `doctor`, `receptionist`, `appointment`, `treatment`, `medicine`, `prescription`, `prescription_item`, and `payment`.
