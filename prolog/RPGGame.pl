% ============================================================
%  COVIL DO LICH - RPG Baseado em Regras (Prolog)
%  Trabalho Final - Programação Lógica
% ============================================================

% --- MAPA: conexões entre salas ---
% conecta(Origem, Destino) - caminho unidirecional (Parecido com a logica de grafos)

conecta(entrada, ossario).
conecta(ossario, entrada).

conecta(entrada, cripta_esquecida).
conecta(cripta_esquecida, entrada).

conecta(ossario, cripta_esquecida).
conecta(cripta_esquecida, ossario).

conecta(sala_armadilha, cripta_esquecida).
conecta(cripta_esquecida, sala_armadilha).

conecta(passagem_secreta, ossario).
conecta(ossario, passagem_secreta).

conecta(passagem_secreta, sala_armadilha).
conecta(sala_armadilha, passagem_secreta).

conecta(passagem_secreta, catacumba).
conecta(catacumba, passagem_secreta).

conecta(passagem_secreta, camara_alquimia).
conecta(camara_alquimia, passagem_secreta).

conecta(catacumba, camara_alquimia).
conecta(camara_alquimia, catacumba).

conecta(sala_armadilha, sala_ritual).
conecta(sala_ritual, sala_armadilha).

conecta(corredor_final, sala_ritual).
conecta(sala_ritual, corredor_final).

conecta(corredor_final, camara_alquimia).
conecta(camara_alquimia, corredor_final).

% Corredor final → sala boss: sem volta (portão sela atrás do jogador)
conecta(corredor_final, sala_boss).

% --- JOGADOR: estado inicial ---
% jogador(Nome, SalaAtual, Vida, ForcaBase)

jogador(heroi, entrada, 10, 1).

% --- MONSTROS ---
% monstro(Nome, Sala, Forca, Descricao)

monstro(rato_morto_vivo, ossario, 2,
    'Rato reanimado pelo miasma do lich').
monstro(esqueleto_guardiao, catacumba, 4,
    'Soldado esqueletico que ainda empunha sua lanca').
monstro(ghoul, sala_armadilha, 5,
    'Morto-vivo faminto que embosca intrusos').
monstro(espectro, sala_ritual, 6,
    'Espirito aprisionado nos circulos rituais').
monstro(cavaleiro_da_morte, sala_boss, 9,
    'Campeao caido do lich, revestido em armadura negra').

% --- ITENS ---
% item(Nome, Sala, Tipo, Valor, Descricao)
%   Tipo: arma | defesa | cura | chave

item(pocao_menor, entrada, cura, 3,
    'Frasco com liquido avermelhado').
item(adaga_enferrujada, passagem_secreta, arma, 2,
    'Lamina corroida mas ainda cortante').
item(escudo_osseo, sala_armadilha, defesa, 2,
    'Escudo feito de ossos fundidos').
item(espada_amaldicoada, catacumba, arma, 4,
    'Espada negra que emana energia sombria').
item(amuleto_protetor, cripta_esquecida, defesa, 2,
    'Amuleto gravado com runas de protecao').
item(pocao_maior, camara_alquimia, cura, 5,
    'Elixir concentrado de restauracao vital').
item(chave_cripta, sala_ritual, chave, 0,
    'Chave de ferro retorcido, abre o corredor final').

% --- ARMADILHAS ---
% armadilha(Sala, Dano, Descricao)

armadilha(sala_armadilha, 3,
    'Espinhos emergem do chao de pedra').

% --- SALAS: descrições ---
% descricao_sala(Sala, Texto)

descricao_sala(entrada,
    'Portal de pedra coberto de musgo. O ar cheira a morte.').
descricao_sala(ossario,
    'Pilhas de ossos se acumulam nas paredes.').
descricao_sala(cripta_esquecida,
    'Tumulos antigos com inscricoes apagadas pelo tempo.').
descricao_sala(passagem_secreta,
    'Corredor estreito escondido atras de uma parede falsa.').
descricao_sala(sala_armadilha,
    'Sala com mecanismos visiveis no chao e paredes.').
descricao_sala(catacumba,
    'Galerias subterraneas repletas de nichos funerarios.').
descricao_sala(camara_alquimia,
    'Laboratorio abandonado com frascos e circulos arcanos.').
descricao_sala(sala_ritual,
    'Circulos de invocacao gravados no chao de obsidiana.').
descricao_sala(corredor_final,
    'Corredor longo e silencioso. A escuridao se adensa.').
descricao_sala(sala_boss,
    'Salao do trono profanado. Uma figura blindada aguarda.').




% ============================================================
%  REGRAS DE MOVIMENTAÇÃO
% ============================================================

% pode_mover/2 - movimento direto (1 passo)
% O jogador pode mover se existe conexão da sala atual ao destino.

pode_mover(Jogador, Destino) :-
    jogador(Jogador, SalaAtual, _, _),
    conecta(SalaAtual, Destino).


% caminho/2 - alcançabilidade (N passos)
% Verifica se existe ALGUMA sequência de conexões de X até Y.
% Usa lista de visitados para evitar loops infinitos.

caminho(Origem, Destino) :-
    caminho(Origem, Destino, [Origem]).

caminho(X, X, _).

caminho(Origem, Destino, Visitados) :-
    conecta(Origem, Intermediario),
    \+ member(Intermediario, Visitados),
    caminho(Intermediario, Destino, [Intermediario | Visitados]).


% rota/3 - encontra o caminho completo como lista de salas

rota(Origem, Destino, Caminho) :-
    rota(Origem, Destino, [Origem], CaminhoRev),
    reverse(CaminhoRev, Caminho).

rota(X, X, Acumulador, Acumulador).

rota(Origem, Destino, Visitados, Caminho) :-
    conecta(Origem, Prox),
    \+ member(Prox, Visitados),
    rota(Prox, Destino, [Prox | Visitados], Caminho).


% todas_rotas/3 - coleta TODAS as rotas possíveis entre duas salas
% Usa findall para forçar o Prolog a esgotar o backtracking de rota/3

todas_rotas(Origem, Destino, Rotas) :-
    findall(R, rota(Origem, Destino, R), Rotas).


% ============================================================
%  REGRAS DE INVENTÁRIO
% ============================================================

% melhor_arma/2 - encontra o maior bônus de arma no inventário
% Se não tem arma, bônus é 0.

melhor_arma(Inventario, Bonus) :-
    findall(V, (member(Item, Inventario), item(Item, _, arma, V, _)), Armas),
    Armas \= [],
    max_list(Armas, Bonus).

melhor_arma(Inventario, 0) :-
    \+ (member(Item, Inventario), item(Item, _, arma, _, _)).


% bonus_defesa/2 - soma TODOS os itens de defesa (escudo + amuleto acumulam)

bonus_defesa(Inventario, Total) :-
    findall(V, (member(Item, Inventario), item(Item, _, defesa, V, _)), Defesas),
    sum_list(Defesas, Total).


% cura_total/2 - soma todas as poções disponíveis

cura_total(Inventario, Total) :-
    findall(V, (member(Item, Inventario), item(Item, _, cura, V, _)), Curas),
    sum_list(Curas, Total).


% poder_total/3 - calcula o poder de combate do jogador
% Poder = ForcaBase + MelhorArma + BonusDefesa

poder_total(Jogador, Inventario, Poder) :-
    jogador(Jogador, _, _, ForcaBase),
    melhor_arma(Inventario, BonusArma),
    bonus_defesa(Inventario, BonusDefesa),
    Poder is ForcaBase + BonusArma + BonusDefesa.

% vida_total/3 - vida efetiva considerando curas e dano de armadilhas

vida_efetiva(Jogador, Inventario, VidaFinal) :-
    jogador(Jogador, _, VidaBase, _),
    cura_total(Inventario, Cura),
    VidaFinal is VidaBase + Cura.

% tem_chave/1 - verifica se o jogador possui a chave da cripta
tem_chave(Inventario) :-
    member(chave_cripta, Inventario).


% ============================================================
%  REGRAS DE COMBATE
% ============================================================

% pode_derrotar/3 - o jogador vence se seu poder >= força do monstro

pode_derrotar(Jogador, Monstro, Inventario) :-
    monstro(Monstro, _, ForcaMonstro, _),
    poder_total(Jogador, Inventario, PoderJogador),
    PoderJogador >= ForcaMonstro.

% sala_segura/3 - a sala não tem monstro, OU o jogador pode derrotá-lo

sala_segura(_Jogador, Sala, _Inventario) :-
    \+ monstro(_, Sala, _, _).

sala_segura(Jogador, Sala, Inventario) :-
    monstro(Monstro, Sala, _, _),
    pode_derrotar(Jogador, Monstro, Inventario).

% sobrevive_armadilha/3 - vida efetiva > dano da armadilha

sobrevive_armadilha(_Jogador, Sala, _Inventario) :-
    \+ armadilha(Sala, _, _).

sobrevive_armadilha(Jogador, Sala, Inventario) :-
    armadilha(Sala, Dano, _),
    vida_efetiva(Jogador, Inventario, Vida),
    Vida > Dano.

% sala_acessivel/3 - sala é segura E sobrevive à armadilha (se houver)

sala_acessivel(Jogador, Sala, Inventario) :-
    sala_segura(Jogador, Sala, Inventario),
    sobrevive_armadilha(Jogador, Sala, Inventario).


% pode_acessar_corredor_final/2 - precisa da chave E sala_ritual limpa

pode_acessar_corredor_final(Jogador, Inventario) :-
    tem_chave(Inventario),
    sala_segura(Jogador, sala_ritual, Inventario).


% monstros_derrotaveis/2 - lista todos os monstros que o jogador
% consegue derrotar com um dado inventário.
% Reutiliza pode_derrotar/3 que já calcula poder_total internamente.

monstros_derrotaveis(Inventario, Monstros) :-
    findall(M, pode_derrotar(heroi, M, Inventario), Monstros).


% salas_seguras/2 - lista todas as salas que o jogador pode
% atravessar com segurança (sem monstro OU monstro derrotável,
% E sobrevive à armadilha se houver).
% Itera sobre todas as salas conhecidas via descricao_sala/2.

salas_seguras(Inventario, Salas) :-
    findall(S,
        (descricao_sala(S, _), sala_acessivel(heroi, S, Inventario)),
        Salas).

% ============================================================
%  CONDIÇÕES DE VITÓRIA
% ============================================================

% vencedor/2 - o jogador vence o jogo se:
%   1. Pode acessar o corredor final (tem chave + derrotou espectro)
%   2. Pode derrotar o boss (cavaleiro_da_morte)
%   3. Sobrevive a todas as armadilhas no caminho

vencedor(Jogador, Inventario) :-
    pode_acessar_corredor_final(Jogador, Inventario),
    pode_derrotar(Jogador, cavaleiro_da_morte, Inventario),
    sobrevive_armadilha(Jogador, sala_armadilha, Inventario).

% inventario_minimo_vitoria/1 - qual é o menor inventário que garante vitória?
% Usa backtracking para testar combinações.

inventario_possivel([pocao_menor, adaga_enferrujada, escudo_osseo,
    espada_amaldicoada, amuleto_protetor, pocao_maior, chave_cripta]).

inventario_minimo_vitoria(Inventario) :-
    inventario_possivel(TodosItens),
    subconjunto(Inventario, TodosItens),
    Inventario \= [],
    vencedor(heroi, Inventario),
    \+ (subconjunto(Menor, Inventario),
        Menor \= Inventario,
        Menor \= [],
        vencedor(heroi, Menor)).

% subconjunto/2 - gera subconjuntos via backtracking
subconjunto([], _).
subconjunto([X|Resto], Lista) :-
    member(X, Lista),
    subconjunto(Resto, Lista).