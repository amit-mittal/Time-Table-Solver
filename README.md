Time Table Solver
=================
Come up with time table for IIT Guwahati automatically on the basis of constraints given in Prolog

How to Run?
------------
1. Load main.pl in prolog<br/>
2. Run main.<br/>
3. It will ask for input file which contains all the facts and constraints<br/>
4. Output file will also be asked where all the possible time tables will be printed

How to define input file?
--------------------------
- See sample input.txt<br/>
- force contraint is the list containing the possible values, it can take

Features
--------
- To apply OR in force constraints, define 2 force constraints for the same courses<br/>
- To apply AND in force constraints, write them in the list of same force constraint<br/>
- Supports consistency check: load main.pl and your input file, call course_groups(A), solve(course_groups(A), your_timetable). It will return true or false.

Improvements
-------------
- one course can come in many course groups<br/>
- order in time table matters, should be in same sequence as in course groups<br/>
- handle labs + lectures in time table<br/>
- force contraint says one room as well as slot simulaneously. eg. if room A, then slot B needed OR if room X, then slot Y needed