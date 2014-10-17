% course(no., students, faculty_code, no. of lectures)
course(ma121, 22, kk11, 2).
course(ma122, 25, kk12, 2).
course(ma123, 4, kk13, 2).

% room(no., capacity)
room(1101, 30).
room(1102, 30).

% course_groups(list)
course_groups([ma121, ma122, ma123]).

% force(course, slots(list))
force(ma121, slots([a, b, c])).
force(ma122, slots([a, b, c])).
force(ma123, slots([a, b, c])).

% force(course, rooms(list))
force(ma121, rooms([1101, 1102])).
force(ma122, rooms([1101, 1102])).
force(ma123, rooms([1101, 1102])).

% TODO add days to slot info or no. of lectures
slot(a).
slot(b).
slot(c).

% table contains alloted(course, room no., slot)
solve(CourseCode, [alloted(CourseCode, Room, Slot)|X]):- atom(CourseCode), 
								course(CourseCode, Students, _, _), 
								room(Room, Capacity), 
								slot(Slot),
								Capacity >= Students,
								force(CourseCode, rooms(Rooms)),
								member(Room, Rooms),
								force(CourseCode, slots(Slots)),
								member(Slot, Slots),
								\+ member(alloted(Other, Room, Slot), X),
								!.
solve(CourseCode, [alloted(B, _, _)|X]):- atom(CourseCode), solve(CourseCode, X).

% TODO Also implement one solver which takes in whole list

% Can use delete to delete free slot or room lists