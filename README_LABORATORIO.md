# Laboratório — corredores e combate (v7)

Projeto de `cirithrunes-jpg/metroidvania-godot-4`, branch `feature/laboratorio-cyberpunk`.
Original preservado em `backup/original-2026-10-23`, commit `32b73e35851e0f6eb58ba2469b38e3d73daccd9a`. A main não foi alterada.

## Abrir e jogar

1. Extraia o ZIP atualizado em uma pasta nova.
2. No **Godot 4.7.2** (versão testada), importe `project.godot` e aguarde a importação.
3. Pressione **F5**, escolha **Jogar** e assista à introdução. Espaço, Enter ou Esc pulam o vídeo.

O ZIP local inclui o vídeo enviado. O vídeo não foi incluído no repositório público: essa publicação aguarda autorização explícita. Sem o arquivo `prototype/assets/video/introduction.ogv`, o jogo passa automaticamente do menu para a primeira fase.

A campanha tem **três corredores conectados**, cada um com 1920 unidades de comprimento (antes 960), câmera com movimento vertical, plataformas adicionais e 11 unidades de segurança. Os fundos mudam entre laboratório, fábrica de turbinas e manutenção de reator. Vigas em camadas, barris, latões e ferramentas decoram a fábrica; as vigas da frente encobrem a personagem sem bloquear fisicamente a passagem.

## Controles

- A/D ou setas: mover e escolher a direção para olhar.
- W, seta para cima ou Espaço: salto; pressione novamente para salto duplo.
- **Z:** atirar horizontalmente na direção em que a personagem está olhando. O mouse não mira nem dispara.
- **J:** soco (1 de dano). **K:** chute (2 de dano). Um acerto por golpe, alcance curto e paredes bloqueiam o ataque.
- **L, segurado:** defender. Os primeiros dois tiros são bloqueados sem perda de vida. O terceiro quebra o escudo, causa 1 de dano e empurra a personagem para trás. Após a quebra, a recarga leva 2 segundos. Ao soltar a defesa após um bloqueio, a recarga leva 1,4 segundo; alternar rapidamente a tecla não restaura os bloqueios. Ataques e tiros ficam indisponíveis durante a defesa.
- **E:** acionar botão próximo.
- Esc: pausar/retomar. Tab: menu. R: reiniciar o corredor.

Suba pelas plataformas até o botão luminoso e pressione E para liberar a porta e registrar o checkpoint. Apenas se aproximar do botão não o ativa. No **segundo corredor, a porta também está em uma plataforma alta**, acessível por outro conjunto de plataformas. Nas outras duas saídas, a porta fica ao nível do piso. A porta abre ao se aproximar depois de liberada e exige entrar na abertura para passar. A última porta encerra a campanha.

Os checkpoints ficam em memória e reiniciam ao sair/reiniciar o corredor. Quedas devolvem ao checkpoint com penalidade de vida; morte recria a personagem. A trilha fornecida toca em loop durante os corredores. O vídeo enviado pelo usuário é reproduzido ao iniciar uma nova campanha; ele não se repete após morrer ou atravessar uma porta.

## Movimento e aparência

A pose parada mantém um quadro alinhado, com respiração suave, filtro linear e interpolação física. Isso evita a tremulação e a imagem duplicada da alternância entre desenhos diferentes. Corrida, salto e pouso continuam animados. Soco, chute e defesa usam a biblioteca de poses da personagem. Os efeitos de tiro têm recuo, clarão, rastro e impactos, com colisão contínua.

As plataformas superiores permitem saltar através de baixo e sustentam a personagem ao pousar por cima. A câmera acompanha os percursos altos. Os cinco tipos de inimigos continuam presentes: patrulheiro, atirador, blindado, drone e robô. A origem CC0 da base dos inimigos está em `prototype/assets/enemies/SOURCE.md`.

## Arquivos principais

- `prototype/laboratory.gd`: corredores, plataformas, botões e progressão.
- `prototype/controller.gd`, `specimen.gd`: movimento, combate, defesa e animações.
- `prototype/factory_scenery.gd`: fundos distintos, objetos e vigas.
- `prototype/intro.tscn`, `intro.gd`, `assets/video/introduction.ogv`: vídeo e passagem ao jogo.
- `prototype/pressure_door.gd`: porta com painéis deslizantes e detecção de entrada.
- `prototype/animations/pose_preview.tscn`: prévia das 16 animações (F6). Só soco, chute e defesa foram conectados nesta revisão; espada, granada, rastejar e poder continuam como arte.
- `prototype/assets/GERACAO_V7.md`: prompts, ferramenta e arquivos das novas artes.

## Validação

```text
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/laboratory_smoke.gd
godot --headless --path . --script res://tests/security_units_smoke.gd
godot --headless --path . --script res://tests/ballistics_smoke.gd
godot --headless --path . --script res://tests/corridor_combat_smoke.gd
```

92 verificações aprovadas: 34 de campanha, 24 de segurança, 7 de balística e 27 de combate/corredores. As verificações cobrem campanha, portas, morte, checkpoint, controles, dano dos golpes, defesa e recarga, direção dos tiros, vídeo e alcance físico das plataformas até o botão. Capturas com renderização Compatibility/ANGLE também são inspecionadas. Os testes não substituem uma avaliação humana de dificuldade e ritmo.

Este computador apresenta um aviso do repositório de certificados do Windows, também presente na base; não impediu os testes locais. Novos assets e vídeo estão dentro do projeto, sem depender das pastas Downloads ou Desktop.
