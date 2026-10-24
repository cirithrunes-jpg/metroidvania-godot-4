# Fonte dos modelos e adaptacoes

Base: **Space soldier (sprite sheet 32x32)**, de **drakzlin**.
Pagina original: https://opengameart.org/content/space-soldier-sprite-sheet-32x32
Arquivo original: https://opengameart.org/sites/default/files/all_sprites.png
Licenca informada na pagina do autor: **CC0 1.0**.
Texto da licenca: https://creativecommons.org/publicdomain/zero/1.0/
Consulta e download: 23/10/2026.
Copia preservada: `source/drakzlin-space-soldier.png`.

O arquivo original inclui o soldado de capacete, um drone em forma de disco e um robo humanoide. A ferramenta de imagens da OpenAI foi usada para editar/adaptar essa folha como referencia de origem: materiais de metal desgastado, armaduras grafite, pequenos visores ciano/vermelhos, rifles e silhuetas ajustadas para o laboratorio.

Resultado: `security-family.png`, folha transparente com 6 colunas e 5 linhas de variantes. As linhas possuem alturas diferentes; os recortes explicitos em `prototype/enemies/security_unit.gd` preservam cada unidade sem vazar as linhas vizinhas. A imagem derivada e uma adaptacao assistida por IA, nao arte original de drakzlin nem uma aprovacao dele ao projeto. A fonte CC0 foi preservada sem modificacoes.

Variantes: patrulheiro, atirador, blindado, drone e robo de contencao. As tres variantes de soldado derivam do mesmo modelo de base, com armamento, protecao, visores e parametros diferentes. Drones e robos derivam das respectivas silhuetas presentes na folha de origem.

A IA, os projeteis, os indicadores de ataque e os parametros de combate foram implementados para este projeto. Audio e efeito de destruicao reaproveitam os sistemas que ja existiam no repositorio.

SHA-256 do arquivo fonte preservado: `EDF8A967D0575C7412F39C269DBBC3D26FA349A5CAB79304365E4F5F11152DFA`.
