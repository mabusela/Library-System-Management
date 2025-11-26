-- SQL Project - Library Management System N2

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 60-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

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

-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
SELECT * FROM issued_status
where issued_book_isbn = '978-0-451-52994-2';

select * from books
where isbn = '978-0-307-58837-12';

update books
set status = 'no'
where isbn = '978-0-451-52994-2';

select * from return_status
where issued_id = 'IS130';

--
/* Addiding the book_quality column in the return_status table */
alter table return_status
add column book_quality varchar(15);

insert into return_status(return_id, issued_id, return_date, book_quality)
values ('RS125','IS130', current_date,'Good');

update books
set status = 'Yes'
where isbn = '978-0-451-52994-2';

-- Store Procedures for updating the Status to Yes as soon as the book is returned
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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
select *  from branch;
select *  from issued_status;
select * from employee;
select * from books;
select * from return_status;

CREATE TABLE branch_report
as
select 
	br.branch_id,
    br.manager_id,
    count(ist.issued_id) as number_book_issued,
    count(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
from issued_status as ist
join	
employee as emp
on emp.emp_id =  ist.issued_emp_id 
join 
branch as br
on emp.branch_id = br.branch_id
left join 
return_status as rs
on rs.issued_id = ist.issued_id
join 
books as bk
on ist.issued_book_isbn = bk.isbn
group by br.branch_id,br.manager_id;

select * from branch_report;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
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

-- 
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
    
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
    

/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

select * from books;

select * from issued_status;

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

select * from books
where isbn = '978-0-06-025492-6'






