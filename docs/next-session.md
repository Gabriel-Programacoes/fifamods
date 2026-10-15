# Retomada — 14/10/2026

Preferência de trabalho do usuário: terminar cada resposta de andamento com suas tarefas numeradas, passo a passo, incluindo a evidência que deve retornar. Manter explicação curta, não repetir tarefas concluídas e indicar explicitamente quando não houver tarefa manual pendente.

## Próximo passo ativo

**Tarefa manual necessária:** a compilação com mod foi substituída pelo controle sem mod (`mods.json` agora é `[]`; arquivos gerados têm data 16:05:36). Para inspecionar a saída exata do Manager, repita uma única vez: (1) no Frosty Mod Manager, ative somente `LeagueStatsRoundtrip`; (2) use Launch para iniciar pelo fluxo já confirmado do `stp-fifa17`; (3) chegue a Player Stats e confirme o comportamento conhecido, sem avançar nem salvar progresso; (4) feche o jogo e deixe o mod aplicado no Manager; não compile sem mod ainda; (5) responda “pronto”. Não precisa nova captura se o resultado repetir o anterior. Assim que avisar, vou ler `FIFA 17/ModData/Default/Update/Patch/Data/mods.json` e os arquivos `.toc/.sb` resultantes, comparando metadados com o FBMOD. O parser local já confirmou os 3 registros BIG: DAT (`0`, offset 64, 12990 bytes), marcador `sg2`, APT (`1`, offset 13056, 8366 bytes), com assinaturas válidas. `LegacyCustomActionHandler` foi lido estaticamente: `SaveToMod` serializa registros Collector e `Modify` os mescla por hash FNV com registros-base. Não repetir o controle sem mod.

## Estado mais recente: regressão isolada ao pacote (14/10/2026)

**Correção do diagnóstico anterior:** o usuário testou o mesmo save/contexto com `LeagueStatsRoundtrip` desativado; os dados retornaram, como mostra `prints/Captura de tela 2026-10-14 160635.png` (oito linhas). Com o mod ativo, os dados desaparecem, segundo relato do usuário. A associação ao pacote/aplicação está fortemente sustentada. A leitura estática confirmou o BIG e os membros com o parser local; ainda falta comparar o Collector-base e a saída efetivamente gerada pelo Manager/runtime. Não repetir agora a ativação. Preservar o pacote atual como caso mínimo de falha e analisá-lo offline antes de qualquer novo teste no jogo. Para completar o registro, uma captura do estado com mod só é necessária se ela puder ser recuperada sem repetir o teste.

A inspeção do FBMOD com `scripts/inspect-fbmod-legacy.ps1` confirma que ele tem uma entrada `LeagueStats.big` (chunk `97a4dc55-1a51-a143-144f-08dd208bd401`, 5474 bytes comprimidos, 21422 expandidos) e uma entrada Collector de 102 bytes. O mapeamento Collector tem hash FNV1 correto e aponta para esse chunk. O parser local confirmou no BIGF os registros DAT e APT, offsets, tamanhos e assinaturas. Isso comprova consistência interna contra o parser, não integração Collector/runtime. Depois do teste de controle, `ModData/.../mods.json` ficou `[]`; o pack deve permanecer desativado.

Leitura de `scripts/inspect-leaguestats.py` (sem execução de bytecode, sem escrita) mapeia o APT1: 1280×720, 253 constantes, 28 personagens e 1 frame; imports incluem `RowControl` e `ScrollBar`; exports incluem `StatsRowData` e `game.screens.career.Stats.LeagueStats`. Placements reais incluem os cabeçalhos Rank x=165, Name x=266, Team x=550, Value x=894, y=200; `mcRowControl` (145,233), `mcScrollbar` (1112,233), `mcNoData` (271,324). É evidência para planejar geometria, não uma instrução para patch. O leitor não decodifica lógica, não prova qual script preenche as linhas e não fornece writer.

O assembly local expõe `LegacyCustomActionHandler`, com PDB; o código-fonte exato/commit não está no workspace e ILSpy não foi encontrado. A branch `main` do fork e a release 2.0.1 são referências, não identificação da build local. A leitura de IL usada para mapear `SaveToMod` e `Modify` está disponível em `scripts/inspect-legacy-plugin-il.ps1`; próximo passo local é examinar a saída ModData e comparar a fusão do Collector. Ver `docs/documentation-review.md` para hashes e limites.

O teste com mod compilou sem crash: `prints/155707.png` registra `Applied Mods in 0m 14s` e `Done`; `FIFA 17/ModData/Default/Update/Patch/Data/mods.json` lista `LeagueStatsRoundtrip`. `prints/155652.png` mostra que o jogo abriu. O conteúdo interno específico consumido pelo jogo não foi confirmado.

As capturas antigas mostram estados vazio e populado; `prints/160635.png` confirma oito linhas sem mod no contexto do teste. DAT/APT exportados após a ida e volta são byte a byte iguais aos originais, mas o BIG/Collector reconstruído continua suspeito. A captura da tela com mod ainda não foi localizada.

O controle sem mod foi concluído: os dados retornaram. Não é necessário repeti-lo. Mantenha `LeagueStatsRoundtrip` desativado enquanto analisamos offline o recurso Legacy e a geração do Collector; evite nova aplicação até identificarmos uma hipótese corrigível.

## Estado de pacote e Collector (evidências anteriores)

DAT/APT de `work/roundtrip` são byte a byte iguais aos originais após importação/salvamento/reabertura. O pacote `roundtrip-leaguestats.fbmod` (6106 bytes; SHA-256 `F636C744670EFF8D0BC2EA3A559B24E5A25A0937B6EA9FBC9BDCEF0601C711DC`) existe nas pastas Mods do Editor e Manager com hashes iguais. Captura `prints/Captura de tela 2026-10-14 150148.png` confirma Available Mods e os dois itens afetados: `legacy;data/ui/game/screens/career/Stats/LeagueStats.big` e `legacy;Collector (Core/ChunkFiles/CFC_GameModes)`. Captura `prints/Captura de tela 2026-10-14 150724.png` mostra Show only modified ativo e somente LeagueStats no projeto; Collector não é um item Legacy separado na árvore.

O código `LegacyCustomActionHandler.cs` no fork consultado explica a entrada: `SaveToMod` percorre recursos Legacy modificados, obtém seus `CollectorInstances`, serializa nome/hash e metadados de chunks, e inclui um `LegacyResource` do chunk Collector no pacote. Isso indica que o Collector é o mapa auxiliar necessário à reconstrução do arquivo Legacy, e não uma segunda alteração escolhida pelo usuário. O binário local não está ligado a commit/revisão exata, então registrar como explicação fortemente sustentada pela captura e pelo código do fork, sem alegar hash do payload Collector comparado ao jogo.

O ciclo de aplicação foi executado e gerou ModData; a comparação confirmou que os dados somem com o mod. Não repetir até análise estática ou correção controlada. O usuário confirma que Launch usa `stp-fifa17.exe` neste setup.

## Atualização: pacote ativado no perfil do Manager (14/10/2026 15:09)

Captura `prints/Captura de tela 2026-10-14 150901.png` mostra LeagueStatsRoundtrip marcado em Applied Mods no pack Default. O Log contém apenas inicialização do Manager às 14:08 e aviso de diretório customizado inexistente, usando o padrão; não há registro de compilação. Consulta local não encontrou `FIFA 17/ModData`. Assim, a lista de Applied Mods confirma seleção/ativação no pack, mas não confirma execução do Mod Executor nem geração de ModData. Corrigir orientação anterior: no fluxo Frosty 1.0.6.3, a compilação acontece ao acionar Launch, que executa `FrostyModExecutor.Run` e então ações de plataforma (código da tag 1.0.6.3 consultado).

Importante: `LaunchPlatformPlugin.dll` está presente no diretório de plugins do Editor, mas ausente no diretório de plugins do Manager. Não copiar plugins nem misturar instalações. Captura 151156 já inspecionou Tools → Options: somente Mod Manager Options, sem Launch Options ou caminho para executável customizado. Não pedir essa captura de novo.

## Referência upstream e confirmação do launcher local

Captura `prints/Captura de tela 2026-10-14 151156.png` mostra somente `Mod Manager Options` (sem seção `Launch Options`); não houve mudança/salvamento de configuração. `Custom Mods Directory` está sem valor. A consulta local confirmou que `FIFA 17/steam_appid.txt` não existe e que não há `FIFA 17/ModData` gerado. O plugin `LaunchPlatformPlugin.dll` existe na pasta do Editor, mas não na do Manager. Não copiar plugin entre instalações.

O código upstream Frosty 1.0.6.3 consultado indica que `FrostyModExecutor.Run` cria `ModData/<pack>` e no final chama o launcher; sem `steam_appid.txt`, `LaunchGame` inicia `<basePath>FIFA17.exe` com `-dataPath`, não `stp-fifa17.exe` ([código de lançamento](https://github.com/CadeEvs/FrostyToolsuite/blob/1.0.6.3/FrostyModSupport/FrostyModExecutor.cs#L1617-L1648)). Isso é referência de versão, não prova absoluta para os binários locais do fork, que não estão vinculados a commit. O usuário esclareceu que, no setup dele, Launch aciona o `stp-fifa17.exe` e o STP reconhece a chamada; tratar como relato específico do ambiente e confirmar na próxima execução.

Tentativa somente de consulta `FrostyCmd.exe --help` não mostrou ajuda: entrou em `ProfileCreator.CreateProfiles` e falhou com `DirectoryNotFoundException` para `Profiles.bin`. Portanto não há CLI de build confirmada; não repetir comandos CLI presumidos. O teste integrado Launch já foi executado; próxima etapa: analisar serialização Legacy sem aplicar novos pacotes ao jogo até haver hipótese corrigível. Não copiar plugin.

## Atualização do Manager — abertura e perfil concluídos

Usuário confirmou funcionamento; captura 142413 examinada, janela principal `Frosty Mod Manager - 1.0.6.3 (FIFA 17)`, Pack Default, Available Mods/Applied Mods vazios e Launch disponível. Onze capturas examinadas ao todo. Abertura e perfil FIFA 17 validados; não pedir repetição desse teste nem recomendar troca da versão por diferença de hash sem falha concreta.

Ainda não foi demonstrado Launch com stp-fifa17.exe, importação/aplicação/remoção de mod ou compatibilidade de pacote Editor → Manager. A próxima ação permanece esclarecer importação do membro DAT no BIG LeagueStats e persistência sem mudanças em projeto separado. Os registros históricos abaixo sobre ausência de teste Manager referem-se às inspeções anteriores e estão superados quanto à abertura/perfil, não quanto ao ciclo de mod.

## Último resultado: amostra estrutural recebida

`work/original/leaguestats.APT` (8366 bytes) e `leaguestats.DAT` (12990 bytes) já foram recebidos e analisados. Captura 142004 mostra LeagueStats Type BIG no Legacy, DAT índice 0 e APT índice 1, Export/Import. Os quatro itens sob Stats são recursos BIG, não pastas conforme hipótese inicial. Dez capturas examinadas. Não repetir o pedido de exportar APT/DAT ou abrir o Editor/projeto vazio.

Hashes e inventário em environment.md; mapa de componentes, offsets verificados e fontes em documentation-review.md. Script `python scripts/inspect-leaguestats.py` executado: leitura parcial restrita a esses hashes, sem escritor. Identificou área lógica 1280 × 720, 28 slots, StatsRowData, componentes importados, quatro campos de linha e seus cabeçalhos posicionados. Cabeçalho txtHeadPlayerName tem tx=266, ty=200 no DAT; ainda não testado no jogo. A associação com Player Stats está fortemente sustentada, mas a prova estrutural no jogo não foi realizada.

F17-03 tem candidato concreto e geometria preliminar lida. F17-04 (ida e volta) e F17-05 (mudança única) ainda não iniciados. Nenhum original, save ou instalação modificado pelo agente. Próximo trabalho independente: confrontar o leitor e a reconstrução/importação BIG do plugin da revisão local; não instalar conversor/IDE ou tentar SWF por suposição.

## Histórico anterior à exportação — superado pelo último resultado acima

Baseline: inglês, 1280 × 720 windowed, iniciado por stp-fifa17.exe. Dimensões e FULLSCREEN=0 conferidos no arquivo ativo `%USERPROFILE%\Documents\FIFA 17\fifasetup.ini`. Saves localizados em `%USERPROFILE%\Documents\FIFA 17\settings`; conteúdo preservado, perfil separado/backup ainda não confirmados. Não pedir novamente resolução, idioma ou caminho dos saves.

Data Explorer/UI: usuário encontrou somente Localization. No Legacy, identificou `data/ui/game/screens/career/Stats` com fixtures, leaguestats, leaguetables e teamstats. Captura 141719 confirma screens/career/Stats e outras seções da carreira; não mostra as quatro entradas expandidas. A pasta career reúne várias telas, mas abrangência de toda a UI é hipótese. Captura 140816 mostra o seletor do Manager aberto; reconhecimento da instalação e aplicação não validados. Nove capturas examinadas.

F17-03 agora tem candidatos temáticos reais no Legacy, ainda sem arquivo/tipo ou propriedade estrutural conhecidos. Não é preciso repetir busca genérica de stats nem abertura/projeto vazio do Editor. Próxima ação é a amostra específica abaixo; demais seções históricas preservam o que já foi feito.

**Estado: pronto para investigar recursos no Editor; fluxo completo parcialmente preparado.** F17-01 tem inventário e baseline visual vazio/populado documentados; validação interativa pendente. F17-02 parcialmente concluído: instalação carregada no Editor e projeto vazio salvo/reaberto pelo usuário; Manager/exportação/aplicação ainda pendentes. F17-03 tem tela definida e catálogo principal acessível, sem recurso estrutural. F17-04 e F17-05 não iniciados.

**Teste vazio concluído, não repetir:** `frosty_projects/vazio.fbproject`, 111 bytes, SHA-256 `3334bb3f7933c4a4338f9da202db371bd9079a516d640938c252cd3df56974be`. Usuário confirmou salvar/reabrir sem problemas. Capturas `140522.png` e `140605.png` examinadas; a segunda mostra Editor 1.0.6.3 (FIFA 17), Data Explorer populado, aba Legacy Explorer e log Initialization complete. O título na imagem ainda é New Project.fbproject; relato de reabertura e arquivo salvo completam a evidência. Sete imagens examinadas ao todo. O agente não operou a interface gráfica nem salvou o projeto.

## Próximo experimento recomendado: ida e volta sem alteração

Procedimento futuro, ainda não executado nesta auditoria. Não aplicar mods nem escrever no jogo automaticamente. Antes de importar, esclarecer se o botão Import atua no membro selecionado ou no contêiner; a imagem confirma sua existência, não sua semântica. A implementação do plugin remoto não pôde ser obtida. Se o próprio visualizador não deixar isso claro, examinar o código correspondente antes de tentar.

1. Preservar vazio.fbproject e os dois arquivos em work/original; usar um projeto de experimento separado. Confirmada a operação de membro, reimportar somente o DAT original no slot DAT 0 do LeagueStats, mantendo APT 1 intacto. Não renomear os membros por convenções de ferramentas externas: seus cabeçalhos e rótulos diferem.
2. Salvar/fechar/reabrir esse projeto e reexportar o DAT e APT para pasta distinta de work/original. Comparar hashes e estrutura; explicar qualquer diferença antes de gerar mod. Se o projeto não registrar alteração por os bytes serem iguais, documentar o no-op; isso não comprova o caminho de persistência de alteração e não justifica forçar bytes aleatórios.
3. Em fase de teste no jogo, após resolver Manager/launcher e restauração, verificar a mesma tabela com um pacote de ida e volta, se houver mudança efetivamente registrada. Confirmar dados/navegação e reversão. Exportar mod sem erro não basta.

Sucesso do teste local: recurso reaparece íntegro, conteúdo conhecido é preservado e o ciclo de armazenamento é explicado. Sucesso no jogo: tabela funciona com dados e navegação, com aplicação/remoção reproduzíveis.

Depois disso, o menor teste estrutural proposto é mover somente txtHeadPlayerName de tx=266 para tx=278 (12 unidades lógicas), mantendo ty=200 e os demais bytes/campos. É proposta, não arquivo produzido ou offset autorizado para patch. Antes de escrever, validar o campo pelo nome/referência, o hash exato e a rota de importação. Esperado: apenas cabeçalho Name desloca, dados continuam dinâmicos, reinício preserva e remoção restaura. Não alterar globais, RowControl compartilhado ou constantes nesse primeiro teste.

**Captura populada já recebida:** `prints/Captura de tela 2026-10-14 140230.png`, examinada, com oito linhas de Top Scorers da NA Allstars Trophy. Primeira linha Gashi / Colorado Rapids / 2 gols; demais sete com 1 gol. Não solicitar outra captura para cumprir essa pendência. Cinco imagens examinadas no total. O par vazio/populado serve como referência visual; atualização dinâmica e interação continuam sem teste observado.

Atualização: Editor extraído pelo usuário em `FrostyToolsuite-FIFA17editionv3fixed\FrostyToolsuite-FIFA17editionv3fixed\FrostyEditor.exe`, com EXE/SDK/perfil iguais aos hashes do ZIP histórico. Manager indicado em `FrostyModManager\FrostyModManager\FrostyModManager.exe`; mantém hash anterior, distinto do Manager.zip histórico. O par atual é o indicado pelo usuário; compatibilidade ainda não testada. ZIPs não localizados na nova consulta. Não é necessário extrair o Editor novamente.

Launcher para iniciar o jogo: `FIFA 17\stp-fifa17.exe`, confirmado pelo usuário. Tela: `Home → Load Career → Choose save → Central → Season → Player Stats`. Quatro capturas em `prints` foram examinadas; menus em inglês, estado final `Top Scorers` da `NA Allstars Trophy`, cabeçalhos Rank/Name/Team/Goals, mensagem `No Statistics Available`. A primeira imagem está na aba PLAY; a carga do save foi descrita pelo usuário. As imagens comprovam acesso visual à tela, sem demonstrar linhas/dados dinâmicos ou navegação em lista.

Foram criados `docs/environment.md`, `docs/readiness-audit.md`, `docs/documentation-review.md`, este arquivo e `scripts/audit-local.py`. Script executado com sucesso. Nenhum mod foi gerado ou aplicado; nenhum programa gráfico de modding foi iniciado; nenhum save, binário original ou cache foi alterado. Não existe repositório Git reconhecido. Não repetir a pesquisa geral: versões, caminhos e hashes já estão em `environment.md`.

## Pendências a responder em conjunto

1. Quando necessário ao teste estrutural, observar seleção/rolagem/retorno com teclado/mouse e gamepad. Entrada, resolução, idioma e baseline sem mods já confirmados.
2. Confirmar existência de perfil separado/backup antes de testes que afetem o jogo; localização dos saves, launcher, tela e percurso já recebidos. Não perguntar novamente se as capturas estavam sem mods.
3. Registrar a URL de origem das ferramentas, se disponível, como rastreabilidade. Não é necessário baixar novamente para o teste básico do par indicado. Se houver logs ou projetos anteriores em outro diretório, indicar somente esses caminhos relevantes.

Não é preciso fornecer a instalação inteira, saves pessoais ou credenciais. Nenhuma nova instalação de runtime foi demonstrada necessária. Se a origem dos pacotes não puder ser recuperada, a fonte para obter um par rastreável é a [release do próprio fork](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/2.0.1). Não reutilizar DLLs do Manager extraído para completar outro pacote.

## Procedimento anterior preservado: baseline e persistência de projeto vazio

Launcher, tela, configuração ativa e baseline visual populado já identificados. O procedimento B abaixo foi concluído pelo usuário para o ciclo de projeto vazio e permanece como referência histórica; não solicitar sua repetição. O Legacy já foi explorado até a pasta Stats; falta inspecionar recursos internos. Complementar A apenas quanto à navegação e condições sem mods. Proveniência pública permanece pendência de registro, sem bloquear pesquisa de recursos.

### A. Baseline do jogo

1. Iniciar por `<raiz>\FIFA 17\stp-fifa17.exe`, conforme informado, sem acrescentar mod. Registrar se já há mods ativos, sem removê-los automaticamente.
2. Chegar à tabela escolhida no contexto offline de teste. Não sobrescrever progresso pessoal; se depender de criar perfil/save de teste, fazê-lo separadamente antes dos experimentos futuros.
3. Reutilizar o percurso e as cinco capturas em `prints`, incluindo o baseline populado `140230.png`; não recapturar os menus nem solicitar outra tabela com dados. Manter também a imagem original de estado vazio `135842.png`. Avaliar seleção/rolagem separadamente quando o comportamento da tela permitir.
4. Baseline ativo já registrado: inglês, 1280 × 720 windowed. Informar controle/teclado e observar navegação, rolagem e retorno conforme o comportamento real da tela; não solicitar novamente captura de configuração já corroborada por arquivo.
5. Se falhar, devolver texto completo do erro, executável utilizado e log/captura correspondente. Remover dados de conta antes de compartilhar. Não confirmar funcionalidade apenas porque abriu a janela do launcher.

Critério de sucesso A: mesmo caminho chega à mesma tabela, com dados reais e navegação funcional observada. Este teste resolve baseline, não viabilidade de mod.

### B. Abrir e persistir no Editor — concluído para projeto vazio

1. Iniciar `<raiz>\FrostyToolsuite-FIFA17editionv3fixed\FrostyToolsuite-FIFA17editionv3fixed\FrostyEditor.exe`. Caminho e hash já registrados; capturar versão mostrada e erro, caso exista. Não iniciar o Manager nem aplicar mod neste teste.
2. No seletor do Editor, identificar a instalação por `<raiz>\FIFA 17\FIFA17.exe`. Isso não muda a instrução de iniciar o jogo pelo launcher `stp-fifa17.exe`: são operações distintas. Se o Editor não reconhecer a instalação, registrar erro integral e a tela do seletor; não renomear executáveis nem trocar o alvo por tentativa. A preparação inicial pode gerar cache da ferramenta; registrar local e tamanho e preservar o conteúdo preexistente.
3. Aguardar o catálogo carregar; capturar a janela com `Data Explorer`, `Legacy Explorer` e área de mensagens. Esses rótulos foram encontrados no binário, mas a disposição real ainda não foi observada. Se uma aba não existir/carregar, capturar esse estado, sem presumir outro menu.
4. Usar `Ctrl+N` (New Project) apenas se necessário e `Ctrl+S` (Save Project), sem modificar recursos. Caminho efetivamente usado: `<raiz>\frosty_projects\vazio.fbproject`. Preservar esse arquivo; não impor o caminho sugerido anteriormente.
5. Fechar o Editor, reabrir o mesmo executável/jogo e usar `Ctrl+O` (Open Project) para abrir o arquivo salvo. Capturar ausência de erro e disponibilidade dos catálogos. Um projeto vazio confirma o ciclo básico, não a persistência de recursos editados.
6. Devolver captura do catálogo principal e Legacy, arquivo de projeto ou seu caminho/tamanho/hash, e mensagens de erro. Se houver log em disco, informar o caminho real; não há nome/local de log comprovado nesta revisão. A área de mensagens pode ser capturada quando não houver arquivo.

Critério de sucesso B: Editor reconhece a instalação real, lista recursos, salva e reabre o projeto em uma nova execução. Se A ou B falhar, registrar como reprovado com evidência e investigar esse erro específico antes de importações. Não aplicar mod nesta etapa.

## Procedimento histórico de busca da primeira amostra — concluído

Pesquisar nos catálogos principal e Legacy usando primeiro `Player Stats`, `Top Scorers`, `No Statistics Available` e depois termos auxiliares `stats`, `statistics`, `career`, `frontend`, `table`, `ui`. São consultas, não nomes de recursos presumidos. Registrar catálogo, nome completo, tipo, identificador e referências de cada resultado relevante. Mapear candidatos pode prosseguir com o estado vazio; o teste estrutural de linhas exigirá baseline populado.

Exportar no máximo 1–3 candidatos pequenos pelo comando Export exposto para o tipo selecionado, sem importar de volta ainda. Guardar em `work/original/`, mantendo o vínculo identificador → arquivo → hash. Incluir imagem do painel de propriedades e dizer se existem opções Import/Export. Não exportar todo o jogo. Se não houver candidato, retornar a lista de consultas e resultados, sem escolher um arquivo apenas pelo nome.

Critério de sucesso da amostra: um candidato possui evidência de associação à tela, tipo e operação de exportação conhecidos; idealmente expõe geometria. Fontes/texturas sozinhas são evidência de aparência. Se apenas estas aparecerem, manter o layout como não verificado e seguir as referências antes de instalar ferramentas adicionais.

## Experimento estrutural posterior, condicionado às evidências

Não está autorizado para execução automática nesta primeira etapa. Pré-requisitos: baseline A, persistência B, par e launcher testados, backup/restauração definidos, candidato estrutural identificado, gravador/importação conhecido e ciclo de aplicação/remoção validado separadamente.

1. **Ida e volta:** exportar/reimportar o mesmo recurso sem mudança, salvar, reabrir, gerar mod e testar a tela; explicar diferenças de serialização. Se quebrar, investigar leitor/gravador antes de alterar geometria.
2. **Mudança única:** alterar somente um campo de geometria que tenha sido realmente identificado, por exemplo largura de uma coluna ou posição de um cabeçalho. Documentar valor original/novo, unidade e limites reais. Não inventar offset, nome de propriedade ou incremento.
3. **Prova no jogo:** capturas antes/depois no mesmo contexto, reinício, seleção, rolagem, retorno e novo contexto com atualização dos dados. Remover/desativar o teste e confirmar reversão.

Critério de sucesso: geometria nativa mudou conforme o campo identificado, persiste após reinício, valores continuam dinâmicos e corretamente associados, navegação funciona e remoção restaura baseline. Exportar um pacote, trocar textura ou abrir um mockup não atende ao critério.

## O que evitar repetir

- Não presumir que versões PE iguais significam ferramentas iguais: hashes já demonstram a diferença.
- Não confundir caches dentro do ZIP com sessões anteriores desta máquina.
- Não executar receita antiga de VS 2019/branch 1.0.6 sem obter a revisão correspondente.
- Não propor CLI de FrostyCmd sem implementação/ajuda verificada; os símbolos encontrados não demonstram exportação/importação.
- Não declarar ausentes globalmente saves ou ferramentas que só foram procurados em caminhos usuais.
- Não preparar backup completo em C: sem medir o espaço restante e o cache; a cópia do jogo ocuparia ~30,82 GiB dos ~37,75 GiB livres observados.
