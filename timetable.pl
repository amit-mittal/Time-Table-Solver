% TODO add support of taking input, read from file and write to file
% TODO lab classes support still needs to be added
% TODO Remove warnings
% TODO Remove redundant files from the folder
% TODO Test for other inputs - make a big test case


% ========================= TIME TABLE CONSTRAINTS SPECIFIED =========================
% course(no., students, faculty_code, no. of lectures)
course(ma121, 22, kk11, 2).
course(ma122, 5, kk12, 2).
course(ma123, 24, kk13, 2).

% room(no., capacity)
room(1101, 15).
room(1102, 30).

% course_groups(list)
% course_groups([ma121, ma122, ma123]).

% force(course, slots(list))
force(ma121, slots([a, b])).
force(ma122, slots([a, b])).
force(ma123, slots([a, b])).

% force(course, rooms(list))
force(ma121, rooms([1101, 1102])).
force(ma122, rooms([1101, 1102])).
force(ma123, rooms([1101, 1102])).

% TODO add days to slot info or no. of lectures
slot(a).
slot(b).


% ========================= GENERIC CODE =========================
% Count number of occurrence of course in the list
count_course(_, [], 0) :- !.
count_course(X, [alloted(X, _, _)|T], N) :- count_course(X, T, N2), N is N2 + 1.
count_course(X, [alloted(Y, _, _)|T], N) :- X \= Y, count_course(X, T, N).

% Count number of occurrence of room and slot together in the list
count_room_slot(_, _, [], 0) :- !.
count_room_slot(X, Y, [alloted(_, X, Y)|T], N) :- count_room_slot(X, Y, T, N2), N is N2 + 1.
count_room_slot(X, Y, [alloted(_, Z, Y)|T], N) :- X \= Z, count_room_slot(X, Y, T, N).
count_room_slot(X, Y, [alloted(_, X, Z)|T], N) :- Y \= Z, count_room_slot(X, Y, T, N).
count_room_slot(X, Y, [alloted(_, A, B)|T], N) :- X \= A, Y \= B, count_room_slot(X, Y, T, N).

% Count number of occurrence of course and slot together in the list
count_course_slot(_, _, [], 0) :- !.
count_course_slot(X, Y, [alloted(X, _, Y)|T], N) :- count_course_slot(X, Y, T, N2), N is N2 + 1.
count_course_slot(X, Y, [alloted(X, _, A)|T], N) :- A \= Y, count_course_slot(X, Y, T, N).
count_course_slot(X, Y, [alloted(A, _, Y)|T], N) :- A \= X, count_course_slot(X, Y, T, N).
count_course_slot(X, Y, [alloted(A, _, B)|T], N) :- A \= X, B \= Y, count_course_slot(X, Y, T, N).

% Count number of occurrence of slot in the time table given the course group
% count_slot(slot, course group list, time table list, count)
count_slot(_, [], _, 0) :- !.
count_slot(X, [A|B], Y, N) :- count_course_slot(A, X, Y, N1), count_slot(X, B, Y, N2), N is N1 + N2.

% Check if a course is in the course group
if_in_group(Course, [Course|Y]).
if_in_group(Course, [X|Y]):- X \= Course, if_in_group(Course, Y).

% Check if both courses are in the course group
if_both_in_group(Course1, Course2, X):- if_in_group(Course1, X), if_in_group(Course2, X).

% Check if two courses are in the same group
if_in_same_group(Course1, Course2, [course_group(X)|Y]):- if_both_in_group(Course1, Course2, X), !.
if_in_same_group(Course1, Course2, [course_group(X)|Y]):- if_in_same_group(Course1, Course2, Y).


% Consistency Check
% just check that room and slot are not getting repeating simultaneously
consistency_check(course_group([]), X).
consistency_check(course_group([CourseCode|B]), X):- 
                                member(alloted(CourseCode, Room, Slot), X),
                                count_course(CourseCode, X, 1),
                                count_room_slot(Room, Slot, X, 1),
                                count_slot(Slot, [CourseCode|B], X, 1),
                                consistency_check(course_group(B), X).

% Consistency Check of whole Time Table
consistency_check([]).
consistency_check([alloted(CourseCode, Room, Slot)|X]):-
                                count_room_slot(Room, Slot, X, 0),
                                consistency_check(X).

% Checking consistency of one course with respect to the allotment
solve(CourseCode, alloted(CourseCode, Room, Slot)):- 
                                atom(CourseCode), 
                                course(CourseCode, Students, _, _), 
                                force(CourseCode, rooms(Rooms)),
                                force(CourseCode, slots(Slots)),
                                member(Room, Rooms),
                                room(Room, Capacity), 
                                Capacity >= Students,
                                member(Slot, Slots),
                                slot(Slot).

% Checking consistency of one course group
solve(course_group([]), []):- !.
solve(course_group([CourseCode|B]), [alloted(CourseCode, R, S)|X]):- 
                                solve(A, alloted(CourseCode, R, S)), 
                                solve(course_group(B), X),
                                consistency_check(course_group([CourseCode|B]), [alloted(CourseCode, R, S)|X]).

% Checking consistency of multiple course groups
solve(course_groups([]), []):- !.
solve(course_groups([CourseGroup|B]), Table):-
                                solve(CourseGroup, Table1),
                                solve(course_groups(B), Table2),
                                append(Table1, Table2, Table),
                                consistency_check(Table).