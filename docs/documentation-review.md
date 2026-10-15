# Revisão documental e investigação preliminar — 14/10/2026

## Atualização: pacote de ida e volta analisado após regressão no jogo

O comparativo do usuário isolou o problema: os dados aparecem sem `LeagueStatsRoundtrip` e somem quando ele é ativado. O controle sem mod está documentado em `prints/Captura de tela 2026-10-14 160635.png`. Após o teste sem mod, `FIFA 17/ModData/Default/Update/Patch/Data/mods.json` contém `[]` (16:05:36), confirmando que o perfil atual foi compilado sem o pacote.

Análise somente leitura do FBMOD pelas assemblies locais `FrostySdk.dll`, `FrostyHash.dll` e `FrostyCore.dll`, repetível com `scripts/inspect-fbmod-legacy.ps1`, encontrou formato 5, perfil `FIFA17`, título `LeagueStatsRoundtrip`, e exatamente dois recursos Legacy relevantes:

| Recurso | Evidência interna | Leitura |
| --- | --- | --- |
| `data/ui/game/screens/career/Stats/LeagueStats.big` | Chunk ID `97a4dc55-1a51-a143-144f-08dd208bd401`; payload comprimido 5474 bytes, SHA-1 `6a2edcbb2a9da33e9ed8a6532082c50eb8e21203`; tamanho expandido declarado 21422 | Mod substitui o conteúdo Legacy por um chunk próprio. Não há exportação do BIG original completo para comparação byte a byte. |
| `Collector (Core/ChunkFiles/CFC_GameModes)` | Payload 102 bytes, SHA-1 `fabdc7e2db416ab1b45d2bfca225fa1f15653dd1`; contém uma entrada para LeagueStats, hash `0x72A29A07`, confirmado por `Frosty.Hash.Fnv1.HashString`; mesmo chunk ID, offset 0, compressed offset 0, tamanho comprimido 5474 e expandido 21422 | Mapeamento é internamente consistente com o recurso listado, mas isso não prova que o jogo o aceitou ou que os bytes reconstruídos preservam o comportamento dinâmico. |

Descompressão Zstandard do chunk, usando `ThirdParty/libzstd.dll`, revelou um `BIGF` de 21422 bytes. Dentro dele, o DAT original está byte a byte no offset 64 e o APT original no offset 13056; não há diferença nos membros em relação a `work/original`. Entre o fim do DAT (13054) e o APT há dois bytes de alinhamento; o container tem 64 bytes antes do primeiro membro. A leitura adicional da tabela pelo percurso do parser local confirmou 3 registros: DAT `0` (offset 64, 12990 bytes), marcador `sg2`, APT `1` (offset 13056, 8366 bytes); os dados nesses offsets começam com `Apt Data:1:7:8` e `Apt1`. Portanto, tabela e offsets estão consistentes com o parser do próprio plugin. Isso ainda não prova que o jogo consome a saída corretamente.

O `.fbmod` foi lido com o `FrostyMod` da build local após inicializar apenas em memória o perfil `FIFA17`; nenhum recurso foi aplicado ou escrito. A descompressão usou a `libzstd.dll` empacotada no Frosty. `7z l` não o reconhece como arquivo, o que é esperado para o formato proprietário e não indica corrupção. O assembly local `FrostyCore.dll` contém `LegacyCustomActionHandler` e PDB correspondente, mas não existe checkout de código-fonte no workspace e ILSpy não está no PATH. A branch `main` consultada do fork tem código de gravação/modificação Legacy e commits posteriores à release 2.0.1; ela não pode ser tratada como código exato dos binários locais. A release 2.0.1 declara “Fixed Mod Manager issues with legacy assets”, mas a versão/revisão dos executáveis locais não foi vinculada a esse commit. [Código Legacy na branch main](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/blob/main/FrostyPlugin/Handlers/LegacyCustomActionHandler.cs), [release 2.0.1](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/2.0.1), consulta em 14/10/2026.

### Mapeamento da tela LeagueStats

Execução somente leitura de `scripts/inspect-leaguestats.py` sobre os arquivos originais com SHA-256 fixado confirmou um APT1 parcial: palco lógico de 1280 × 720; 253 constantes (a tabela começa no offset 48); 28 personagens; um frame raiz; oito imports, entre eles `game.globalComponents.RowControl` (ID 14) e `ScrollBar` (ID 10). O movie exporta `StatsRowData` e `game.screens.career.Stats.LeagueStats`. No DAT, os placements nomeados incluem `mcScrollbar`, `mcNoData`, `mcRowControl`, `mcHeaderToggle`, `txtHeadPlayerName`, `txtHeadValue`, `txtHeadRank`, `txtHeadTeamName`, `mcIcon`, `mcCompetitionToggle` e `mcStatsToggle`. Cabeçalhos observados: Name x=266, Value x=894, Rank x=165, TeamName x=550; y=200. `mcRowControl` está em (145,233), scrollbar em (1112,233) e `mcNoData` em (271,324).

Isso estabelece um candidato real de geometria e mostra que o movie referencia componentes compartilhados para linhas e rolagem; não decodifica a lógica ActionScript nem prova como a tabela recebe/ordena dados. O leitor é parcial e deliberadamente não executa bytecode nem grava arquivos. A associação da tela ao recurso é sustentada pelo caminho Legacy `data/ui/game/screens/career/Stats/LeagueStats.big`, pelos símbolos exportados e pela captura do Data Explorer; não se deve inferir que cada elemento visual está contido nesse arquivo.

### Resultado da inspeção do parser e handler locais

O IL de `LegacyBigFileEditor.LegacyTextEditor_Loaded` confirma que o plugin local lê `BIGF`, percorre o contador de registros, interpreta `sg1` como DDS e `sg2` como APT; para registros com tamanho não zero, posiciona o stream no offset declarado e lê exatamente o tamanho indicado. O modo `-ShowExpandedHeader` em `scripts/inspect-fbmod-legacy.ps1` reproduz esse percurso sobre o payload descomprimido e encontra os três registros acima. Isso elimina offsets/tamanhos errados como hipótese imediata para este payload, mas não substitui uma leitura pelo jogo.

O IL de `LegacyCustomActionHandler.SaveToMod` local percorre `CollectorInstances`, associa hashes de caminhos aos metadados dos chunks e serializa o recurso Collector no mod. `Modify` local carrega o Collector-base, lê registros e strings, calcula hash FNV dos caminhos, substitui metadados dos nomes presentes no mod, mantém os restantes e reconstrói o chunk. A inspeção é estática: não executa o handler nem compara o Collector-base real com a saída aplicada. Logo, a falha continua associada ao pacote, mas sua causa específica ainda pode estar na aplicação/integração do Collector ou no caminho runtime do jogo.

### Próximo experimento

O pacote deve permanecer desativado fora do teste controlado. A tabela BIG foi decodificada e validada contra o parser local. O `ModData` atual corresponde ao controle sem mod (`mods.json` vazio; arquivos de saída marcados 16:05:36), então não contém a compilação com falha para análise. Próxima evidência necessária: nova compilação única com `LeagueStatsRoundtrip` ativo, inspeção da tela já conhecida, fechar o jogo e deixar a saída gerada intacta para leitura somente. Comparar `.toc/.sb` e metadados do pacote; então tentar obter o Collector-base por AssetManager offline e traçar a fusão no handler. O mapa parcial do DAT/APT identifica alvos de layout, mas não alterar geometria enquanto o roundtrip remove dados.


## Atualização: Manager não apresenta configuração de launcher customizado

Captura `prints/Captura de tela 2026-10-14 151156.png` mostra apenas `Mod Manager Options`; não há `Launch Options` nem campo para executável customizado. `Custom Mods Directory` está vazio. No ambiente, `FIFA 17/steam_appid.txt` e `FIFA 17/ModData` não existem.

Como referência, o código upstream da tag 1.0.6.3 chama o executor na ação Launch; o executor constrói `ModData/<pack>` e o `LaunchGame` direciona por Steam apenas se `steam_appid.txt` existir. Caso contrário executa `<basePath>FIFA17.exe` com `-dataPath`. Fonte: [`FrostyModExecutor.cs`](https://github.com/CadeEvs/FrostyToolsuite/blob/1.0.6.3/FrostyModSupport/FrostyModExecutor.cs#L1617-L1648), consulta em 14/10/2026. Os binários locais vêm de fork diferente e não estão ligados a commit; tratar como risco provável, não prova da implementação customizada.

`FrostyCmd.exe --help` foi testado sem parâmetros de escrita, mas não retornou ajuda; entrou em ProfileCreator e falhou com `DirectoryNotFoundException` para `Profiles.bin`. Nenhum CLI de build foi comprovado. O usuário esclareceu que, na instalação dele, o fluxo Launch chama `stp-fifa17.exe` e o STP reconhece a chamada. Isso prevalece como evidência específica do setup, embora ainda não tenhamos observado o ciclo com mod. O próximo teste vai registrar o processo real e o resultado. A ausência de Launch Options na janela não impede o fluxo relatado pelo usuário; não instalar/copiar plugins.

## Atualização: motivo da entrada Collector no pacote

Captura 150724 mostra `Show only modified` ativo com LeagueStats como único BIG modificado na árvore Legacy; Collector não aparece como segundo arquivo selecionável. O painel do Manager no pacote, porém, lista `legacy;Collector (Core/ChunkFiles/CFC_GameModes)`.

O handler de Legacy do fork, [`LegacyCustomActionHandler.cs`](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/blob/main/FrostyPlugin/Handlers/LegacyCustomActionHandler.cs), define `SaveToMod`: para cada arquivo Legacy modificado ele percorre `CollectorInstances`, serializa os metadados associados aos chunks e adiciona ao mod um `LegacyResource` usando o chunk Collector do EBX correspondente. Isso sustenta que Collector é um recurso auxiliar gerado pelo processo Legacy para mapear a reconstrução do BIG, não uma segunda edição manual. Consulta em 14/10/2026.

Limite: o código consultado está na branch `main`; os executáveis locais não estão vinculados a um commit específico. A função explica a estrutura e coincide com o nome exato exibido no pacote, mas não foi possível comparar o payload binário do Collector com o do jogo. O pacote continua sem alteração intencional de layout; a igualdade do DAT/APT só comprova os membros exportados, não a execução no jogo.

## Atualização: pacote exportado e reconhecido pelo Manager

O arquivo `roundtrip-leaguestats.fbmod` (6106 bytes; SHA-256 `F636C744670EFF8D0BC2EA3A559B24E5A25A0937B6EA9FBC9BDCEF0601C711DC`) está tanto na pasta Mods do Editor quanto na pasta Mods do Manager; os hashes coincidem. A captura `prints/Captura de tela 2026-10-14 150148.png` confirma metadados `LeagueStatsRoundtrip`, versão 0.0.1, em Available Mods, sem item visível em Applied Mods. O painel Affected Files lista `legacy;data/ui/game/screens/career/Stats/LeagueStats.big` e `legacy;Collector (Core/ChunkFiles/CFC_GameModes)`. O cabeçalho/strings do pacote também contém essas referências.

A igualdade byte a byte entre DAT/APT reexportados e originais prova que a amostra local LeagueStats não recebeu mudança. Ainda não foi extraído nem comparado o payload do `Collector`; por isso, o pacote é útil como prova de exportação e reconhecimento no Manager, mas não pode ser chamado de pacote comprovadamente sem efeito. Aplicação e lançamento devem aguardar a identificação dessa entrada adicional ou a exportação de um pacote sem ela. A tentativa de abrir como arquivo ZIP com 7-Zip falhou, o que apenas confirma que `.fbmod` usa outro formato; não prova corrupção.

## Atualização: resultado da ida e volta local

DAT e APT reexportados em work/roundtrip são idênticos byte a byte aos originais após o ciclo manual de importação do DAT/salvamento/reabertura. Projeto de laboratório cresceu de 111 para 5953 bytes e contém o caminho explícito `data/ui/game/screens/career/Stats/LeagueStats.big`. A captura 144757 registra as exportações pelo Legacy BIG Editor. Esses resultados validam preservação local da amostra, inclusive do APT não importado.

Não houve alteração de geometria. Não classificar esse teste como persistência de layout ou ida e volta validada no jogo. Crescimento do projeto aponta registro associado ao recurso, mas ainda é necessário confirmar inclusão efetiva no pacote; se Show only modified não exibir LeagueStats, registrar antes de exportar para evitar pacote vazio. O próximo teste é exportar o projeto de ida e volta e adicionar o pacote ao Manager, sem aplicar/Launch, para inspecionar compatibilidade e conteúdo.

## Atualização: operação de importação do membro DAT

Captura 144208 mostra Import File com filtro DAT (*.DAT), e o usuário confirma que é a única extensão aceita ao selecionar DAT 0. A incerteza sobre o tipo de entrada desse botão está resolvida para a operação observada: importar o DAT original no membro DAT, sem fornecer um BIG completo ou renomear APT. Não foi executada a importação ainda; o comportamento interno do plugin e a persistência permanecem desconhecidos.

Próximo teste: importar work/original/leaguestats.DAT no projeto de laboratório já criado, salvar, fechar/reabrir e reexportar DAT e APT para work/roundtrip. Comparar os dois com seus originais; observar se há marca de alteração ou se o Editor trata conteúdo idêntico como no-op. Um no-op é resultado informativo, mas não comprova que uma alteração estrutural seria persistida.

## Atualização: baseline sem mods e dispositivos

Usuário confirmou que todos os registros são de jogo sem modificações, usando teclado/mouse. Gamepad é seu uso habitual. A condição sem mods deixa de ser pergunta pendente; registrar essa confirmação como relato do usuário, sem transformá-la em auditoria criptográfica de toda a instalação. Testes futuros devem cobrir teclado/mouse e gamepad, sem presumir comportamento a partir dos ícones da captura.

## Atualização: funcionamento básico do Manager com FIFA 17

Captura `prints/Captura de tela 2026-10-14 142413.png` confirma a janela principal do Frosty Mod Manager 1.0.6.3 com perfil FIFA 17. Isso supera a evidência anterior, limitada ao seletor de jogos. O usuário informa funcionamento normal; não houve falha observada nessa imagem. Available Mods e Applied Mods estão vazios; Launch está disponível, mas não há evidência de seu acionamento ou resultado.

Editor e Manager agora têm abertura/perfil validados individualmente. Compatibilidade do pacote exportado entre ambos, lançamento pelo fluxo com stp-fifa17.exe e aplicação/remoção continuam não verificados. Não confundir janela carregada com teste de mod. A próxima investigação permanece a importação/persistência do LeagueStats sem mudança, antes de escrever geometria ou aplicar algo.

## Atualização: associação forte e geometria candidata em LeagueStats

Captura 142004 confirma LeagueStats como BIG, membros DAT 0 e APT 1, Export/Import visíveis. Os originais estão em work/original com hashes/tamanhos registrados em environment.md. A exportação da primeira amostra está concluída; não repetir o pedido de exportar esses dois membros.

O APT contém `game.screens.career.Stats.LeagueStats`, `LeagueStats::UpdateStatsList()`, `LeagueStats::UpdateRow()`, `LeagueStats::SetHeaderText()` e nomes de campos condizentes com a captura de Player Stats. Isso sustenta uma associação forte com a tela de estatísticas de jogadores, além de coincidência no nome do arquivo. A prova causal no jogo permanece pendente.

| Responsabilidade | Evidência local real | Limite |
| --- | --- | --- |
| Geometria e texto | DAT contém personagens de texto e posicionamentos nomeados txtPlayerName/txtTeamName/txtRank/txtValue e respectivos cabeçalhos; leitor parcial percorreu suas referências | Inicialização/bytecode pode alterar medidas em runtime; não testado no jogo |
| Aparência | DAT contém EACondBold e EABold; APT contém StyleManager, TEXT_COLOR, COLOR_TEXT_UNHIGHLIGHT e hasBands | Não inferir valor de cor ou estilo somente do símbolo |
| Dados | APT contém ION_CareerMode, GetScreenStaticData, GetScreenComponentData, m_arrStatsInfo, PLAYER_NAME, TEAM_NAME, VALUE, TEAM_ID, UpdateStatsList e UpdateRow | Strings são símbolos, não execução/decompilação das funções; origem final dos valores ainda não decodificada |
| Cabeçalhos/localização | APT contém TITLES, SetHeaderText, txtHeadPlayerName/Rank/TeamName/Value e NO_DATA | Textos localizados e IDs não resolvidos |
| Foco/rolagem/navegação | APT contém UI_UP/UI_DOWN, mcRowControl, highlightedRow, previousOffset/nextOffset, previousWindow/nextWindow, mcScrollbar e OnExitScreen | Presença não prova comportamento de seleção ou ação efetiva |
| Reutilização | DAT importa oito componentes de game/globalComponents/globalComponents | Recurso compartilhado não deve ser editado sem mapear outros consumidores |

### Referências de formato consultadas em 14/10/2026

Encontrada fonte primária [LibreSAGE/AptTools](https://github.com/LibreSAGE/AptTools), projeto distinto do Frosty. Seu README documenta variantes de APT e limitações de conversão SWF; o corpus declarado não demonstra compatibilidade com esta amostra de FIFA 17. Não foi instalado, compilado ou executado. Main foi consultada sem hash de commit obtido; não fixar como dependência de produção ainda.

O [leitor constfile.rs](https://github.com/LibreSAGE/AptTools/blob/main/crates/apt/src/constfile.rs) descreve Apt1 como variante de arquivo de constantes, com offset de entrada e tabela. O [leitor parse.rs](https://github.com/LibreSAGE/AptTools/blob/main/crates/apt/src/parse.rs) distingue o cabeçalho Apt Data e lê raiz, personagens, textos e controles de posicionamento; [io.rs](https://github.com/LibreSAGE/AptTools/blob/main/crates/apt/src/io.rs) especifica little-endian e alinhamento dos slots de ponteiro. Com essa referência, os cabeçalhos locais indicam que o membro rotulado DAT contém o corpo APT, enquanto o membro rotulado APT contém constantes. Não renomear os originais nem assumir equivalência por extensão.

Foi implementado um leitor diagnóstico próprio e parcial em `scripts/inspect-leaguestats.py`, sem copiar/compilar o projeto externo. Não decodifica ações, não interpreta estilos/imports em runtime, não reserializa e não gera mod. Seu suporte é deliberadamente restrito aos hashes locais. Ele permite verificar referências e campos de geometria, não a integridade semântica completa nem importação compatível.

### Resultado estrutural estático, específico dos hashes registrados

Área lógica declarada: 1280 × 720. Raiz: um frame, 28 slots. Export `StatsRowData` aponta ao personagem 7; export `game.screens.career.Stats.LeagueStats` ao personagem 24. Imports incluem ImageLoader, MainFrame, Header, ScrollBar, RowControl, EventIcon, ShoulderToggleLeft e BumperToggleLeft, todos do caminho real `game/globalComponents/globalComponents`.

| Instância | Dono / personagem referenciado | tx / ty lidos | Offset decimal do tx no DAT |
| --- | --- | --- | ---: |
| txtHeadPlayerName | 24 / 15 | 266 / 200 | 4748 |
| txtHeadRank | 24 / 17 | 165 / 200 | 4908 |
| txtHeadTeamName | 24 / 18 | 550 / 200 | 4988 |
| txtHeadValue | 24 / 16 | 894 / 200 | 4828 |
| mcRowControl | 24 / 14 (importado) | 145 / 233 | 4588 |
| txtPlayerName | 7 (StatsRowData) / 2 | 122 / 1 | 3788 |
| txtRank | 7 / 4 | 16 / 1 | 3948 |
| txtTeamName | 7 / 5 | 459 / 1 | 4028 |
| txtValue | 7 / 3 | 732 / 1 | 3868 |

São valores float32 de matrizes de posicionamento com escalas próximas de 1, obtidos percorrendo tabelas de personagens/frames/controles e lendo a instância pelo nome. As coordenadas de linha pertencem ao símbolo reutilizado, não são posições absolutas do PNG. Recorte da captura e regras em runtime impedem afirmar equivalência pixel a pixel. Offsets não foram adivinhados nem escritos e valem somente para este DAT/hash.

Os personagens 2/3/4/5 têm caixas de texto e alinhamentos distintos; cabeçalhos usam personagens separados 15/16/17/18. Assim, há rota concreta para investigar largura/alinhamento e posição sem tocar inicialmente em RowControl compartilhado. ROW_HEIGHT, STATS_LIST_VISIBLE_ROWS e rowWidth aparecem como símbolos no APT, mas seus valores/comportamento não foram decompilados. Não tratá-los como campos editáveis já localizados.

Conclusão: candidato estrutural identificado estaticamente; viabilidade prática permanece não verificada. O menor teste posterior seria deslocar somente txtHeadPlayerName no DAT, após validar importação e persistência sem mudança. Não alterar constantes, dados de linhas ou componentes globais nesse primeiro teste. Converter para SWF e voltar não é um fluxo validado e pode perder informação; não é requisito para continuar a leitura desta amostra.

Consulta do diretório LegacyBigFilePlugin no fork continuou indisponível via web; não foi confirmada a implementação de reconstrução/importação BIG dessa revisão. Essa é a próxima limitação concreta a investigar antes de escrever um pacote.

## Atualização: candidatos Legacy da carreira

Resultado manual informado: `UI` no Data Explorer contém apenas `Localization` na exploração feita. Esse resultado restringe a busca naquela pasta; não exclui recursos UI em outros catálogos. A busca prioritária passa ao Legacy, cujo caminho informado é `data/ui/game/screens/career/Stats`.

A imagem `prints/Captura de tela 2026-10-14 141719.png` confirma screens/career/Stats. Mostra também seções careerTraining, EuropeanFirstSeason, gtn, international, managermode, news, playasplayer, preSeasonTour, squad, tcmFinance, transfers e youthScout. Isso sustenta que career agrupa recursos de várias telas da carreira. Não comprova que reúna toda a UI desse modo, sua lógica, dados, componentes compartilhados ou localização. Essa abrangência continua hipótese.

| Candidato real informado sob data/ui/game/screens/career/Stats | Evidência disponível | Hipótese de investigação, ainda sem vínculo comprovado |
| --- | --- | --- |
| `leaguestats` | Entrada encontrada pelo usuário; não expandida na captura | Prioridade inicial por possível relação com estatísticas em competição, incluindo jogadores; o nome não garante Player Stats |
| `teamstats` | Entrada encontrada pelo usuário | Pode atender estatísticas de equipe; investigar depois como comparação, sem substituir automaticamente a tela alvo |
| `leaguetables` | Entrada encontrada pelo usuário | Pode atender classificação de equipes, distinta da artilharia; eventual componente compartilhado não comprovado |
| `fixtures` | Entrada encontrada pelo usuário | Pode atender partidas/resultados; prioridade menor para a tabela de artilharia |

Os nomes acima são entradas da árvore relatadas, não arquivos com formato/extensão confirmados. Não inventar .big/.apt/.xml ou interpretar propriedades antes de abri-los. Próximo passo: expandir Stats e leaguestats; registrar os nomes completos e a coluna Type, abrir um recurso pertinente e verificar Export/Import e suas dependências. Se oferecer exportação, preservar um original sem alterações e analisar cabeçalho/estrutura antes de reimportar.

Busca adicional somente de sequências ASCII no cache principal por ui/game/screens/career, leaguestats, leaguetables e teamstats não retornou resultados. Isso não invalida a árvore Legacy: o cache não foi interpretado com leitor de formato e pode não armazenar esses nomes nesse registro. Nenhum candidato novo foi inferido a partir dessa ausência.

Geometria, ligação dos dados e navegação da tabela ainda não foram identificadas. Localização em pasta de stats é uma pista de associação, não prova estrutural. Captura de seletor do Manager `140816.png` confirma abertura básica da janela, sem validar reconhecimento da instalação ou aplicação/remoção de mod.

## Atualização: funcionamento básico do Editor comprovado

O usuário concluiu salvar/reabrir um projeto vazio. Arquivo real: `frosty_projects/vazio.fbproject`; hash e capturas em `environment.md`. A imagem `prints/Captura de tela 2026-10-14 140605.png` mostra Editor 1.0.6.3 (FIFA 17), Data Explorer com pastas e log `Initialization complete`. Assim, abertura/perfil e ciclo básico do projeto deixam de ser apenas funcionalidades encontradas estaticamente e passam a resultados de teste manual neste ambiente. O título da captura é New Project.fbproject; a reabertura do arquivo salvo é evidência relatada pelo usuário, não observação direta do agente.

Data Explorer está acessível; Legacy Explorer tem aba visível, mas seu conteúdo ainda precisa ser explorado. A lista de 46 plugins mostra confirmações e alguns `!`, cujo significado específico não foi investigado. Não classificar os plugins com `!` como falhas sem ler seus detalhes e não instalar dependências preventivamente.

Próximo alvo de leitura: pastas reais `UI`, `Fifa` e `Content`, e catálogo Legacy. O campo `Filter` visível pode filtrar nomes; não há evidência de que pesquise conteúdos localizados. Usar `stats`, `statistics`, `career`, `player`, `table` como consultas de nomes; usar Player Stats/Top Scorers/No Statistics Available como pistas de localização apenas onde existir pesquisa de conteúdo/textos.

Uma busca estática delimitada no cache `Caches/fifa17.cache`, por sequências ASCII com barra e padrões player-stat/top-scorer/career-stat, não encontrou candidato pertinente (os dois resultados eram de estado de jogador online e foram descartados). Isso não exclui recursos da tabela: cache não foi decodificado por um leitor de formato e não substitui explorar catálogos principal/Legacy. Não foi identificado recurso estrutural novo nesta atualização.

As seções históricas abaixo que afirmam ausência de projeto/teste de abertura descrevem a inspeção inicial. Exportar/importar recursos, persistir mudanças, exportar mod e usar o Manager continuam sem teste.

## Atualização: tela identificada e Editor extraído

**Baseline populado recebido e examinado:** `prints/Captura de tela 2026-10-14 140230.png`. Mantém competição NA Allstars Trophy e categoria Top Scorers; oito posições visíveis. Primeira linha: Rank 1, Gashi, Colorado Rapids, Goals 2; segunda: Rank 2, Ramírez, Club Atlas, Goals 1. As demais linhas também mostram jogadores, escudos, equipes e gols. Há nomes com acentos e múltiplas palavras, úteis para futuros testes de recorte/alinhamento. A associação visual dos dados está documentada; nenhuma linha selecionada ou ação de rolagem pode ser confirmada pela imagem. A existência de estados vazio e populado constitui evidência de apresentação nos dois estados; não demonstra a causa da atualização nem a lógica dinâmica. As observações seguintes sobre ausência de linhas referem-se à captura anterior, não ao estado atual da investigação.

As conclusões sobre ausência de captura e Editor compactado nos registros iniciais abaixo foram superadas. As referências web não foram consultadas novamente nesta atualização. O usuário indicou o par de ferramentas disponível e o launcher `stp-fifa17.exe`; a extração do Editor foi confirmada por presença e hashes de EXE/SDK/perfil. O Manager permanece distinto do ZIP histórico; nenhuma incompatibilidade foi reproduzida.

Tela alvo: carreira → Season → Player Stats. Percurso completo informado: `Home → Load Career → Choose save → Central → Season → Player Stats`. Capturas em `prints` corroboram Central, Season e a tela final; a imagem do menu principal está na aba PLAY, não HOME. Essa diferença é apenas um limite da cobertura visual, sem necessidade de refazer o percurso já informado. As seções seguintes preservam a pesquisa inicial; afirmações de ausência de captura ou Editor extraído devem ser lidas como estado anterior a esta atualização.

| Elemento observado em `prints/Captura de tela 2026-10-14 135842.png` | Evidência | Consequência para investigação |
| --- | --- | --- |
| Título | `Player Stats` | Consulta textual real para localizar a tela |
| Contexto de competição | `NA Allstars Trophy` | Baseline atual pertence a esse contexto; outros podem ter dados |
| Categoria | `Top Scorers` | Primeiro estado tabular definido |
| Cabeçalhos | `Rank`, `Name`, `Team`, `Goals` | Quatro colunas no estado capturado; largura/alinhamento ainda sem propriedades identificadas |
| Área de conteúdo | `No Statistics Available` | Há apenas estado vazio; sem evidência de linhas ou valores |
| Ajuda de entrada | Ícones W/E junto à competição, X/C junto à categoria, Esc Back | Pistas de interação visual; ações não testadas pelo agente |
| Apresentação | Painel central escuro, faixas de título/cabeçalhos, fundo do estádio | Descrição visual; nenhum vínculo com recurso interno confirmado |

Pesquisar inicialmente `Player Stats`, `Top Scorers` e `No Statistics Available`, além das consultas funcionais anteriores. Esses textos são evidências da captura, não nomes de arquivos ou identificadores. Cabeçalhos comuns como Name/Team podem gerar falsos positivos. Não converter medidas dos PNGs recortados em coordenadas nativas antes de identificar o formato.

Geometria, dados e navegação continuam sem candidato interno. Inglês está visualmente confirmado; PT-BR permanece alvo de planejamento, sem validação nesta instalação. Uma captura populada em contexto já existente permitirá distinguir largura de colunas, alinhamento dos valores, linha selecionada e rolagem. Não avançar nem sobrescrever a carreira pessoal para produzir dados nesta auditoria.

## Fontes e alcance da consulta

| Fonte | Consulta | Resultado e limite |
| --- | --- | --- |
| `Planejamento_Mod_Interface_FIFA_17.md` | Local, completo, 14/10/2026 | Plano vigente; fases F17-01 a F17-09 e critérios, sem evidência local de conclusão |
| `Planejamento_Mod_Interface_FIFA_16_17.md` | Local, completo, 14/10/2026 | Referência anterior; escolha entre jogos superada pelo escopo exclusivo FIFA 17 deste pedido |
| `FIFA 17/_README.txt` | Local, completo, 14/10/2026 | Procedimento da distribuição/launcher; não é documentação do Frosty nem confirmação de execução |
| README de vgmstream nos ZIPs | Local, completo, 14/10/2026 | Biblioteca de áudio; não demonstra formato ou edição da UI |
| [Repositório e README do fork](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition) | Web, 14/10/2026 | README e árvore acessíveis; branch apresentada como main |
| [Releases do fork](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases) | Web, 14/10/2026 | Notas de versões acessíveis; listagem de assets falha ao carregar |
| [Release 2.0.1](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/2.0.1) | Web, 14/10/2026 | Indicada Latest; tag 2.0.1, commit abreviado 57456e7; sem digest de pacote acessível |
| [Plugins na main](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/tree/main/Plugins) | Web, 14/10/2026 | Nomes dos módulos acessíveis; não foram obtidos corpos de implementação |
| [Tópico do desenvolvedor, página 1](https://soccergaming.com/forums/threads/frosty-editor-fifa-17-edition-2-0-released-mesh-importion-support-unlimited-real-faces-in-the-game-sound-editing-and-more.6475801/) | Web, 14/10/2026 | Anúncio e explicações do autor lidos; discussões posteriores, 15 páginas no total, não revisadas integralmente |
| Program.cs de FrostyCmd e csproj do Editor, main/raw e tentativa por commit | Web, 14/10/2026 | Cache miss/erro de obtenção; implementação não acessível |
| API releases e issues do mesmo repositório | Web/shell, 14/10/2026 | API indisponível no navegador; shell com conexão recusada pelo proxy local. Página issues não obtida |

Há acesso parcial à internet, suficiente para notas públicas; não suficiente para fixar hashes dos assets remotos ou auditar fontes. Não foi contornada a restrição de rede, nem clonado/compilado um projeto. Resultados de busca de outros Frosty/CLIs não foram usados como evidência da implementação deste fork.

## Planejamento versus estado encontrado

O plano exige mudança estrutural nativa, dados dinâmicos e navegação; permanece o critério do projeto. As fases e estimativas são propostas, não resultados. Nenhuma versão de textura, overlay ou mockup foi aceita como prova estrutural.

A referência principal do plano é a release 2.0. As notas públicas agora apresentam 2.0.1 com importação/exportação em lote de Legacy e correção no Manager para esses recursos. Isso torna 2.0.1 candidata a avaliação, sem provar edição da tabela. [Notas do mantenedor](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/2.0.1).

A página de releases associa 2.0/newrelease a `dd6b90a` e 1.0/release a `8885c8e`. As notas 1.0 distinguem duplicação DDS funcional de duplicação BIG sem resultado no jogo. É uma limitação histórica dessa versão, não prova de que o mesmo problema persiste ou foi resolvido em qualquer binário local. [Histórico de releases](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases).

O README ainda orienta branch 1.0.6, VS 2019 e DeveloperDebug/x64. A árvore exibida é main, e não há checkout para confrontar configurações de projeto. Não executar essa receita como se fosse revisão fixada. A licença declarada é CC BY-NC-ND 4.0; eventual redistribuição de ferramentas alteradas precisa ser avaliada separadamente. [README do fork](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition).

O nome local `FrostyToolsuite-FIFA17editionv3fixed` não coincide com os rótulos públicos consultados. Os EXEs locais declaram 1.0.6.3, sem identificar a revisão modificada. Não há vínculo comprovado entre os hashes locais e uma release. O Manager já extraído difere do Manager ZIP e do SDK compartilhado pelos ZIPs. Não repetir tentativa com mistura de DLLs.

## Funcionalidades: níveis de evidência

| Tema | Documentado | Encontrado estaticamente neste ambiente | Testado |
| --- | --- | --- | --- |
| Exportar/importar recursos | Autor explica botões de import/export para meshes e áudio, com limites por tipo | Editor contém símbolos contextMenuImportAsset_Click, contextMenuExportAsset_Click e Import/Export; plugins especializados presentes | Somente leitura estática; operações não testadas |
| Recursos principais | Estrutura do fork expõe SDK/Editor/Plugins | Rótulo `Data Explorer`; AssetManager com EnumerateEbx/EnumerateRes/EnumerateChunks | Catálogo não aberto |
| Legacy | Release 2.0.1 anuncia operações em lote e correção do Manager | `Legacy Explorer`, LegacyFileManager, plugins FIFA; Legacy BIG Editor com Import File/Export File | Catálogo/gravador não testados |
| Projeto e mod | Fluxo previsto pelo plano, não certificado pelo README | Rótulos New Project/Open Project/Save Project/Save Project As, atalhos Ctrl+N/Ctrl+O/Ctrl+S/Ctrl+Shift+S; Export to Mod | Salvar, reabrir e exportar não testados |
| Texto e formatos | Não há documentação de formato da tabela | LegacyTextPlugin registra strings XML/TXT/LUA/CSV/INI/H/JSON/HTML/PRE; BIG plugin contém BIG/AST e referência a Apt.png | Não identifica formato da tela; nenhum recurso correspondente exportado |
| Serialização | Módulo SDK remoto presente | Símbolos EbxReader/EbxWriter, V2, DbReader/DbWriter, Serialize | Corpos de métodos não auditados; ida e volta não testada |
| CLI | Sem manual obtido para FrostyCmd deste fork | EXE real no ZIP; strings ProfileCreator/CreateProfiles/CreateFIFA17Profile e FIFA20SDK | Nenhum comando executado; export/import por CLI não demonstrados |

As explicações do autor mostram funcionalidades de meshes/áudio e limites específicos. Não foi encontrada nelas uma promessa de editor de layout de tabelas. [Explicações do autor](https://soccergaming.com/forums/threads/frosty-editor-fifa-17-edition-2-0-released-mesh-importion-support-unlimited-real-faces-in-the-game-sound-editing-and-more.6475801/).

“Encontrado estaticamente” significa nomes de classes/métodos e strings do binário ou árvore remota, não análise do código-fonte nem comprovação de comportamento. Em particular, símbolos de perfis não autorizam inventar parâmetros de FrostyCmd. Não executar `--help` de binário desconhecido sem saber se trata argumentos; ele pode iniciar outra tarefa.

## Combinação e dependências

Não é possível indicar uma combinação já validada para esta instalação. O par dos ZIPs locais é um candidato por compartilhar exatamente FrostySdk.dll e Fifa17SDK.dll, mantendo os pacotes completos e separados. Sua origem ainda precisa ser estabelecida. Se ela não puder ser recuperada, obter um par da mesma release do fork, com origem registrada; 2.0.1 merece avaliação pela correção Legacy anunciada. Não substituir silenciosamente a base nem presumir que a release pública é idêntica ao pacote local.

Os `.exe.config` dos ZIPs exigem .NET Framework 4.8. A família instalada aparece no registro; runtimes dotnet 8–10 não são substitutos. O Manager extraído empacota instalador 4.7.2, mas isso não redefine o requisito dos ZIPs. VC++ x64 está instalado, porém não houve análise completa de imports nativos nem carregamento de plugins. Só instalar dependência se um erro ou documentação da revisão concreta apontar qual falta.

Não há problema de persistência reproduzido neste ambiente. “Salvar e perder a mudança” é um risco descrito no planejamento, não um defeito observado. A correção Legacy das notas 2.0.1 não explica quais formatos/casos cobre e não comprova persistência da UI. Sem fontes individuais ou logs, não há fundamento para afirmar mais.

## Amostra preliminar da interface

Não existem exportações ou projetos anteriores. Foi examinada uma amostra pequena de arquivos já existentes: dois pares `ui.toc/ui.sb`, sem descompactar CAS nem interpretar campos estruturais.

| Caminho real relativo à raiz | Bytes | SHA-256 | Evidência e limite |
| --- | ---: | --- | --- |
| `FIFA 17/Data/Win32/ui.toc` | 2173 | `e27c306244231b50a178b92986b6ccd6952991b57a4c09da1a7403ddf04c050b` | Nome sugere catálogo UI; nenhum layout decodificado |
| `FIFA 17/Data/Win32/ui.sb` | 36998 | `6318ea9c872e7156c987dd38cd28fdad40cde257f5863e8acd641717a67e6863` | Strings `bundles`, `magicSalt`, `fonts/eabold`, `fonts/eamedium`, `fonts/eaheavybold`, `fonts/eacondmedium`, `fonts/eacondbold`, `originalSize` |
| `FIFA 17/Update/Patch/Data/Win32/ui.toc` | 2173 | `e3a8c60c92b9d21d5c1f8dd2378d1b806ad72fe984036f82d6466630dbf54016` | Há versão de patch distinta; prioridade efetiva não testada |
| `FIFA 17/Update/Patch/Data/Win32/ui.sb` | 35915 | `adc5dd40731ff1e53801c5efe5e28485977c6a8f2a61f0e629e0658fd4f82182` | Também contém referências a fontes; bytes diferem da base |

Foram lidos prefixos binários e extraídas sequências ASCII imprimíveis com `re.findall(rb'[\x20-\x7e]{6,}', data)`. Não houve escrita, parser experimental nem atribuição de offsets. `originalSize` é uma string do pacote; não foi identificada como tamanho de linha/coluna. Os caminhos de fontes são strings observadas, não recursos já localizados e validados no Editor.

| Responsabilidade | Pista disponível | Associação com a tabela |
| --- | --- | --- |
| Geometria/layout | Nenhuma propriedade identificada | Não verificada |
| Texturas/fontes/aparência | Referências de fontes em ui.sb; plugins de textura/atlas | Pista de UI geral, sem vínculo específico |
| Textos/localização | Plugin LegacyLocalizedStrings e recurso PT-BR do configurador | Não demonstra texto dos cabeçalhos da tela |
| Dados/linhas/colunas | Nenhuma exportação ou referência concreta | Não verificada |
| Foco/seleção/rolagem/navegação | Nenhum candidato identificado | Não verificada |

Não se presume XML, Lua, APT, SWF, HTML ou outro formato a partir dos plugins. Não se conclui que toda a UI esteja no superbundle de nome ui. As referências a fontes não bastam para concluir editabilidade estrutural.

## Pontos de investigação e dúvidas delimitadas

- No código remoto, os módulos reais `FrostySdk`, `FrostyPlugin`, `FrostyEditor`, `FrostyCmd` e `Plugins/Fifa` são pontos para procurar leitores, gravadores e persistência. Sem revisão local ou corpos acessíveis, ainda não há resultado de análise fonte.
- Após identificar o recurso no Editor, seguir o plugin/definição de tipo responsável; investigar só o leitor necessário. `EbxToXmlPlugin` pode oferecer uma representação, mas seu nome não garante importação simétrica ou formato nativo XML.
- Determinar se a origem do pacote local corresponde a uma release anterior corrigida, a 2.0.1 ou a uma compilação diferente; os números PE não resolvem essa dúvida.
- Confirmar acesso real a Data Explorer e Legacy Explorer e a prioridade da versão de patch. Somente então selecionar um recurso pequeno e rastreável.
- Confirmar comportamento de salvar/reabrir antes de qualquer redesign e de exportar/aplicar/remover em etapa posterior autorizada. Nenhum desses testes foi concluído nesta auditoria.
