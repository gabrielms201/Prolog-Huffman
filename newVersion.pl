% Predicado principal que deverá ser chamado ao testar o programa

salvarStringEmArquivo(String, NomeArquivo) :-
    open(NomeArquivo, write, Stream),
    write(Stream, String),
    close(Stream).
main():-
    applyToAll("HelloCo", Code),
    salvarStringEmArquivo(Code, "out.txt").

% Pares de caracteres e suas frequencias
%  Cria uma lista de dupla de frequencia da caractere ex [(10, "A"), etc)
calculateFrequencies([],[]).
calculateFrequencies([Head|Tail], [Dupla|TailDupla]):-
    countCharacter(Head, Tail, Dupla, NovaTail),
    calculateFrequencies(NovaTail, TailDupla),!.

% Conta a quantidade de caracteres
countCharacter(X,[],[1,X],[]).
countCharacter(X,[X|L],[I,X],Z):- countCharacter(X, L, [I2,X],Z), I is I2 + 1.
countCharacter(X, [Y | L], [1, X], [Y | L]) :-
    X \= Y.
countCharacter(X, [X | L], [2, X], L).

% Ordena de acordo com a frequencai
sortFrequencies(Pares,ParesOrd):- sort(Pares,ParesOrd).

% Obtem o codigo de um caractere de acordo com a string dada.
% Esse predicado é a base do nosso codigo
% Chamamos ele para cada caractere da nossa string, e depois armazenamos numa lista de duplas
getCode(Caracter,Codigo, String):-
    huffmanEncoding(Arvore, String),
    checkInTree(Caracter,Arvore,Codigo).

% verifica se eh no
isNo([_,_,_]).
% Codifica cada caractere da arvore em binario, e adiciona o codigo ao no. Exemplo: [2,"B",[1,0,1]]
encodeCharacters([_,E,D], Code, L):-
    % Adicionar 0 se andar para a esquerda e for no
    % Percorre na esquerda até encontrar o no, e codifica
    ( isNo(E) -> 
        encodeCharacters(E, [0|Code], L1)
        ;
        codeNode(E, [0|Code], L1)),
    % Combina 1's e 0's
    % Adicionar 1 se andar pra direita e for no
    % Percorre na direita até encontrar o no, e codifica
    ( isNo(D) ->
        encodeCharacters(D,[1|Code], L2)
        ;
        codeNode(D, [1|Code], L2)),
    append(L1, L2, L).

% Tem como objetivo criar a lista que representa a arvore inteira.
createTree([ [C1|X1],[C2|X2]|Tail],Tree):-
    H is C1 + C2,
    Tree1 = [H,[C1|X1],[C2|X2]],
    (   Tail=[] -> Tree = Tree1
        ;
        sort([Tree1|Tail], OrderedTail),
        createTree(OrderedTail,Tree) ).

% Separa em uma lista
convertToList(String,List):- atom_chars(String,List).

% Algoritmo de huffman
huffmanEncoding(EncodedTree, String):-
    % Converter em uma lista
    convertToList(String,List),
    msort(List, OrderedList),
    calculateFrequencies(OrderedList,Pairs),
    % Ordena de acordo com a frequencai
    sortFrequencies(Pairs,OrderedPairs),
    createTree(OrderedPairs, Tree),
    encodeCharacters(Tree,[],EncodedTree).

% Relaciona um caractere ao seu codigo
checkInTree(X,[[_,X,C]|_],C).
checkInTree(X,[[_,_,_]|Z], C):-
    checkInTree(X,Z,C),!.

% Codifica um no
codeNode([N1, N2], Code, ResultCode):-
    reverse(Code, ReverseCode),
    atomics_to_string(ReverseCode, NewCode),
    ResultCode = [[N1, N2, NewCode]].



% modificar
applyToAll(String, Codes) :-
    string_chars(String, Chars),
    applyToAllAux(Chars, Codes, String).

applyToAllAux([], [], _).
applyToAllAux([X | XS], [(X, Code) | Z], String) :-
    getCode(X, Code, String),
    applyToAllAux(XS, Z, String).