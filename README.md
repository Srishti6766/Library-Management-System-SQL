# Smart Library Management System **:**

A structured SQL-based system to manage library operations including books, users, borrowing records, and fine calculations. Designed to streamline traditional library workflows with optimized query management.

## Project Duration
**Mar 2025 – Apr 2025**

## Tech Stack **:**
- SQL
- MySQL

## Features **:**
- Efficient database schema for books, members, and transactions.
- Query-based access to:
  - Book availability
  - Borrow and return records
  - Fine calculation for late returns
- Normalized tables to avoid redundancy and ensure data integrity.

## Database Tables **:**
- `Books`: Stores book details like ID, title, author, genre, and availability.
- `Users`: Contains user ID, name, email, and user role (student/staff).
- `Borrow_Records`: Tracks borrow and return dates, fine status, and overdue information.

## SQL Queries Implemented **:**
- Check availability of a book.
- Retrieve borrowing history for a user.
- Calculate and update fines for overdue books.
- Add or remove books/users from the system.
