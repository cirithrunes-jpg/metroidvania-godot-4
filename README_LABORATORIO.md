# Laboratorio — campanha revisada (v6)

Projeto Godot de `cirithrunes-jpg/metroidvania-godot-4`.
Branch de desenvolvimento: `feature/laboratorio-cyberpunk`.
Original preservado: `backup/original-2026-10-23`, commit `32b73e35851e0f6eb58ba2469b38e3d73daccd9a`.

## Abrir

1. Extraia o ZIP atualizado em uma pasta nova, sem misturar arquivos de versoes anteriores.
2. No Godot **4.7.2** (versao testada), importe `project.godot` e aguarde a importacao.
3. Pressione **F5** e escolha **Jogar**.

A campanha atual tem **tres setores conectados**, com variacoes de percurso, posicionamento de plataformas, reles, inimigos e tonalidade do ambiente. Eles compartilham o kit visual industrial. A porta leva automaticamente ao setor seguinte; a ultima leva a conclusao da campanha.

## Controles e objetivo

- A/D ou setas: mover.
- W, seta para cima ou espaco: pular; pressione novamente para salto duplo.
- Mouse: mirar; botao esquerdo: disparar.
- Esc ou E: pausar/retomar.
- Tab: menu.
- R: reiniciar o setor atual.

Em cada setor, suba ate o rele luminoso e toque nele. Ele ativa o checkpoint e libera a porta a direita. Ao se aproximar da porta no nivel do chao, os paineis se abrem. Entre na abertura para atravessar com uma transicao de tela. Nao basta estar perto da borda da fase ou acima da porta. O checkpoint fica apenas em memoria e reinicia ao sair/reiniciar o setor. Quedas devolvem ao checkpoint; morte tambem recria a personagem.

## Revisao solicitada

- **Tiros:** novos projeteis com teste continuo de colisao por segmento, rastro curto, clarao de boca, recuo da arma, faiscas e pequena fumaca de impacto. Tiros param em paredes e inimigos; efeitos expiram. Os efeitos antigos de tiro nao sao usados pela campanha atual.
- **Plataformas:** textura original de aco desgastado, grades, rebites, borda usinada e faixa luminosa discreta. O desenho acompanha as colisoes.
- **Movimento:** controlador novo com aceleracao/frenagem progressivas, tolerancia na borda, memoria curta do comando de salto, salto duplo, parede, interpolacao fisica, camera suavizada e transicao curta entre quadros da personagem. Limite de renderizacao ampliado para 120 FPS; isso nao garante 120 FPS em todo computador.
- **Textos:** fonte de sistema limpa, com acentos, painel em alta resolucao, contraste escuro e tamanho maior. Sem a fonte pixelada anterior na interface atual.
- **Modelo anterior:** atlas antigo `player/player.png` e seu importador excluidos. A cena antiga do jogador agora encaminha para a nova personagem; a campanha usa diretamente `prototype/player.tscn`. O menu foi refeito com apenas Jogar/Sair, sem acesso a versao antiga ou carregamento antigo. O original continua recuperavel na branch de backup.
- **Porta:** arte original de porta pressurizada, batente fixo, paineis deslizantes, indicador de bloqueio/liberacao, deteccao de aproximacao, entrada e passagem para o proximo setor. A musica continua durante as transicoes.

## Inimigos e audio

Cinco unidades por setor: patrulheiro (2 de integridade), atirador (2), blindado (4), drone (2) e robo (5). Aviso antes do tiro, linha de visao bloqueada por paredes e patrulhas que evitam fossos. Sem ondas infinitas. Arte adaptada de modelos CC0 de drakzlin; fonte e modificacoes em `prototype/assets/enemies/SOURCE.md`.

A trilha MP3 fornecida pelo usuario toca em loop. O barramento Master esta habilitado. Origem de todas as novas artes e da trilha em `prototype/assets/ORIGEM_E_ALTERNATIVAS.md`.

## Estrutura atual

- `prototype/laboratory.tscn`, `sector_2.tscn`, `sector_3.tscn`: setores da campanha.
- `prototype/laboratory.gd`: percursos, plataformas, reles e progressao.
- `prototype/controller.gd`, `player.tscn`, `specimen.gd`: controle e animacao da personagem atual.
- `prototype/combat/`: arma, projeteis e efeitos novos.
- `prototype/pressure_door.gd`: animacao e entrada na porta.
- `prototype/ui/`: fonte, HUD e conclusao.
- `prototype/enemies/`: familia de seguranca.

Alguns scripts de infraestrutura originais sao mantidos para compatibilidade dos autoloads e tipos. Eles nao representam uma opcao de jogo antigo no menu.

## Validacao

```text
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/laboratory_smoke.gd
godot --headless --path . --script res://tests/security_units_smoke.gd
godot --headless --path . --script res://tests/ballistics_smoke.gd
```

**58 verificacoes aprovadas:** 33 de campanha/controle/interface/portas, 18 de inimigos e 7 de balistica. A suite de campanha tambem foi executada com renderizacao Compatibility/ANGLE e suas capturas foram inspecionadas. Os testes posicionam a personagem diretamente para verificar transicoes e nao substituem um playtest humano completo dos saltos, da dificuldade e da animacao.

Neste computador, o Godot informa falha de leitura do repositorio de certificados do sistema; o aviso tambem ocorre na base e nao impediu os testes locais offline. Nenhuma alteracao foi mesclada na main.

## Biblioteca de poses e armas

Em `prototype/animations/` ha uma biblioteca adicional com 16 sequencias/96 entradas de quadros: soco, chute, defesa, reacao a golpe, agachar, andar de quatro, rastejar, cair, costas, virar, rolamento, escalar, arma de fogo, espada, granada e energia. Abra `pose_preview.tscn` e F6 para visualizar. Este acrescimo fornece animacoes; as mecanicas de dano e de movimento correspondentes ainda nao foram ligadas ao controlador da campanha. Instrucoes em `prototype/animations/LEIA-ME.md`. Biblioteca validada com 25 verificacoes especificas.
