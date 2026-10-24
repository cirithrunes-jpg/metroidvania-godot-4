# Laboratório — controles personalizáveis e objetos quebráveis (v9)

Projeto de `cirithrunes-jpg/metroidvania-godot-4`, branch `feature/laboratorio-cyberpunk`.
Original preservado em `backup/original-2026-10-23`, commit `32b73e35851e0f6eb58ba2469b38e3d73daccd9a`. A main não foi alterada.

## Abrir e jogar

1. Extraia o ZIP atualizado em uma pasta nova.
2. No **Godot 4.7.2** (versão testada), importe `project.godot` e aguarde a importação.
3. Pressione **F5**, escolha **Jogar** e assista à introdução. Espaço, Enter, A/✕ ou Menu/Options pulam o vídeo. Em seguida aparece uma tela preta com **MISSÃO: PROTOCOLO DE COMBATE ATIVADO**, com entrada e saída suaves do letreiro, antes da fase.

O ZIP local inclui o vídeo enviado. O vídeo não foi incluído no repositório público: essa publicação aguarda autorização explícita. Sem o arquivo `prototype/assets/video/introduction.ogv`, o jogo segue para a tela de missão e depois inicia a fase.

A campanha tem **três corredores conectados**, cada um com 1920 unidades de comprimento (antes 960), câmera com movimento vertical, plataformas adicionais e 11 unidades de segurança. Os fundos mudam entre laboratório, fábrica de turbinas e manutenção de reator. Vigas em camadas, quatro barris/latões quebráveis por corredor e poucas ferramentas decoram a fábrica; as vigas da frente encobrem a personagem sem bloquear fisicamente a passagem.

## Controles

- A/D ou setas: mover e escolher a direção para olhar.
- W, seta para cima ou Espaço: salto; pressione novamente para salto duplo.
- **Z:** atirar horizontalmente na direção em que a personagem está olhando. O mouse não mira nem dispara.
- **J:** soco (1 de dano). **K:** chute (2 de dano). Um acerto por golpe, alcance curto e paredes bloqueiam o ataque.
- **L, segurado:** defender. Os primeiros dois tiros são bloqueados sem perda de vida. O terceiro quebra o escudo, causa 1 de dano e empurra a personagem para trás. Após a quebra, a recarga leva 2 segundos. Ao soltar a defesa após um bloqueio, a recarga leva 1,4 segundo; alternar rapidamente a tecla não restaura os bloqueios. Ataques e tiros ficam indisponíveis durante a defesa.
- **E:** acionar botão próximo.
- Esc: pausar/retomar. Tab: menu. R: reiniciar o corredor.

Suba pelas plataformas até o botão luminoso e pressione E para liberar a porta e registrar o checkpoint. Apenas se aproximar do botão não o ativa. No **segundo corredor, a porta também está em uma plataforma alta**, acessível por outro conjunto de plataformas. Nas outras duas saídas, a porta fica ao nível do piso. A porta abre ao se aproximar depois de liberada e exige entrar na abertura para passar. A última porta encerra a campanha.

Salvar progresso no menu de pausa grava setor, botão/checkpoint, vida, inimigos restantes e objetos ainda inteiros em `user://cyberpunk_campaign_v1.json`. No menu principal, Continuar progresso salvo restaura a partida pelo checkpoint, sem repetir vídeo e missão. Jogar começa uma campanha nova e preserva o save anterior até salvar novamente. Quedas devolvem ao checkpoint com penalidade de vida; morte recria a personagem. A trilha fornecida toca em loop durante os corredores. O vídeo enviado pelo usuário é reproduzido ao iniciar uma nova campanha; ele não se repete após morrer ou atravessar uma porta.

## Movimento e aparência

A personagem agora fica com o rifle nas mãos. Uma nova folha de animação fornece poses de corrida armada, disparo e defesa, com recortes alinhados e sem o desenho simples de arma que ficava sobreposto. A pose parada mantém um quadro alinhado, com respiração suave, filtro linear e interpolação física. Isso evita a tremulação e a imagem duplicada da alternância entre desenhos diferentes. A corrida tem oito entradas de quadros e velocidade proporcional ao movimento. A defesa tem preparação, pose sustentada animada e reação ao impacto; solte L/L1/LB para baixar o escudo. Soco e chute usam a biblioteca de poses da personagem. Sons próprios acompanham tiros e impactos; a personagem tem duas vocalizações femininas de dor sintetizadas localmente. Os efeitos de tiro têm recuo, clarão, rastro e impactos, com colisão contínua.

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

142 verificações passaram: 35 de campanha, 24 de segurança, 7 de balística, 27 de combate/corredores, 23 de controles/pausa/áudio/missão/save e 26 de personalização de comandos/pôster/objetos. As verificações cobrem campanha, portas, morte, checkpoint, controles, dano dos golpes, defesa e recarga, direção dos tiros, vídeo e alcance físico das plataformas até o botão. Capturas com renderização Compatibility/ANGLE também são inspecionadas. Os testes não substituem uma avaliação humana de dificuldade e ritmo.

Este computador apresenta um aviso do repositório de certificados do Windows, também presente na base; não impediu os testes locais. Novos assets e vídeo estão dentro do projeto, sem depender das pastas Downloads ou Desktop.


## Controle Xbox / PlayStation

| Ação | Xbox | PlayStation |
| --- | --- | --- |
| Mover | Analógico esquerdo / direcional | Analógico esquerdo / direcional |
| Salto e salto duplo | A | ✕ |
| Atirar | RT ou RB | R2 ou R1 |
| Soco | X | □ |
| Chute | B | ○ |
| Defesa (segurar) | LB ou LT | L1 ou L2 |
| Acionar botão | Y | △ |
| Pausar | Menu | Options |

Na pausa há Continuar, Salvar progresso, Controles e Menu principal. Navegue com direcional/analógico e confirme com A/✕. No teclado, use setas e Enter. Os comandos de teclado anteriores permanecem disponíveis. O suporte usa o mapeamento padrão de controles do Godot/SDL, sem exigir mouse na campanha. Os testes usam eventos de controle simulados; o comportamento de cada controle físico depende também do driver reconhecido pelo Windows.

As vozes são sintéticas, geradas pela voz Microsoft Maria instalada no Windows, sem imitar uma pessoa real. Efeitos de tiro, impacto e escudo são sínteses originais, geradas para o projeto. Arte e prompt em `prototype/assets/GERACAO_V8.md`. Teste adicional: `godot --headless --path . --script res://tests/v8_controls_save_smoke.gd`.


## Personalizar os comandos (v9)

No menu principal, escolha **Configurar controles**; durante a fase, use **Pausa → Controles**. A tela tem uma coluna de teclado e outra de Xbox/PlayStation para cada uma das onze ações, incluindo movimento, salto, tiro, soco, chute, defesa, interação, pausa, reinício e menu principal.

Selecione a célula da ação, pressione a tecla ou botão/gatilho/analógico desejado e use **Salvar e voltar**. Se o comando já estiver em uso, as duas ações trocam os comandos dessa categoria. **Voltar sem salvar** descarta as alterações. **Restaurar padrão** permite recuperar os comandos originais; salve em seguida para manter. Esc cancela a captura e permanece disponível para acessar a pausa, mesmo que você mude o comando de pausar. A navegação dos menus usa setas/direcional e Enter/A/✕, separadamente dos comandos da personagem.

As configurações ficam em `user://cyberpunk_controls_v1.cfg`, separadas do progresso da campanha. Elas são carregadas ao abrir o jogo e permanecem após morte, troca de corredor e nova campanha. HUD e tela de configuração mostram os comandos atuais. Mouse continua sem função de mira/disparo; pode ser usado nos menus.

## Menos latas, com destruição

Cada corredor agora tem **duas latas e dois barris**. Uma lata quebra com um tiro; um barril aguenta dois. Socos, chutes e tiros dos inimigos também atingem os objetos. Há impacto sonoro e faíscas; os objetos não explodem e não travam a passagem da personagem. O salvamento mantém a destruição e o dano dos objetos. Saves anteriores continuam compatíveis e começam com os quatro objetos inteiros.

O menu principal usa o pôster original da personagem já criado para o projeto: `prototype/assets/menu-poster.png`, cópia de `poster-anime-01.png`, sem modificar os pixels. A ilustração fica separada dos botões e mantém a proporção. A foto do controle enviada foi usada apenas como referência de nomes; não é redistribuída. As folhas de poses enviadas correspondem à biblioteca existente e não foram usadas para substituir as animações nesta revisão.

Teste da revisão: `godot --headless --path . --script res://tests/v9_remap_props_smoke.gd`. Ele cobre captura de comandos, conflitos, persistência, cancelamento, spawn após remapeamento, HUD, pausa, pôster, dano por projéteis/golpes e restauração dos objetos no save.
