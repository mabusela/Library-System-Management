# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select  *  from books;
```
**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address = '63 thuthuka street'
where member_id = 'C101';
select * from members
where member_id = 'C101; -- to see if the record was updated.  
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select i.issued_member_id,
       m.member_name,
     count(*) as number_of_books
  from issued_status as i
  join members as m 
  on i.issued_member_id = m.member_id
  group by i.issued_member_id,m.member_name
  having  number_of_books > 1
  order by 3 DESC;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table total_book_issued_cnt
as 
select 
	b.isbn,
    b.book_title,
    count(ist.issued_id) as number_issued
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1,2;

select * from total_book_issued_cnt;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select * from books
where category = 'Children';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select category,
sum(rental_price) as rental_income,
count(*) as no_of_times_book_issued
from books as b 
join issued_status as ist
on b.isbn = ist.issued_book_isbn
group by 1
order by 1 DESC;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select * from members
where reg_date >= current_date() - interval 180 DAY;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select 
    emp1.*,
    br.*,
    emp2.emp_name as manager
from employee as emp1
join branch as br 
on emp1.branch_id = br.branch_id
join employee emp2
on br.manager_id = emp2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table books_rental_price_greater_than_seven
as
select * from books
where rental_price > 7;

select * from books_rental_price_greater_than_seven;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
    m.member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    DATEDIFF(CURRENT_DATE, ist.issued_date) AS over_due_date
FROM issued_status AS ist
JOIN members AS m
    ON m.member_id = ist.issued_member_id
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND DATEDIFF(CURRENT_DATE, ist.issued_date) > 30
order by 1;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

DROP PROCEDURE IF EXISTS add_return_records;

DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id     VARCHAR(10),
    IN p_issued_id     VARCHAR(10),
    IN p_book_quality  VARCHAR(15)
)
BEGIN
    -- Declared variables
    DECLARE v_isbn VARCHAR(25);
    DECLARE v_book_name VARCHAR(100);

    -- Inserting into return_status based on user input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Selecting the ISBN and book name for the returned book
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Updating the status to 'yes' on the books table
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Display a message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END $$

DELIMITER ;

call add_return_records('RS138','IS135','Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

-- Testing the function add_return_records
select * from issued_status
where issued_id = 'IS135';

select *  from books
where isbn = '978-0-307-58837-1';

select * from return_status
where issued_id = 'IS135';

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

create Table active_members
as 
select * from members
where member_id IN(
select 
	distinct(issued_member_id)
 from issued_status
where 
	issued_date > current_date() - INTERVAL 45 month -- I have changed the number of months to have data,  you can update the records to the currect year to get data
);

select * from active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
 select 
         emp.emp_name,
         br.*,
         count(ist.issued_id) as number_book_issued
    from issued_status as ist
    join 
    employee as emp
    on emp.emp_id = ist.issued_emp_id
    join branch as br
    on emp.branch_id = br.branch_id
    group by 1,2;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

 DELIMITER $$
CREATE procedure issue_book(
		IN p_issued_id varchar(10),
        IN p_issued_member_id  varchar(10), 
        IN p_issued_book_isbn  varchar(25),
        IN p_issued_emp_id  varchar(10)
        )

BEGIN 
-- All the variables
  DECLARE v_status  varchar(5);
   -- All the logic goes here 
		-- checking if book is available 'yes'
        select 
			status
            into
            v_status
		from books 
        where isbn = p_issued_book_isbn;
	IF  v_status = 'yes' then
		insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn,issued_emp_id)
		values
			(p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);
         update books
         set status = 'no'
         where isbn = p_issued_book_isbn;
            -- Display a message
           SELECT CONCAT('Book records added successfully for book isbn: ', p_issued_book_isbn) AS message;
    ELSE 
		 SELECT CONCAT('Oops, the book you requested is unavailable book_isbn: ', p_issued_book_isbn) AS message;
    END IF;
END $$
DELIMITER ;

select * from books;
-- '978-0-06-025492-6' -- yes;
-- 978-0-375-41398-8 -- no
select * from issued_status
where issued_book_isbn =  '978-0-06-025492-6';

call issue_book('IS155','C104','978-0-06-025492-6','E110');
call issue_book('IS156','C104','978-0-375-41398-8','E110');

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Tebogo Mabusela



