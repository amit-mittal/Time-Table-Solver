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

% Check if a course is in the course group
if_in_group(Course, [Course|Y]).
if_in_group(Course, [X|Y]):- X \= Course, if_in_group(Course, Y).

% Check if both courses are in the course group
if_both_in_group(Course1, Course2, X):- if_in_group(Course1, X), if_in_group(Course2, X).

% Check if two courses are in the same group
if_in_same_group(Course1, Course2, [course_group(X)|Y]):- if_both_in_group(Course1, Course2, X), !.
if_in_same_group(Course1, Course2, [course_group(X)|Y]):- if_in_same_group(Course1, Course2, Y).

% course(no., students, faculty_code, no. of lectures)
course(ma121, 22, kk11, 2).
course(ma122, 25, kk12, 2).
course(ma123, 4, kk13, 2).

% room(no., capacity)
room(1101, 30).
room(1102, 30).

% course_groups(list)
% course_groups([ma121, ma122, ma123]).

% force(course, slots(list))
force(ma121, slots([a])).
force(ma122, slots([a, b, c])).
force(ma123, slots([a, b, c])).

% force(course, rooms(list))
force(ma121, rooms([1101])).
force(ma122, rooms([1101, 1102])).
force(ma123, rooms([1101, 1102])).

% TODO add days to slot info or no. of lectures
slot(a).
slot(b).
slot(c).

% Consistency Check
% just check that room and slot are not getting repeating simultaneously
consistency_check(course_group([]), X).
consistency_check(course_group([CourseCode|B]), X):- 
								member(alloted(CourseCode, Room, Slot), X),
								count_course(CourseCode, X, Count1), Count1 == 1,
								count_room_slot(Room, Slot, X, Count2), Count2 == 1,
								consistency_check(course_group(B), X).

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
solve(course_group([]), []).
solve(course_group([CourseCode|B]), [alloted(CourseCode, R, S)|X]):- 
								solve(A, alloted(CourseCode, R, S)), 
								solve(course_group(B), X),
								consistency_check(course_group([CourseCode|B]), [alloted(CourseCode, R, S)|X]).


% TODO use no. of lectures needed for that
% TODO if 2 courses in same group their slot count should also be 1