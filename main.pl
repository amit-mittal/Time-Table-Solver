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


% Consistency Check of whole Time Table
consistency_check([]).
consistency_check([alloted(_, Room, Slot)|X]):-
                                count_room_slot(Room, Slot, X, 0),
                                consistency_check(X).

% Consistency Check of one course group
consistency_check(course_group([]), _).
consistency_check(course_group([CourseCode|B]), X):- 
                                member(alloted(CourseCode, Room, Slot), X),
                                count_course(CourseCode, X, 1),
                                count_room_slot(Room, Slot, X, 1),
                                count_slot(Slot, [CourseCode|B], X, 1),
                                consistency_check(course_group(B), X).

% Checking consistency of one course with respect to the allotment
consistency_check(CourseCode, alloted(CourseCode, Room, Slot)):- 
                                atom(CourseCode), 
                                course(CourseCode, Students, _, _), 
                                force(CourseCode, rooms(Rooms)),
                                force(CourseCode, slots(Slots)),
                                member(Room, Rooms),
                                room(Room, Capacity), 
                                Capacity >= Students,
                                member(Slot, Slots),
                                slot(Slot).

% Solving one course group
solve(course_group([]), []).
solve(course_group([CourseCode|B]), [alloted(CourseCode, R, S)|X]):- 
                                consistency_check(CourseCode, alloted(CourseCode, R, S)), 
                                solve(course_group(B), X),
                                consistency_check(course_group([CourseCode|B]), [alloted(CourseCode, R, S)|X]).

% Solving multiple course groups
solve(course_groups([]), []).
solve(course_groups([CourseGroup|B]), Table):-
                                solve(CourseGroup, Table1),
                                solve(course_groups(B), Table2),
                                append(Table1, Table2, Table),
                                consistency_check(Table).


% Managing the flow of the program
main:-
    write('Input FilePath: '),
    read(In),
    consult(In),
    course_groups(A),
    write('Output FilePath: '),
    read(Out),
    tell(Out),
    (
        solve(course_groups(A), Table),
        writeln('Possible Time Table:'),
        writeln(Table), nl,
        fail
    ;
        told
    ).