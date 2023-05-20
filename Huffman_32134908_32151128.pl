% Trabalho Paradigmas de Linguagem de Programação
% PAULO HENRIQUE BRAGA CECHINEL             - 32151128
% RICARDO GABRIEL MARQUES DOS SANTOS RUIZ   - 32134908
% Esse programa consiste em ler um arquivo.txt, codificar em huffman, e depois escrever o seu codigo em um arquivo out.txt
% obs: para quebras de linha, o output do \n está vazio:


% Predicado principal que devera ser chamado ao testar o programa
main():- 
    lerArquivo("in.txt", Content),
    salvarCodigosParaArquivo(Content, "out.txt").

% Esse predicado relaciona um caractere ao seu codigo.
verificaNaArvore(Item,[[_,Item,Code]|_R],Code).
verificaNaArvore(Item,[[_N,_X,_Cod]|Cauda], C):- verificaNaArvore(Item,Cauda,C),!.
verificaNaArvore(_I,[],_Co):- write("ERRO FATAL: Caracter não está na arvore").

% algoritmo de huffman
huffman(ArvoreCodificada, String):-
    % Converter em uma lista
    atom_chars(String,Lista),
    msort(Lista,ListaOrdenada),
    calcularFrequencia(ListaOrdenada,Pares),
    % Ordena de acordo com a frequencai
    sort(Pares,ParesOrd),
    criarArvore(ParesOrd, Arvore),
    codificarCaracteres(Arvore,[],ArvoreCodificada).

% Conta a quantidade de caracteres
contarQuantidadeCaracter(X,[],[1,X],[]).
contarQuantidadeCaracter(X,[X|L],[Count,X],Cauda):- contarQuantidadeCaracter(X, L, [Contagem2,X],Cauda), Count is Contagem2 + 1.
contarQuantidadeCaracter(X,[Y|L],[1,X],[Y|L]):- dif(X,Y). % Unica ocorrência

% Cria uma lista de dupla de frequencia da caractere ex [(10, "A"), etc)
calcularFrequencia([],[]).
calcularFrequencia([Head|Tail], [Dupla|TailDupla]):-
    contarQuantidadeCaracter(Head, Tail, Dupla, NovaTail),
    calcularFrequencia(NovaTail, TailDupla),!.

% Tem como objetivo criar a lista que representa a arvore inteira.
criarArvore( [[F1|Caracter1],[F2|Caracter2]|Cauda],ArvoreFinal):-
    Total is F1 + F2,
    Arvore = [Total,[F1|Caracter1],[F2|Caracter2]],
    ( Cauda=[] -> ArvoreFinal = Arvore ; sort([Arvore|Cauda], CaudaOrdenada),
    criarArvore(CaudaOrdenada,ArvoreFinal) ).

% Codifica cada caractere da arvore em binario, e adiciona o codigo ao no. Exemplo: [2,"B",[1,0,1]]
codificarCaracteres([_,NoEsq,NoDir], Codigo, ListaFinal):-
    % Adicionar 1 se andar pra direita e for no
    % Percorre na direita até encontrar o no, e codifica
    ( ehNo(NoDir) -> codificarCaracteres(NoDir,[1|Codigo], Lista2) ; codificarNo(NoDir, [1|Codigo], Lista2)),
    % Adicionar 0 se andar para a esquerda e for no
    % Percorre na esquerda até encontrar o no, e codifica
    ( ehNo(NoEsq) -> codificarCaracteres(NoEsq, [0|Codigo], Lista1) ; codificarNo(NoEsq, [0|Codigo], Lista1)),
    % Combina 1's e 0's
    append(Lista1, Lista2, ListaFinal).

% verifica se eh no
ehNo([_,_,_]).

% Para cada caractere na string, obtem o codigo, e armazena em uma lista de duplas. Ex: 
% Codigo = [(H, 111), (E, 110), (L, 101), (O, 011)]
juntarCodigosEmDuplas(String, Codigo):-
    string_chars(String, List),
    huffman(Arvore, String),
    juntarCodigosEmDuplas_aux(List, Codigo, String, Arvore).

juntarCodigosEmDuplas_aux([], [], _, Arvore).
juntarCodigosEmDuplas_aux([Char | Tail], [(Char, Code) | RestCodes], String, Arvore):-
    getCodigo(Char, Code, String, Arvore),
    juntarCodigosEmDuplas_aux(Tail, RestCodes, String, Arvore).

% Obtem o codigo de um caractere de acordo com a string dada.
% Esse predicado é a base do nosso codigo
% Chamamos ele para cada caractere da nossa string, e depois armazenamos numa lista de duplas
getCodigo(Caracter,Codigo, String, Arvore):-
    verificaNaArvore(Caracter,Arvore,Codigo).

% Como percorremos, precisamos inverter o codigo, e transformar em uma string.
codificarNo([No1, No2], Codigo, CodigoFinal):-
    reverse(Codigo, CodigoContrario),
    atomics_to_string(CodigoContrario, CodigoEmString),
    CodigoFinal = [[No1, No2, CodigoEmString]].

% Predicados para tratamento de arquivos:


% Recebe uma string, e salva em um arquivo
salvarCodigosParaArquivo(String, Filename) :-
    juntarCodigosEmDuplas(String, Codigo),
    removerDuplasRepetidas(Codigo, Filtrado),
    open(Filename, write, Stream),
    salvarCodigosParaArquivo_aux(Filtrado, Stream),
    close(Stream).

% salvarCodigosParaArquivo_aux([], _).
% salvarCodigosParaArquivo_aux([(Char, Code) | RestCodes], Stream) :-
%     format(Stream, '~w: ~w~n', [Char, Code]),
%     salvarCodigosParaArquivo_aux(RestCodes, Stream).
salvarCodigosParaArquivo_aux([], _).
salvarCodigosParaArquivo_aux([(Char, Code) | RestCodes], Stream) :-
    (Char = '\n' ->
        NewChar = '\\n'
    ;
        NewChar = Char
    ),
    format(Stream, '~w: ~w~n', [NewChar, Code]),
    salvarCodigosParaArquivo_aux(RestCodes, Stream).

% Remove letras repetidas para o arquivo final ficar mais bonito
removerDuplasRepetidas(Lista, Resultado) :-
    removerDuplasRepetidas(Lista, [], Resultado).

removerDuplasRepetidas([], Acumulador, Acumulador).
removerDuplasRepetidas([(Char, Code) | Resto], Acumulador, Resultado) :-
    (member((Char, _), Resto) ->
        removerDuplasRepetidas(Resto, Acumulador, Resultado)
    ;
        append(Acumulador, [(Char, Code)], NovoAcumulador),
        removerDuplasRepetidas(Resto, NovoAcumulador, Resultado)
    ).
% Le um arquivo, e retorna uma string
lerArquivo(Nome, Output) :-
    open(Nome, read, S),
    lerLinhas(S, Lines),
    close(S),
    atomic_list_concat(Lines, '\n', Output).

lerLinhas(S, []) :-
    at_end_of_stream(S).

lerLinhas(S, [X | Z]) :-
    \+ at_end_of_stream(S),
    read_line_to_string(S, X),
    lerLinhas(S, Z).