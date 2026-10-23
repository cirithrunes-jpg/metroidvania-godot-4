# Laboratorio / 01 — primeira evolucao jogavel

Prototipo incremental para `cirithrunes-jpg/metroidvania-godot-4`.
Base preservada: `32b73e35851e0f6eb58ba2469b38e3d73daccd9a`.
Branch original: `backup/original-2026-10-23`.
Branch de trabalho: `feature/laboratorio-cyberpunk`.

## Abrir e testar

1. No GitHub, selecione a branch `feature/laboratorio-cyberpunk`, clique em **Code > Download ZIP** e extraia o arquivo.
2. No Godot 4, clique em **Importar**, selecione `project.godot` e aguarde a importacao. Validado com Godot 4.7.2, renderizador Compatibility.
3. Aperte **F6** com `prototype/laboratory.tscn` aberta, ou **F5** e escolha **Jogar laboratorio (prototipo)**.
4. Suba pelas plataformas, toque no rele azul na plataforma alta e siga ate a saida a direita.
5. O menu tambem oferece **Jogar versao original** e **Carregar original**.

Na copia local, o projeto esta na pasta `Game`, junto deste documento.

## Controles

- A/D ou setas esquerda/direita: movimento.
- W ou seta para cima: pular; pressione novamente no ar para salto duplo.
- Mouse: mirar; clique esquerdo: atirar.
- S ou seta para baixo: descer plataformas quando suportado pelo controlador original.
- ESC ou E: pausar/retomar laboratorio.
- R: reiniciar laboratorio; TAB: voltar ao menu.

## Conteudo desta etapa

- Fase horizontal de 960 x 180 unidades, com passarelas, saltos, tres inimigos e objetivo final.
- Rele de energia que ativa um checkpoint durante a partida e libera a conclusao.
- Queda devolve ao checkpoint e tira uma unidade de integridade, sem matar; morte por combate recria o jogador no checkpoint.
- Paleta grafite, azul eletrico e vermelho de emergencia; tanques, paineis, luzes de alarme pulsantes e fachos desenhados em 2D.
- Protagonista feminina biomecanica com atlas original gerado, cabelo prateado e detalhes luminosos. Ciclo de corrida com seis quadros, repouso, subida, apice, queda, parede e aterrissagem, com respiracao e recuperacao de impacto suaves. Colisores do laboratorio ajustados a silhueta mais alta; cena original preservada.
- Reaproveita o controlador, tiros, inimigos, efeitos e audio ja presentes no repositorio. Nenhum novo asset externo foi copiado ou baixado.
- Cenas e scripts das tres fases originais mantidos. O menu recebeu acesso adicional ao prototipo.

Este e um estudo jogavel da direcao visual; nome, historia, habilidades finais e design definitivo continuam em aberto. A iluminacao usa sobreposicoes de cor, sem sombras dinamicas. O checkpoint do laboratorio nao e salvo em disco e reinicia ao sair/reiniciar. O salvamento original continua acessivel pelo menu original. Ainda e necessario playtest humano para ajustar dificuldade e sensacao dos saltos.

## Estrutura examinada

`world.tscn` + `world.gd`: jogador, HUD e troca das fases. `world/level_one.tscn`, `level_two.tscn`, `level_three.tscn`: conteudo original. `player/player.gd`: movimento, salto duplo, wall jump e combate. `enemies/`: inimigos. `menus/`: inicio, pausa e derrota. Autoloads: estatisticas, eventos, instancias, som, musica e salvamento.

A nova cena `prototype/laboratory.tscn` herda o contrato de `World` e contem um `Level`, para preservar a integracao tipada dos tiros e efeitos. O desenho do personagem esta em `prototype/specimen.gd` e e aplicado apenas ao prototipo.

## Validacao reproduzivel

Execute com o executavel Godot no PATH:

```text
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/laboratory_smoke.gd
```

O teste verifica 18 condicoes (incluindo quatro verificacoes da nova arte e animacao): nascimento, chao, movimento, salto, integracao dos disparos/efeitos, rele, queda, renascimento, checkpoint, pausa, retomada, conclusao, menu e abertura do jogo original. Nao substitui um playtest manual completo; os testes de progressao posicionam o personagem para exercitar cada transicao.

Tambem executado com renderizacao Compatibility/ANGLE e captura visual inspecionada. Neste computador o Godot informa falha de leitura do repositorio de certificados do sistema; isso tambem aparece na base e nao impediu o teste local offline. Nenhuma alteracao foi mesclada na main.

## Revisao da personagem v2

Arte e animacao integradas somente ao laboratorio. Origem e alternativas do GitHub documentadas em prototype/assets/ORIGEM_E_ALTERNATIVAS.md. Validacao com 18 verificacoes aprovadas no Godot 4.7.2 e captura visual inspecionada. O render do atlas usa filtro linear para evitar contornos serrilhados na ampliacao da janela. A personagem continua uma proposta artistica em evolucao.


## Revisao do fundo v3

O laboratorio agora usa um panorama original com texturas mais realistas de concreto, metal desgastado, dutos, cabos e janelas de contencao. A imagem preserva suas proporcoes e fica atras das plataformas e da personagem. As instrucoes receberam um painel escuro translucido para facilitar a leitura. Esta revisao altera apenas o visual do fundo; o percurso e suas colisoes foram preservados. Validacao: as mesmas 18 verificacoes passaram com renderizacao no Godot 4.7.2 e a captura dentro do jogo foi inspecionada.

## Trilha sonora

O laboratorio toca em loop a trilha `钢铁地牢 (2).mp3` fornecida pelo usuario, copiada para `prototype/assets/steel-dungeon-soundtrack.mp3`. O barramento Master foi reativado para a reproducao ser ouvida. Ao entrar na campanha original, a musica original volta a tocar. Validacao ampliada para 20 verificacoes, incluindo stream MP3 carregado e em reproducao, loop ativo, duracao valida, Master habilitado e preservacao da trilha original.
