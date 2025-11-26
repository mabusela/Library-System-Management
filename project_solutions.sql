-- Project Task
use library_db;
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
select * from members;
update members
set member_address = '63 thuthuka street'
where member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table, Objective: Delete the record with issued_id = 'IS121' from the issued_status table
select * from issued_status;
delete from issued_status
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select i.issued_member_id,
       m.member_name,
     count(*) as number_of_books
  from issued_status as i
  join members as m 
  on i.issued_member_id = m.member_id
  group by i.issued_member_id,m.member_name
  having  number_of_books > 1;
  
-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results -  and total book_issued_cnt**
-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where category = 'Children';

-- Task 8: Find Total Rental Income by Category:
select category,
sum(rental_price) as rental_income,
count(*)
from books as b 
join issued_status as ist
on b.isbn = ist.issued_book_isbn
group by 1
order by 1 DESC;

-- Task 9 List Members Who Registered in the Last 180 Days:
select * from members
where reg_date >= current_date() - interval 180 DAY;

-- task 10 List Employees with Their Branch Manager's Name and their branch details:
select * from employee;
select * from branch;

select 
	emp1.*,
    br.*,
    emp2.emp_name as manager
from employee as emp1
join branch as br 
on emp1.branch_id = br.branch_id
join employee emp2
on br.manager_id = emp2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
create table books_rental_price_greater_than_seven
select * from books
where rental_price > 7;

select * from books_rental_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned
select *  from return_status;

SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL
