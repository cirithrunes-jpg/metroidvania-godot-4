# Origem da personagem v2 e alternativas pesquisadas

## Arte integrada

`prototype/assets/specimen-female-v2.png`: imagem original gerada com a ferramenta de imagens da OpenAI em 23/10/2026 para este projeto, a partir de descricao de personagem adulta feminina biomecanica. Nao foi extraida de outro jogo nem de um repositorio de terceiros. Atlas transparente 1536 x 1024, com 6 colunas e 4 linhas. O codigo em `prototype/specimen.gd` seleciona quadros para repouso, corrida, subida, apice, queda, parede e aterrissagem. A animacao aplica respiracao, inclinacao e recuperacao de impacto suaves. O ciclo de corrida tem 6 quadros; ainda e uma primeira passagem de animacao, sujeita a ajuste artistico apos playtest.

As fontes abaixo foram pesquisadas como alternativas, mas seus arquivos NAO foram incorporados. Nenhuma atribuicao a esses artistas e reivindicada para a arte gerada.

## Alternativa no GitHub

UniversalCharacterBases, de Joy-less:
https://github.com/Joy-less/UniversalCharacterBases
Arquivo feminino: https://github.com/Joy-less/UniversalCharacterBases/blob/main/CharacterBaseFemale.png
Licenca verificada: https://github.com/Joy-less/UniversalCharacterBases/blob/main/LICENSE.txt

O repositorio oferece bases feminina e masculina. A licenca e Creative Commons Attribution 4.0 International (CC BY 4.0), permitindo compartilhamento e adaptacoes sob suas condicoes: manter creditos e avisos fornecidos, indicar modificacoes e incluir a licenca ou seu link. E uma base para personalizacao, nao uma personagem cyberpunk pronta para este controlador. Nenhum arquivo desta fonte foi baixado para o jogo.

## Outra alternativa de animacao

Huntress, de LuizMelo:
https://luizmelo.itch.io/huntress
A pagina do autor declara CC0 e uso comercial. E uma personagem de fantasia; precisaria de adaptacao visual para a direcao industrial do projeto. Esta fonte e externa ao GitHub e nao foi integrada.

Os assets que ja existiam na base do projeto permanecem com suas respectivas condicoes de uso; este documento registra somente a nova arte e as alternativas pesquisadas.

## Fundo do laboratorio v3

`laboratory-wall-v3.png`: panorama original gerado com a ferramenta de imagens da OpenAI em 23/10/2026 para este projeto. Inclui metal desgastado, concreto, tubulacoes, cabos e observatorios de laboratorio. Nao foi copiado de outro jogo nem de fonte externa. O fundo e uma imagem 2D; luzes e materiais estao pintados, sem simulacao fisica de materiais ou sombras dinamicas. A integracao preserva a proporcao do panorama, usa filtro linear e uma camada mais escura para manter a personagem e as plataformas legiveis. A geometria e as colisoes do percurso continuam as mesmas.

## Trilha fornecida pelo usuario

`steel-dungeon-soundtrack.mp3`: copia do arquivo `钢铁地牢 (2).mp3` fornecido pelo usuario e integrado a seu pedido ao laboratorio. O nome do arquivo foi simplificado dentro do projeto. Autoria e licenca nao foram informadas; este documento nao atribui uma licenca nova ao audio. Importacao Godot com loop habilitado a partir de 0 segundos. A campanha original mantem sua trilha anterior. O barramento Master foi reativado, pois estava silenciado na base.

## Inimigos adaptados de modelos existentes

A familia de seguranca usa a folha CC0 Space soldier, de drakzlin, como base editada por IA. A copia original, a origem, a licenca, as modificacoes e o hash estao registrados em `enemies/SOURCE.md`. Esse e o primeiro conjunto de arte de terceiros incorporado ao laboratorio; as alternativas UniversalCharacterBases e Huntress continuam apenas pesquisadas.

## Revisao v6: plataformas, porta e interface

`platform-steel-v6.png` e `pressure-door-v6.png`: artes originais geradas com a ferramenta de imagens da OpenAI em 23/10/2026 para o projeto, sem copiar imagens de outros jogos. Plataforma com textura metalica e porta pressurizada com paineis deslizantes montados pelo Godot. A textura da plataforma e recortada para retirar a margem da imagem e repetida ao longo da geometria. A porta usa recortes da mesma imagem para manter o batente fixo e abrir os paineis.

Os novos tiros/impactos sao desenhados por codigo em `prototype/combat`, com rastros, faiscas e clarao; nao sao gravacoes nem simulacao fotorealista. A fonte usa SystemFont do Godot (Segoe UI, Arial ou DejaVu Sans, conforme disponivel no sistema), sem copiar ou redistribuir arquivos de fontes do Windows.

O atlas antigo `player/player.png` e seu arquivo de importacao foram excluidos nesta revisao. A copia original permanece na branch de backup. A nova personagem continua usando o atlas feminino original ja documentado. O menu antigo nao e mais oferecido.

## Biblioteca de poses

`poses/combat.png`, `poses/mobility.png`, `poses/extras.png` e `poses/weapons.png`: novas artes originais geradas com a ferramenta de imagens da OpenAI em 23/10/2026 a partir do atlas existente da nossa personagem. Quatro conjuntos de acoes, incluindo movimentos, vista traseira, armas e poder de energia de linguagem anime. A folha com armas foi refeita com figuras menores para manter espadas e efeitos dentro do espaco de cada quadro. Nenhuma imagem de outra franquia foi usada como referencia. Os recortes e margens do Godot estao em `animations/actions.tres`, sem editar os pixels dos PNGs.
