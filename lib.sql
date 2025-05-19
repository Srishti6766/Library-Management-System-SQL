-- Books Table
CREATE TABLE books (
    book_id NUMBER PRIMARY KEY,
    title VARCHAR2(100),
    author VARCHAR2(100),
    total_copies NUMBER,
    available_copies NUMBER
);

-- Members Table
CREATE TABLE members (
    member_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100)
);

-- Transactions Table
CREATE TABLE transactions (
    txn_id NUMBER PRIMARY KEY,
    book_id NUMBER REFERENCES books(book_id),
    member_id NUMBER REFERENCES members(member_id),
    issue_date DATE,
    return_date DATE
);

-- Insert 15 rows
INSERT INTO books VALUES (1, 'To Kill a Mockingbird', 'Harper Lee', 10, 4);
INSERT INTO books VALUES (2, '1984', 'George Orwell', 8, 5);
INSERT INTO books VALUES (3, 'The Great Gatsby', 'F. Scott Fitzgerald', 12, 7);
INSERT INTO books VALUES (4, 'Pride and Prejudice', 'Jane Austen', 9, 3);
INSERT INTO books VALUES (5, 'The Catcher in the Rye', 'J.D. Salinger', 11, 6);
INSERT INTO books VALUES (6, 'The Hobbit', 'J.R.R. Tolkien', 15, 10);
INSERT INTO books VALUES (7, 'Fahrenheit 451', 'Ray Bradbury', 7, 2);
INSERT INTO books VALUES (8, 'Moby-Dick', 'Herman Melville', 6, 1);
INSERT INTO books VALUES (9, 'The Odyssey', 'Homer', 13, 8);
INSERT INTO books VALUES (10, 'Jane Eyre', 'Charlotte Brontë', 10, 5);
INSERT INTO books VALUES (11, 'Brave New World', 'Aldous Huxley', 14, 9);
INSERT INTO books VALUES (12, 'Wuthering Heights', 'Emily Brontë', 8, 4);
INSERT INTO books VALUES (13, 'Crime and Punishment', 'Fyodor Dostoevsky', 9, 6);
INSERT INTO books VALUES (14, 'The Brothers Karamazov', 'Fyodor Dostoevsky', 10, 5);
INSERT INTO books VALUES (15, 'Les Misérables', 'Victor Hugo', 12, 7);


-- Members
INSERT INTO members VALUES (1, 'Alice Johnson', 'alice.johnson@example.com');
INSERT INTO members VALUES (2, 'Bob Smith', 'bob.smith@example.com');
INSERT INTO members VALUES (3, 'Charlie Brown', 'charlie.brown@example.com');
INSERT INTO members VALUES (4, 'Diana Prince', 'diana.prince@example.com');
INSERT INTO members VALUES (5, 'Ethan Hunt', 'ethan.hunt@example.com');
INSERT INTO members VALUES (6, 'Fiona Gallagher', 'fiona.gallagher@example.com');
INSERT INTO members VALUES (7, 'George Martin', 'george.martin@example.com');
INSERT INTO members VALUES (8, 'Hannah Davis', 'hannah.davis@example.com');
INSERT INTO members VALUES (9, 'Isaac Newton', 'isaac.newton@example.com');
INSERT INTO members VALUES (10, 'Julia Roberts', 'julia.roberts@example.com');
CREATE OR REPLACE PROCEDURE borrow_book (
    p_book_id IN NUMBER,
    p_member_id IN NUMBER
) AS
    v_available NUMBER;
    v_txn_id NUMBER;
BEGIN
    -- Check availability
    SELECT available_copies INTO v_available FROM books WHERE book_id = p_book_id;

    IF v_available > 0 THEN
        -- Generate txn ID
        SELECT NVL(MAX(txn_id), 0) + 1 INTO v_txn_id FROM transactions;

        -- Insert transaction
        INSERT INTO transactions (txn_id, book_id, member_id, issue_date)
        VALUES (v_txn_id, p_book_id, p_member_id, SYSDATE);

        -- Update available copies
        UPDATE books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;

        DBMS_OUTPUT.PUT_LINE('Book issued successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Book not available.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid book ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;


CREATE OR REPLACE PROCEDURE return_book (
    p_book_id IN NUMBER,
    p_member_id IN NUMBER
) AS
    v_txn_id NUMBER;
BEGIN
    -- Find active transaction
    SELECT txn_id INTO v_txn_id FROM transactions
    WHERE book_id = p_book_id AND member_id = p_member_id AND return_date IS NULL;

    -- Update return date
    UPDATE transactions SET return_date = SYSDATE WHERE txn_id = v_txn_id;

    -- Update available copies
    UPDATE books SET available_copies = available_copies + 1 WHERE book_id = p_book_id;

    DBMS_OUTPUT.PUT_LINE('Book returned successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No active borrow found for this member and book.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE show_overdue_books AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Overdue Books (More than 7 days):');
    FOR rec IN (
        SELECT 
            m.name AS member_name,
            b.title AS book_title,
            t.issue_date,
            (SYSDATE - t.issue_date) AS days_borrowed,
            ((SYSDATE - t.issue_date) - 7) * 10 AS fine_amount
        FROM 
            transactions t
        JOIN members m ON t.member_id = m.member_id
        JOIN books b ON t.book_id = b.book_id
        WHERE 
            t.return_date IS NULL
            AND SYSDATE - t.issue_date > 7
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Member: ' || rec.member_name || 
                             ', Book: ' || rec.book_title || 
                             ', Issued: ' || TO_CHAR(rec.issue_date, 'DD-MON-YYYY') || 
                             ', Days: ' || rec.days_borrowed || 
                             ', Fine: ₹' || rec.fine_amount);
    END LOOP;
END;
/

BEGIN
    borrow_book(6, 5);
END;
/

SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM transactions;

BEGIN
    return_book(6, 5);
END;
/

BEGIN
    show_overdue_books;
END;
/