# Biblioteca de poses da personagem

16 animacoes, com 6 quadros por sequencia (96 entradas), em quatro PNGs transparentes. Artes originais geradas para a personagem do projeto, mantendo cabelo prateado, armadura biomecanica e detalhes ciano. A energia segue a linguagem visual de golpes de anime, sem copiar uma personagem de outra franquia.

## Ver as animacoes

No pacote independente, importe `project.godot` no Godot 4.7.2 e pressione **F5**.
No projeto do jogo, abra `prototype/animations/pose_preview.tscn` e pressione **F6**.

Clique na animacao desejada. Setas esquerda/direita trocam de pose, espaco repete, F espelha. Esc volta ao menu no projeto completo ou fecha a previa no pacote independente.

## Sequencias

| Recurso | Animacoes |
| --- | --- |
| combat.png | Soco, chute, defesa e reacao ao golpe |
| mobility.png | Agachar, andar de quatro, rastejar e cair |
| extras.png | De costas, virar, esquiva/rolamento e escalar |
| weapons.png | Arma de fogo, espada, granada e disparo de energia |

O recurso `prototype/animations/actions.tres` pode ser atribuido a um `AnimatedSprite2D`. Ele contem os recortes e margens de registro. Nao recorte as folhas apenas dividindo a altura por quatro: as figuras geradas possuem espacos verticais diferentes, e o recurso ja corrige isso.

## Usar no Godot

```gdscript
var frames = load("res://prototype/animations/actions.tres")
$AnimatedSprite2D.sprite_frames = frames
$AnimatedSprite2D.centered = false
$AnimatedSprite2D.offset = -frames.get_meta("foot_anchor")
var action = "sword"
var factor = frames.get_meta("pose_scales")[action]
$AnimatedSprite2D.scale = Vector2.ONE * 0.132 * factor
$AnimatedSprite2D.play(action)
```

Nomes: `punch`, `kick`, `guard`, `hit`, `crouch`, `all_fours`, `prone_crawl`, `fall`, `back_idle`, `turn`, `roll`, `climb`, `rifle`, `sword`, `grenade`, `energy`.

Cada quadro tem canvas virtual de 512 x 384; ancora dos pes em (256,352). A escala extra das poses com armas esta nos metadados `pose_scales`. Os recortes mantem os PNGs originais intactos. Os ciclos de rolamento e escalada reutilizam um quadro de recuperacao para evitar vazamento da linha vizinha. As animacoes sao uma primeira passagem artistica e podem precisar de refinamento de timing e transicoes ao entrar no controlador final.

Soco, chute e defesa agora estao ligados ao controlador da campanha (J, K e L). Espada, granada, rastejar e poder continuam como biblioteca de arte, sem mecanicas de combate associadas.

## Validacao

25 verificacoes aprovadas no Godot: 16 sequencias, 96 quadros, recortes dentro das imagens, canvas normalizado, transparencia e selecao das 16 acoes na cena de previa. Previa e catalogo renderizados e inspecionados.

No repositorio, `tests/build_pose_library.gd` reconstroi `actions.tres`; `tests/poses_smoke.gd` valida a biblioteca e `tests/poses_catalog.gd` gera o catalogo.
