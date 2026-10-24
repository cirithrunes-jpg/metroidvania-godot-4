# Laboratório — controle e combate (v12)

Projeto Godot de `cirithrunes-jpg/metroidvania-godot-4`, branch `feature/laboratorio-cyberpunk`.
Original preservado em `backup/original-2026-10-23`, commit `32b73e35851e0f6eb58ba2469b38e3d73daccd9a`. Main preservada.

## Abrir

1. Extraia o ZIP v12 em uma pasta nova e importe `project.godot` no **Godot 4.7.2**.
2. Pressione **F5** e escolha **Jogar**. A sequência é vídeo → tela preta com MISSÃO: PROTOCOLO DE COMBATE ATIVADO → fase.
3. O vídeo está no ZIP local. No GitHub, sua publicação ainda aguarda autorização explícita; a ausência dele leva normalmente à tela de missão.

## Esquema solicitado

| Ação | PlayStation | Xbox | Teclado padrão |
| --- | --- | --- | --- |
| Mover | Analógico esquerdo / direcional ← → | Igual | A/D ou ←/→ |
| Pular | Toque ↑ no direcional ou analógico esquerdo | Igual | W, ↑ ou Espaço |
| Pulo duplo / cambalhota | Solte e aperte X novamente no ar | A novamente | Espaço novamente |
| Soco | Quadrado | X | J |
| Chute | Triângulo | Y | K |
| Chute aéreo | Pule e pressione Triângulo | Pule e pressione Y | Pule e pressione K |
| Tiro | R1 | RB | Z |
| Poder de energia | Segure R2 por 2 segundos | Segure RT por 2 segundos | Segure C por 2 segundos |
| Defesa | Segure Círculo | Segure B | Segure L |
| Granada | L2 | LT | G |
| Espada | L1 | LB | H |
| Agachar, sem movimentação | ↓ imediatamente | Igual | S ou ↓ |
| Deitar / rastejar | Segure ↓ por 1 segundo | Igual | S ou ↓ por 1 segundo |
| Levantar | Um comando de pulo, com espaço acima | Igual | Pulo |
| Acionar botão da porta | L3 | L3 | E |
| Subir / descer escadas | ↑ / ↓ no direcional ou analógico | Igual | W / S ou ↑ / ↓ |
| Pausar | Start / Options | Menu | Esc |

O pulo do controle fica reservado no X/cruz (A no Xbox), inclusive na tela de configuração. Para cima controla escadas. O segundo pulo executa uma cambalhota; o tiro aguarda seu término.

A postura baixa permanece após soltar para baixo. Agachada fica imóvel; deitada pode rastejar. Um pulo restaura o corpo em pé e inicia o salto; se houver um teto baixo, a personagem continua deitada até ter espaço. Corpo e área que recebe tiros diminuem com a postura. A defesa funciona em pé, agachada e deitada: bloqueia dois tiros, e o terceiro quebra o escudo, causa dano e recuo. Após a quebra, a recarga leva 2 segundos; ao soltar uma defesa usada, leva 1,4 segundo.

## Armas e poder

- Soco normal: sequência de 12 quadros, dois contatos de 1 de dano; o próximo comando de soco dentro de 2,2 segundos executa um gancho de 6 quadros. Cada contato acerta uma vez.
- Chutes sucessivos alternam chute normal (12 quadros), invertido e com os dois pés (6 quadros cada). Chutes causam 2 de dano, gancho 1, espada 2. No ar, Triângulo executa o chute aéreo. Paredes bloqueiam golpes.
- R2 carrega um poder original de energia frontal. Ao completar 2 segundos, ele é disparado automaticamente, causando 3 de dano. Soltar antes cancela a carga. Para disparar de novo, solte e carregue novamente; manter o botão pressionado não repete o poder.
- L2 lança uma granada com trajetória e quique, fusível de 1,25 segundo após o lançamento, alcance de explosão de 42 unidades e 3 de dano em inimigos/objetos. Paredes bloqueiam a explosão. Há intervalo de 1,4 segundo entre lançamentos, com uma granada por pressionamento. A explosão não causa dano na própria personagem.
- O HUD informa carga do poder, mudança de postura, teto baixo e recarga da granada. Sons próprios acompanham as novas habilidades. Pausar congela os tempos das habilidades e das granadas.

A animação inédita de chute aéreo tem seis quadros em `prototype/animations/air_kick.tres`, com PNG em `prototype/assets/poses/air-kick-v10.png`. A animação de subir escadas vista de costas está salva em **`prototype/animations/ladder_back.tres`**; abra `ladder_back_preview.tscn` e pressione **F6** para vê-la. Está ligada às escadas das plataformas: ↑ sobe, ↓ desce, X sai pulando.

## Configuração e salvamento

Abra **Configurar controles** no menu principal ou **Pausa → Controles**. Há dezesseis ações, com colunas de teclado e controle, captura de botão/gatilho/analógico, troca automática em conflitos, Salvar e voltar, Restaurar padrão e Voltar sem salvar. A lista rola e acompanha o foco pelo controle. Esc continua disponível para acessar a pausa.

O novo esquema usa `user://cyberpunk_controls_v4.cfg`; configurações de versões anteriores permanecem em seus arquivos anteriores. Na v12, Restaurar padrão recupera o esquema desta tabela.

Na pausa há Continuar, Salvar progresso, Controles e Menu principal. O save em `user://cyberpunk_campaign_v1.json` preserva setor, botão/checkpoint, vida, inimigos restantes e latas/barris danificados ou quebrados. No menu, Continuar progresso salvo restaura pelo checkpoint. Jogar inicia campanha nova; o save anterior só é substituído ao salvar novamente.

## Campanha e arte

Três camadas de textura industrial original usam velocidades diferentes: máquinas distantes (0,25), tubulações (0,60) e vigas/cabos em primeiro plano (1,12). Cada setor tem tonalidade própria. Plataformas têm colunas ancoradas ao piso, travessas, escadas e guarda-corpos; as extremidades limitam soldados sem bloquear os saltos da personagem.

Três corredores conectados de 1920 unidades cada, com plataformas, botão alto que libera a saída e porta elevada no segundo corredor. Fundos de laboratório, turbinas e reator, vigas em primeiro plano e quatro latas/barris quebráveis por corredor. Pôster original no menu principal. A trilha enviada toca em loop durante a campanha.

As folhas de poses existentes foram reaproveitadas para espada, granada, energia, agachar, rastejar e escada de costas. A nova arte do chute aéreo foi criada com image_gen, a partir da nossa personagem. Novos socos, chutes, fogo/fumaça da granada e textura industrial em `prototype/assets/GERACAO_V11_V12.md`, com os prompts exatos. Origem dos demais assets em `prototype/assets/ORIGEM_E_ALTERNATIVAS.md` e base CC0 dos soldados em `prototype/assets/enemies/SOURCE.md`.

Os arquivos RAR de driver foram apenas listados: contêm instaladores para JS046 e JS071. Nenhum instalador foi executado ou incluído no jogo. Nos testes, o Godot não detectou um controle físico; os comandos foram verificados com eventos simulados. Se o seu modelo usar outra numeração, use Configurar controles para capturar cada botão real.

## Validação

Godot 4.7.2, renderização Compatibility/ANGLE. Suítes:

```text
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/laboratory_smoke.gd
godot --headless --path . --script res://tests/security_units_smoke.gd
godot --headless --path . --script res://tests/ballistics_smoke.gd
godot --headless --path . --script res://tests/corridor_combat_smoke.gd
godot --headless --path . --script res://tests/v8_controls_save_smoke.gd
godot --headless --path . --script res://tests/v9_remap_props_smoke.gd
godot --headless --path . --script res://tests/v10_combat_posture_smoke.gd
```

Os testes verificam campanha, combate, paredes, áudio, salvamento, remapeamento, X fixo, posturas imediata/1 segundo, cambalhota, saída do tiro, escadas e os novos combos/camadas. Execute também `tests/v11_immersion_combat_smoke.gd` e `tests/v12_special_depth_smoke.gd`. Capturas renderizadas são inspecionadas. O controle físico ainda precisa ser conferido no equipamento do usuário; os testes usam eventos simulados.
