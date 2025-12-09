# Practical Exercise: Library Management System - Odoo 18

## General Objective

Create a complete module in Odoo 18 called **"library"** that implements a book lending management system. This exercise will allow you to practice and consolidate all fundamental concepts of the Odoo 18 server framework in a different context from the official tutorial.

---

## System Description

The library of an educational center needs to digitalize its book lending process. The system must allow librarians to register books in the catalog, manage library members, and control the complete lending process from request to return.

---

## Functional Requirements

### 1. Book Management (Model: Book)

The system must allow registering books with the following information:

- **Title** (required, short text)
- **Author** (required, linked to Odoo contacts - `res.partner`)
- **ISBN** (unique code, short text, required)
- **Publication Year** (integer)
- **Total Number of Copies** (integer, required)
- **Description** (long text, optional)
- **Category** (short text, optional - e.g.: Fiction, Technology, History, etc.)

**Required calculated fields:**

- **Available Copies** (calculated as: total copies - currently borrowed copies)
- **Borrowed Copies** (calculated by counting active loans of this book)

**Important note:** Do not store the number of available copies directly; calculate it from active loans.

---

### 2. Member Management (Using res.partner)

The system reuses Odoo's standard `res.partner` model to represent library members. A member is simply a contact that has associated loans.

**You do not need to create a separate member model.** Simply link loans to `res.partner` using many2one fields.

---

### 3. Loan Management (Model: Loan)

This is the central model of the system. It records each lending transaction:

- **Book** (many2one to Book, required)
- **Member** (many2one to res.partner, required)
- **Loan Start Date** (required, automatically filled with current date)
- **Expected Return Date** (automatically calculated to 14 days from start)
- **Actual Return Date** (optional, filled when member returns the book)
- **Status** (one of: Requested, Active, Overdue, Completed, Cancelled)
- **Notes** (optional text for librarian notes)

**Required calculated fields:**

- **Days Remaining** (only if loan is active, calculated as: expected date - today)
- **Automatic "Overdue" Status** (a loan in Active status that has exceeded its return date should show Overdue status; you can do this with a calculated field or manual button)

**Required validations:**

- Cannot create a loan if there are no available copies of the book
- Cannot create a loan of a book that the member already has active (prevent lending same book twice)
- The actual return date cannot be earlier than the start date

---

### 4. State Transitions

Loans follow a well-defined lifecycle:

```
Requested â†’ Active â†’ Completed
              â†˜
               Overdue â†’ Completed
              â†—
            Cancelled
```

**Allowed transitions:**

- Requested â†’ Active (button "Confirm Loan")
- Active â†’ Completed (button "Register Return")
- Active â†’ Cancelled (button "Cancel Loan")
- Overdue â†’ Completed (button "Register Return")

**Transition validations:**

- Cannot confirm a loan that is already active, cancelled, or completed
- Cannot complete a loan that is in Requested status
- Cannot cancel a completed loan

---

## Interface Requirements

### List Views

**Book List View:**

- Display: Title, Author, ISBN, Year, Total Copies, Available Copies
- Sort: by title alphabetically
- Search: allow filtering by author, ISBN, category

**Loan List View:**

- Display: Book, Member, Start Date, Expected Return Date, Status, Days Remaining
- Sort: by start date descending (most recent first)
- Color decorations:
  - Red for overdue loans
  - Green for completed loans
  - Yellow for active loans
  - Gray for cancelled loans
- Default filters: show only active and overdue loans (do not show completed and cancelled by default)

### Form Views

**Book Form View:**

- One sheet with two sections (groups):
  - Basic information: title, author, ISBN, year
  - Details: total copies, available copies (read-only), description, category
- One additional tab showing all loans of this book (one2many nested)

**Loan Form View:**

- A header with:
  - Status transition buttons (only visible according to current status)
  - Status field displayed as statusbar
- One sheet with:
  - First section: book, member, notes
  - Second section: dates (start, expected return, actual return)
  - Third section (only visible if active): days remaining
- Conditional behavior:
  - "Confirm Loan" button only visible if status is Requested
  - "Register Return" button only visible if status is Active or Overdue
  - "Cancel Loan" button only visible if status is Requested or Active
  - Actual return date only editable if status is Active or Overdue

### Search View

**Loan Search View:**

- Search fields: book, member, status
- Predefined filters:
  - "Active Loans" (status = Active)
  - "Overdue Loans" (status = Overdue)
  - "Pending Return" (status in [Active, Overdue])
- Grouping: allow grouping by status or by member

---

## Technical Requirements

### Folder Structure

```
library/
â”œâ”€â”€ models/
â”‚   â”œâ”€â”€ __init__.py
â”‚   â”œâ”€â”€ book.py
â”‚   â””â”€â”€ loan.py
â”œâ”€â”€ security/
â”‚   â””â”€â”€ ir.model.access.csv
â”œâ”€â”€ views/
â”‚   â””â”€â”€ library_views.xml
â”œâ”€â”€ __init__.py
â””â”€â”€ __manifest__.py
```

### **manifest**.py File

Must include:

- Name: "Library Management"
- Dependencies: ["base"]
- Installable: True
- Application: True (to appear in Apps)
- Category: "Tools" (or your preference)
- List of data files in correct order

### Security

- Create an `ir.model.access.csv` file that grants full permissions (read, write, create, delete) to the `base.group_user` group for all models
- Follow naming convention: `access_<model>_<group>`

### Naming Conventions

Follow Odoo conventions:

- Many2one models end in `_id` (singular)
- Many2many and one2many models end in `_ids` (plural)
- Private methods start with `_`
- Public methods (callable from UI) do not have `_`
- Calculated fields are defined with `compute="private_method"`

---

## Business Logic Requirements

### Calculated Fields

1. **Book.available_copies** - Number of copies available for lending
2. **Book.borrowed_copies** - Number of copies currently borrowed
3. **Loan.days_remaining** - Days remaining for return (only if loan is active)

### Action Methods

1. **Loan.action_confirm()** - Changes status from Requested to Active, validates available copies
2. **Loan.action_return()** - Changes status to Completed, registers actual return date
3. **Loan.action_cancel()** - Changes status to Cancelled, validates that it is permitted

### Validations

- **Availability validation:** When confirming a loan, verify that there are available copies
- **Duplicate validation:** A member cannot have two active loans of the same book
- **Date validation:** Actual return date cannot be earlier than start date
- **Transition validation:** State transitions are only valid according to the specified diagram

### Onchanges (if necessary)

- **Loan.onchange_book:** When a book is selected, automatically show how many copies are available (optional but useful for UX)

---

## Evaluation Criteria

Your exercise will be considered complete when:

1. âœ“ The module installs without errors
2. âœ“ Books can be created with all required fields
3. âœ“ Loans can be created and copy availability is validated
4. âœ“ State transitions work with the correct buttons
5. âœ“ Calculated fields show correct values
6. âœ“ Views have the specified design with decorations and conditional visibility
7. âœ“ Search allows efficient filtering
8. âœ“ Code follows Odoo conventions
9. âœ“ No warnings in logs when updating the module
10. âœ“ Interface is intuitive and professional

---

## Recommended Steps

To avoid feeling overwhelmed, follow this order:

1. Plan on paper what models, fields, and relationships you need
2. Create the module's base structure (directories and `__manifest__.py`)
3. Define the models with their basic fields (without logic yet)
4. Add security (`ir.model.access.csv`)
5. Create basic views (simple lists and forms)
6. Add calculated fields
7. Add action methods and validations
8. Improve views with decorations, filters, and conditional visibility
9. Test the system completely

---

## Important Notes

- **Do not reuse code from the real estate tutorial.** Although the structure is similar, writing the code from scratch is what will allow you to learn.
- **Test incrementally.** After each phase (models, views, logic), restart the server and verify that it works.
- **Read the logs carefully.** Odoo warnings will tell you exactly what is missing.
- **Official documentation is your friend.** When you have doubts about XML or Python syntax, consult https://www.odoo.com/documentation/18.0/developer/
- **Don't memorize, understand.** You don't need to memorize all the syntax. Understand the concept and search for the syntax when you need it.

---

## Optional Extensions (For Later)

If you finish early and want to practice more:

1. Add a "Fine" model for overdue loans, with automatic calculation of amounts
2. Add a "Reservation" model for members who want an unavailable book
3. Create a report showing statistics: most borrowed books, members with most loans, etc.
4. Add automatic notifications when a loan is about to expire (requires knowledge of Odoo notifications)

---

## Good Luck!

This is a challenging but completely achievable exercise with what you've learned. Remember that learning to develop in Odoo is a process, and every line of code you write will make you better.