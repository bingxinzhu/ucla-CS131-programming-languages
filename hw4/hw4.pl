convert_to_symbol([1,1],'.').
convert_to_symbol([3,1],'-').
convert_to_symbol([2,1],'.').
convert_to_symbol([2,1],'-').
convert_to_symbol([X,1],'-') :- X>3.
convert_to_symbol([1,0],'').
convert_to_symbol([2,0],'').
convert_to_symbol([2,0],'^').
convert_to_symbol([3,0],'^').
convert_to_symbol([4,0],'^').
convert_to_symbol([5,0],'^').
convert_to_symbol([5,0],'#').
convert_to_symbol([X,0],'#') :- X>5.

% convert tuple to list
convert_to_list([],[]).
convert_to_list([[X,Y]|List],Tail) :- convert_to_symbol([X,Y],M), ==(M,''), convert_to_list(List,Tail).
convert_to_list([[X,Y]|List],[M|Tail]) :- convert_to_symbol([X,Y],M), \==(M,''), convert_to_list(List,Tail).

% convert a series of element to tuple
convert_to_tuple([],[]).
convert_to_tuple([Head],[[1,Head]]).
convert_to_tuple([Head|List],[[Counter,Head]|Tail]) :- convert_to_tuple(List,[[Previos_C,Head]|Tail]), Counter is Previos_C+1, !.
convert_to_tuple([Head|List],[[1,Head],[Counter,X]|Tail]) :- convert_to_tuple(List,[[Counter,X]|Tail]), \==(Head,X), !.

% signal_morse function call
signal_morse(List,M) :- convert_to_tuple(List,Tmp), convert_to_list(Tmp,M). 

% facts according to spec
morse(a, [.,-]).   % A
morse(b, [-,.,.,.]).   % B
morse(c, [-,.,-,.]).   % C
morse(d, [-,.,.]).   % D
morse(e, [.]).   % E
morse('e''', [.,.,-,.,.]).   % É (accented E)
morse(f, [.,.,-,.]).   % F
morse(g, [-,-,.]).   % G
morse(h, [.,.,.,.]).   % H
morse(i, [.,.]).   % I
morse(j, [.,-,-,-]).   % J
morse(k, [-,.,-]).   % K or invitation to transmit
morse(l, [.,-,.,.]).   % L
morse(m, [-,-]).   % M
morse(n, [-,.]).   % N
morse(o, [-,-,-]).   % O
morse(p, [.,-,-,.]).   % P
morse(q, [-,-,.,-]).   % Q
morse(r, [.,-,.]).   % R
morse(s, [.,.,.]).   % S
morse(t, [-]).   % T
morse(u, [.,.,-]).   % U
morse(v, [.,.,.,-]).   % V
morse(w, [.,-,-]).   % W
morse(x, [-,.,.,-]).   % X or multiplication sign
morse(y, [-,.,-,-]).   % Y
morse(z, [-,-,.,.]).   % Z
morse(0, [-,-,-,-,-]).   % 0
morse(1, [.,-,-,-,-]).   % 1
morse(2, [.,.,-,-,-]).   % 2
morse(3, [.,.,.,-,-]).   % 3
morse(4, [.,.,.,.,-]).   % 4
morse(5, [.,.,.,.,.]).   % 5
morse(6, [-,.,.,.,.]).   % 6
morse(7, [-,-,.,.,.]).   % 7
morse(8, [-,-,-,.,.]).   % 8
morse(9, [-,-,-,-,.]).   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]).   % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]).   % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).   % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]).   % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]).   % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).   % = (double hyphen)
morse(+, [.,-,.,-,.]).   % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]).   % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

% convert word
signal_convert_helper([], []).
signal_convert_helper(M, [One_element]) :- morse(One_element, M).
signal_convert_helper(M, [Head|Tail]) :- append(MHead, [^|MTail], M), morse(Head, MHead), signal_convert_helper(MTail, Tail).

% convert morse code to Message, separate by #
signal_convert([], []).
signal_convert(Morse, Message) :- signal_convert_helper(Morse, Message).
signal_convert(Morse, Message) :- append(Word, [#|Tail], Morse), signal_convert_helper(Word, Msg), signal_convert(Tail, More_messages), append(Msg, [#|More_messages], Message).

% handle errors
% base case
remove_error_helper([],[],[]).
remove_error_helper([],Remain,Remain).
remove_error_helper(['error'|Tail],[],['error'|Result]) :- remove_error_helper(Tail,[],Result).
remove_error_helper(['error'|Tail],X,Result) :- \==(X,[]), remove_error_helper(Tail,[],Result).
remove_error_helper(['#','error'|Tail],X,Result) :- remove_error_helper(Tail,[],Result).
% recursive rule
remove_error_helper(['#'|Tail],X,Result) :- append(X,['#'],X_temp), append(X_temp,Result_temp,Result), remove_error_helper(Tail,[],Result_temp).
remove_error_helper([Head|Tail],X,Result) :- \==(Head,'#'), \==(Head,'error'), append(X,[Head],Temp), remove_error_helper(Tail,Temp,Result).

% get error free message
remove_error(Message,M) :- once(remove_error_helper(Message,[],M)).
signal_message(B, M) :- signal_morse(B, Morse), signal_convert(Morse, RawM),remove_error(RawM,M).
