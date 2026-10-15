# Inventário do ambiente — 14/10/2026

## Estado atual do teste integrado — regressão confirmada

Com `LeagueStatsRoundtrip` desativado, o mesmo contexto voltou a exibir oito linhas; captura `prints/Captura de tela 2026-10-14 160635.png`. O usuário relata que, com o pacote ativado, as linhas somem. Após a execução sem mod, `FIFA 17/ModData/Default/Update/Patch/Data/mods.json` está em `[]` (16:05:36), então o perfil atualmente gerado não inclui esse pacote. Não houve crash.

Criado e testado `scripts/inspect-fbmod-legacy.ps1`, inspeção somente leitura que usa as assemblies já instaladas. O pacote contém um chunk `LeagueStats.big` com 5474 bytes comprimidos e 21422 bytes expandidos via ZSTD para um BIGF. Os membros exportados estão byte a byte preservados dentro dele (DAT offset 64; APT offset 13056). O registro Collector de 102 bytes tem o hash correto do caminho e referencia esse mesmo chunk. O container/tabela BIG ainda não foi validado contra um BIG vanilla; detalhes em `docs/documentation-review.md`.

## Atualização: ida e volta local preservou os dois membros

Usuário concluiu importar DAT original, salvar/fechar/reabrir projeto e reexportar membros. Comparação direta de bytes: `work/roundtrip/leaguestats.DAT` tem 12990 bytes e SHA-256 `a35474d5834ac3be04a2a25622da52123d0f20536af1f0972a5d0114128dc58b`; `work/roundtrip/leaguestats.APT` tem 8366 bytes e SHA-256 `a2feb529aaca898259dfd1664e5602c7d4371f24cd1a383f1bf51f50faea121a`. Ambos iguais aos originais, zero diferenças; os originais permanecem intactos.

`frosty_projects/ida-volta-leaguestats.fbproject` agora tem 5953 bytes, SHA-256 `1fa5ca58dc861c99c34e12942b6dc180c97f939c7bb06f3c73b63620705cbd89` (antes, 111 bytes). Contém strings `data/ui/game/screens/career/Stats/LeagueStats.big` e `legacy;data/ui/game/screens/career/Stats/LeagueStats.big`. O caminho completo com extensão BIG agora está observado localmente, não apenas inferido. O conteúdo comprimido/registro do projeto não foi decodificado; crescimento e strings sustentam armazenamento associado ao recurso, sem comprovar conteúdo de pacote exportado. vazio.fbproject continua com 111 bytes e hash inalterado.

Captura `prints/Captura de tela 2026-10-14 144757.png`: 158897 bytes, 1909 × 1029, SHA-256 `728f4e1e7ff457db1212f48de225b667536a45cca9729e9b95b4276826459e66`. Editor carregado e log de Legacy BIG Editor registra exportações DAT/APT para work/roundtrip às 14:47:33 e 14:47:39. O título permanece New Project.fbproject; a reabertura é confirmada pelo relato do usuário e arquivos locais, não pelo título da captura. Treze imagens examinadas. Ida e volta local validada; teste no jogo e persistência de geometria alterada pendentes.

## Atualização: importação DAT identificada no diálogo

Examinada `prints/Captura de tela 2026-10-14 144208.png`, 48523 bytes, 936 × 526, SHA-256 `d6d5ed162009e81523729f58853c8d88277b77ba2111fb3cd869aa573496e693`. Diálogo Import File com filtro `DAT (*.DAT)`, aberto pelo usuário após selecionar DAT 0 no LeagueStats. Isso confirma entrada destinada ao membro DAT; a gravação/reconstrução e a persistência ainda não foram testadas. Doze capturas examinadas.

Projeto de laboratório presente: `frosty_projects/ida-volta-leaguestats.fbproject`, 111 bytes, SHA-256 antes da importação `7f3a4bed07f2bf04da22d094f7a370d885c4847e5bb94256c0062c60566c31c0`. `vazio.fbproject` mantém 111 bytes e hash `3334bb3f7933c4a4338f9da202db371bd9079a516d640938c252cd3df56974be`; ambos preservados pelo agente. Hashes diferentes dos projetos não comprovam mudança de recurso, pois metadados também variam.

## Atualização: entrada e condições do baseline

Usuário confirmou teclado e mouse como dispositivos usados nos registros; gamepad é seu dispositivo habitual para jogar. Todas as capturas/registros foram feitos, segundo o usuário, em versão do jogo sem modificações. Baseline passa a ser explicitamente sem mods, com evidência declarada pelo usuário e capturas já examinadas; isso não equivale a comparação integral dos arquivos com uma distribuição oficial. Navegação precisa ser validada nos dois modos de entrada no futuro, sobretudo no gamepad habitual. Modelo do controle ainda não informado e não bloqueia a análise de arquivos.

## Atualização: Manager carregado com perfil FIFA 17

Examinada `prints/Captura de tela 2026-10-14 142413.png`: 23955 bytes, 1049 × 746, SHA-256 `9ff09f60e9930782a99e0607a18ea6553e9fc967ae0d9f637808c065f52bb708`. Onze capturas examinadas. Título visível: `Frosty Mod Manager - 1.0.6.3 (FIFA 17)`. Janela principal disponível, Pack Default, botão Launch e áreas Available Mods/Applied Mods vazias. O usuário informa funcionamento normal.

Abertura básica e carregamento do perfil FIFA 17 no Manager estão validados por teste manual/captura. O caminho do executável do jogo associado não aparece nessa imagem; não inferir que o launcher stp-fifa17 já esteja integrado. Não há evidência de importar/aplicar/remover mod ou iniciar o jogo pelo Manager. Diferenças de hash entre distribuições permanecem inventariadas, sem erro de compatibilidade reproduzido. Não é necessário substituir o Manager ou repetir teste de abertura apenas por essas diferenças.

## Atualização: primeira amostra LeagueStats exportada e analisada

Captura `prints/Captura de tela 2026-10-14 142004.png`: 71065 bytes, 1889 × 1030, SHA-256 `d238dbe4cefc657f7577422682fa08ba7dc0ee0126f1603683746d469bec04e6`. Dez capturas examinadas. A imagem mostra LeagueStats selecionado no Legacy, Type BIG; Fixtures, LeagueTables e TeamStats também aparecem como BIG. Portanto, as entradas antes tratadas provisoriamente como pastas são recursos BIG. O painel do recurso LeagueStats contém DAT índice 0 (12990 bytes) e APT índice 1 (8366 bytes), além de Export/Import. A operação de importação não foi testada.

| Original local preservado | Bytes | SHA-256 | Cabeçalho real |
| --- | ---: | --- | --- |
| `work/original/leaguestats.APT` | 8366 | `a2feb529aaca898259dfd1664e5602c7d4371f24cd1a383f1bf51f50faea121a` | ASCII Apt1 |
| `work/original/leaguestats.DAT` | 12990 | `a35474d5834ac3be04a2a25622da52123d0f20536af1f0972a5d0114128dc58b` | ASCII Apt Data:1:7:8, seguido de 0x1a e NUL |

Origem informada e painel: `data/ui/game/screens/career/Stats/LeagueStats`, tipo BIG, membros internos acima. Não há arquivo do contêiner BIG completo em work/original nem GUID exposto na imagem; não inventar identificador/extensão do contêiner exportado. Exportação dos dois membros comprovada por arquivos e tamanhos coincidentes com o painel.

Criado e executado `python scripts/inspect-leaguestats.py`: leitor parcial, somente leitura, restrito aos hashes desta amostra, sem gravador nem execução de bytecode. Resultado: raiz no DAT em 1448, área lógica 1280 × 720, um frame da raiz, 28 slots de personagens, oito imports, seis exports, 11 definições de texto e 23 instâncias nomeadas. APT contém metadados de 253 constantes, tabela em 48. Interpretação baseada em fonte primária de um leitor externo, conferida contra limites, marcadores e nomes locais; não certifica toda a semântica da variante FIFA nem compatibilidade de escrita.

Teste do leitor rejeitou em memória cabeçalho inválido, DAT truncado e tabela de constantes truncada. Hashes dos dois originais conferidos novamente e inalterados após análise. Offsets publicados na revisão são posições verificadas de campos lidos, específicas desses hashes, não autorização ou instrução de patch. Nenhuma instalação, importação, mod ou alteração no jogo/saves realizada.

## Atualização: configuração ativa, saves e árvore Legacy

Idioma inglês e execução windowed a 1280 × 720 informados pelo usuário. Conferência de leitura em `%USERPROFILE%\Documents\FIFA 17\fifasetup.ini`: `RESOLUTIONWIDTH = 1280`, `RESOLUTIONHEIGHT = 720`, `FULLSCREEN = 0`. A configuração persistida corrobora o relato; 1920 × 1080 permanece somente o default histórico da distribuição. Baseline principal passa a 1280 × 720 windowed; segunda resolução não definida.

`%USERPROFILE%\Documents\FIFA 17` agora existe e foi acessada. Contém `settings`, `fifasetup.ini`, `dumps`, `filesystemcache`, `Screenshots` e `Temp`. Em settings: quatro arquivos, total 15288311 bytes; dois têm nome contendo Career. Não foi lido conteúdo de saves nem registrados seus nomes pessoais. Nenhum arquivo com Profile no nome foi retornado; isso não comprova ausência de perfil, pois o critério é apenas nominal. Perfil separado de teste/backup continuam não confirmados. As constatações iniciais de pasta não localizada abaixo são históricas e foram superadas.

Usuário explorou Data Explorer/UI e encontrou somente Localization; no Legacy informou `data/ui/game/screens/career/Stats`, com entradas fixtures, leaguestats, leaguetables e teamstats. A captura `prints/Captura de tela 2026-10-14 141719.png` confirma o trecho screens/career/Stats; os ancestrais data/ui/game e as quatro entradas são informação do usuário, não visíveis nesse recorte. Nenhuma exportação ou extensão desses candidatos foi obtida.

Novas imagens examinadas (nove ao todo):

| Arquivo em prints | Bytes / dimensões | SHA-256 | Evidência |
| --- | --- | --- | --- |
| `Captura de tela 2026-10-14 140816.png` | 9519 / 1000 × 600 | `0122805c748c25dba846c440a55b0d5fabe9f9afe0eae66422c91a263a63bf5f` | Seletor inicial do Frosty Mod Manager aberto, lista sem entradas naquele instante; não comprova instalação reconhecida/aplicação |
| `Captura de tela 2026-10-14 141719.png` | 10652 / 302 × 355 | `efc759848f7fca92bcbc72ff72a1b1d9b122a6231a6e89c58006b4bf6266a87a` | Árvore screens/career e pasta Stats selecionada |

Nenhum conteúdo de save foi alterado. Esta atualização leu configuração e metadados; não abriu programas nem aplicou mods.

## Atualização: Editor carregado e projeto vazio reaberto

Teste manual realizado pelo usuário: Editor abriu FIFA 17, salvou e reabriu projeto vazio sem problemas. Evidência local: `frosty_projects/vazio.fbproject`, 111 bytes, SHA-256 `3334bb3f7933c4a4338f9da202db371bd9079a516d640938c252cd3df56974be`. Prefixo contém assinatura ASCII `FROSTY` e identificador `FIFA17`; o arquivo não foi modificado nem interpretado como prova de persistência de recursos alterados.

Novas capturas examinadas:

| Arquivo em prints | Bytes | Dimensões | SHA-256 | Evidência |
| --- | ---: | --- | --- | --- |
| `Captura de tela 2026-10-14 140522.png` | 8960 | 997 × 599 | `8d2ab614434701374c734f0d616da0d768f468aaf7a562be408cbdf7ad3d2e90` | Seletor inicial sem entradas naquele instante; não é falha de reconhecimento reproduzida |
| `Captura de tela 2026-10-14 140605.png` | 185353 | 1914 × 1031 | `c7517a5c3f3655a569f7a6f8e1f6c30381614382a14020481a9ee3254af5f5bc` | Editor 1.0.6.3 (FIFA 17), Data Explorer populado; aba Legacy Explorer disponível |

Log visível na segunda imagem: `Frosty Editor v1.0.6.3`, `Loading Profile For FIFA 17`, `Initialization complete`. O título nessa captura ainda mostra `[New Project.fbproject]`; a reabertura de `vazio.fbproject` é confirmada pelo relato do teste manual, acompanhado do arquivo salvo, não por uma captura específica de seu título. Não é necessário repetir o teste vazio por esse motivo.

Pastas visíveis no Data Explorer incluem `Content`, `Fifa`, `Fonts`, `Globals`, `Systems` e `UI`. A página mostra 46 plugins e vários com marca de confirmação, mas também alguns com `!`; não interpretar esses ícones como erro fatal ou incompatibilidade sem detalhes. Conteúdo do Legacy Explorer e suporte de cada plugin à amostra ainda não observados. Nenhum log em arquivo foi localizado na busca desta atualização; o log visual acima é a evidência disponível.

Sete capturas examinadas ao todo. Abertura básica, perfil e ciclo de projeto vazio estão validados por teste manual; aplicação pelo Manager, exportação de mod e persistência de alterações seguem não verificadas. O agente apenas leu arquivos e atualizou documentação; o uso gráfico e o salvamento foram feitos pelo usuário.

## Atualização após extração e entrega das capturas

Atualização subsequente: examinada também `prints/Captura de tela 2026-10-14 140230.png` (808012 bytes, 1280 × 717 pixels, SHA-256 `38f9e9d82e6e70f06e1198068fe56b3a2f231a5f25520e3258f65fb485e95d5c`). É a mesma tela Player Stats / NA Allstars Trophy / Top Scorers, agora com oito linhas: Gashi com 2 gols e outros sete jogadores com 1 gol. A captura confirma apresentação de dados e associações visuais entre jogador, equipe e gols; não prova por si só atualização dinâmica, foco, seleção ou rolagem. São cinco imagens examinadas ao todo. Os registros de quatro imagens/estado vazio abaixo descrevem a entrega anterior; a pendência de captura populada está resolvida.

Este bloco registra o estado atual; o inventário inicial abaixo permanece como histórico da primeira inspeção. O usuário extraiu o Editor e informou que o par disponível é o correto para o projeto. Os ZIPs anteriores não foram encontrados na nova consulta da árvore Frosty; seus hashes abaixo são registros históricos, não arquivos cuja presença atual foi confirmada.

- Editor disponível em `<raiz>\FrostyToolsuite-FIFA17editionv3fixed\FrostyToolsuite-FIFA17editionv3fixed\FrostyEditor.exe`, FileVersion 1.0.6.3, 1098752 bytes. SHA-256 `39d8321de58c4f6b75648262843014b33d486643053b7cad4ad29838d3820ed3`: igual ao membro do Editor.zip auditado antes. FrostySdk.dll e Profiles/Fifa17SDK.dll também coincidem com os hashes anteriormente registrados para esse ZIP. Não foi possível comparar integralmente a extração, pois o ZIP já não está disponível nessa árvore.
- Manager indicado disponível em `<raiz>\FrostyModManager\FrostyModManager\FrostyModManager.exe`, FileVersion 1.0.6.3. Seu hash permanece `87e198ecd0dce9b18fd12b1c496b7ec5ace667ee0d339103b7f476b524dd6dd2`, e o SDK permanece `66b9c3d3d51e6133bcd69706ab4c2eb89756c3b4c97a175fdfca9b26066c3008`. Portanto, continua diferente do Manager.zip inicialmente auditado. O par indicado pelo usuário será a base do teste; a diferença não comprova incompatibilidade e não será corrigida por mistura de DLLs.
- Launcher de execução confirmado pelo usuário: `<raiz>\FIFA 17\stp-fifa17.exe`, 1969152 bytes, sem versão PE útil, SHA-256 `5724a6be30e3c2e457e70033fb3ad68fa6d938701ccf65fbc8f3d92eb48e5754`. `FIFA17.exe` permanece a referência de identificação da instalação; não confundir a seleção da instalação no Editor com a forma de iniciar o jogo.
- Caminho informado: `Home → Load Career → Choose save → Central → Season → Player Stats`. A primeira captura mostra a aba PLAY ativa; Home/Load Career/Choose save não estão documentados visualmente nessa imagem. A parte Central → Season → Player Stats está corroborada pelas demais capturas.
- Quatro imagens em `prints` foram abertas e examinadas; há evidência visual de acesso à carreira e à tela pretendida. A tela final está em inglês e vazia, com `No Statistics Available`. Não comprova estatísticas dinâmicas, seleção ou rolagem; não certifica ausência de mods na sessão capturada.
- Dimensões dos PNGs variam entre 1276–1282 × 714–720 pixels; podem ter sido recortados. A resolução de renderização e o modo de exibição continuam não verificados. Dicas de teclado visíveis não comprovam os dispositivos efetivamente usados nem teste com controle.
- Nenhum aplicativo gráfico foi iniciado pelo agente nesta atualização; nenhuma alteração no jogo ou saves. `scripts/audit-local.py` passou a inventariar também Editor extraído e launcher.

| Evidência em prints | Dimensões | SHA-256 | Observação |
| --- | --- | --- | --- |
| `Captura de tela 2026-10-14 135745.png` | 1276 × 720 | `bd98b49393d4ecdee11053ea50afe53ab4ab1d1bb84720b6a8d9a423a2ec38ca` | Menu principal, aba PLAY |
| `Captura de tela 2026-10-14 135827.png` | 1278 × 714 | `54427adc8024302126cd1f3e9eee8d1eb4d30378d6ab8aa4785936ab0b37f74e` | Carreira, CENTRAL |
| `Captura de tela 2026-10-14 135834.png` | 1282 × 717 | `6ee64558a2ae5da132ce1e9e614c00668599354bc74e67e4d66f62b21a856ecd` | SEASON com opção PLAYER STATS |
| `Captura de tela 2026-10-14 135842.png` | 1277 × 719 | `4b0373189c4d37fd50b7bfd2fd7c2198377daa681b501e814b593f8770e8fb29` | Player Stats; estado vazio |

## Inventário inicial preservado

Auditoria de leitura. Raiz: `<workspace>` (referida abaixo como `<raiz>`). Não foram iniciados jogo, launchers, Editor ou Manager; não foram extraídos pacotes, instaladas dependências, alterados saves, caches ou configurações. Foram criados somente estes documentos e `scripts/audit-local.py`.

## Projeto e preservação

- Lidos os dois planejamentos: `Planejamento_Mod_Interface_FIFA_17.md` é a referência atual; `Planejamento_Mod_Interface_FIFA_16_17.md` é a referência anterior de comparação entre jogos. Nenhum contém resultado de teste local comprovado.
- Não encontrado `AGENTS.md` na árvore do workspace nem nos ancestrais até `C:\`. Não há README do projeto; existe `FIFA 17\_README.txt`, referente à distribuição do jogo, e documentação de bibliotecas dos utilitários.
- Pastas preexistentes: `.obsidian`, `FIFA 17`, `FrostyModManager`, `FrostyToolsuite-FIFA17editionv3fixed`, `imhex`, `winmerge`. Preservadas integralmente.
- `git status --short` e `git -C .. rev-parse --show-toplevel` retornam “not a git repository”. Não há `.git` no workspace. Existe diretório `.git` no pai, sem itens retornados na inspeção; não é um repositório reconhecido. Nenhuma revisão ou diff preexistente pode ser afirmado. Não executar `git init` ou adicionar a árvore inteira durante esta auditoria.
- Não encontrados fontes Frosty (`.cs`, `.csproj`, `.sln`), projetos `.fbproject`, mods `.fbmod`, scripts próprios anteriores, capturas da tela ou logs nas áreas do projeto/ferramentas inspecionadas. O ZIP do Editor contém caches e diretório `Mods/FIFA17` vazio; caches distribuídos não comprovam uso local. Não existe `FIFA 17\ModData`, nem `Mods`/`Caches` no Manager extraído.

## Sistema e execução

| Item | Evidência observada | Limite |
| --- | --- | --- |
| Ambiente | PowerShell 7.6.6 Core; `Platform=Win32NT`; Windows NT 10.0.26200 | Execução nativa Windows, sem WSL intermediando esta sessão |
| Windows | Registro: build 26200, UBR 9550, DisplayVersion 25H2; ProductName informa Windows 10 Pro | Nome comercial do registro pode ser legado; consulta CIM negada; não deduzir edição comercial pelo kernel |
| Leitura/escrita | Leitura do jogo e ZIPs; execução de Python; escrita dos documentos/script na raiz autorizada | Sem teste de escrita na instalação ou nos saves |
| Execução `.exe` | Git, Python, 7-Zip e dotnet executados por este shell | Não comprova GPU, janela interativa, jogo ou Frosty funcionando |
| Espaço C: | 40.533.393.408 bytes livres (~37,75 GiB) no inventário | Valor varia; demais unidades retornaram livre/usado nulos, não utilizáveis como capacidade confirmada |
| Jogo | 263 arquivos; 33.090.395.210 bytes (~30,82 GiB) | Uma cópia completa deixaria ~6,93 GiB antes dos caches; preferir orçamento medido e backups dirigidos |

## Jogo

Único executável encontrado no escopo dirigido: `<raiz>\FIFA 17\FIFA17.exe`.

| Campo | Valor |
| --- | --- |
| Tamanho | 224.639.408 bytes |
| FileVersion | `1,0,0,0` |
| ProductVersion | `17.0.3175939.0` |
| SHA-256 | `29c31cef12b0c3c2a7305220617c7b4fa139ab76b8c857851bdbe88987962899` |
| BuildSettings | `FIFA 17\Info_Win64_retail.BuildSettings`: changelist 3175939, Frostbite changelist 2490089, release 2015.4, build 2017-06-09 |
| Patch | Existe `Update\Patch`, com `package.mft` indicando `Name patch` e `Authoritative`; catálogos e CAS presentes |

Versão declarada e hash identificam esta amostra, mas não certificam integridade contra uma distribuição oficial nem determinam sozinhos o número comercial do patch. Não foi feita verificação de todos os CAS.

`_README.txt` indica iniciar por `stp-fifa17.exe` ou `FIFASetup\fifaconfig.exe`. Também existem `stp-selector.exe`, `stp-origin_emu.dll`, `stp-origin_emu.ini`, `dbdata.dll` e `dbdataEA.dll`. Isso evidencia componentes de launcher/emulação alternativos; o procedimento realmente usado e a compatibilidade com lançamento pelo Manager permanecem não verificados. A recomendação do README de alterar exceções de antivírus não foi executada nem adotada.

`FIFASetup\config.ini` declara `LAUNCH_EXE = fifa17.exe` e `SETTING_FOLDER = 'FIFA 17'`. `fifasetup_default.ini` informa 1920 × 1080, aspecto 1.778, qualidade 5 e VSync 1. É o padrão de distribuição, não configuração ativa comprovada. Há recurso de tradução `FIFASetup\pt-BR\fifaconfig.resources.dll`, que comprova somente suporte de localização do configurador.

Registro `User Shell Folders\Personal` aponta para `%USERPROFILE%\Documents`. Não existem pastas FIFA 17 nesse local nem em `OneDrive\Documents` ou `OneDrive\Documentos`. Saves/perfil de teste: não localizados nesses caminhos; não se afirma ausência global. Não foram lidos nomes pessoais ou conteúdos de saves. Não encontrados launchers EA/Origin nos caminhos padrão consultados, nem instalação em `Program Files\EA Games`, `Program Files (x86)\Origin Games` ou `Program Files (x86)\Steam\steamapps\common\FIFA 17`. Não houve varredura de discos. Nenhum processo FIFA17/FrostyEditor/FrostyModManager/Origin/EADesktop foi retornado no instante da consulta.

## Frosty local

Pacotes: `<raiz>\FrostyToolsuite-FIFA17editionv3fixed\FrostyToolsuite-FIFA17editionv3fixed\`. O nome `v3fixed` não certifica uma release pública. Ambos ZIPs passaram `ZipFile.testzip()` (CRC de todos os membros), sem extração. Não possuem stream `Zone.Identifier` consultável; não há proveniência de download documentada.

| Arquivo | Bytes | SHA-256 |
| --- | ---: | --- |
| `Editor.zip` | 108695412 | `40553438b982a91310c47f27320e2f63b149c8cfd4adfe92e2a30fa0681dcfdf` |
| `ModManager.zip` | 56065689 | `7137c37ecf352cd57ae107eb5083bd7189c0d58a0aacfaefef67424b611197b1` |
| Editor ZIP: `Final/FrostyEditor.exe` | 1098752 | `39d8321de58c4f6b75648262843014b33d486643053b7cad4ad29838d3820ed3` |
| Manager ZIP: `Final/FrostyModManager.exe` | — | `ccb44de0c51dda10ee73a6965545b617c1b19fbdf7fe8498e92a618becec855b` |
| Manager extraído: `FrostyModManager/FrostyModManager/FrostyModManager.exe` | 537088 | `87e198ecd0dce9b18fd12b1c496b7ec5ace667ee0d339103b7f476b524dd6dd2` |
| Ambos ZIPs: `Final/FrostySdk.dll` | — | `13e67b472020ab0d88f00e74128254c1953e5b10761445ee330e413210c7e168` |
| Manager extraído: `FrostySdk.dll` | 2874880 | `66b9c3d3d51e6133bcd69706ab4c2eb89756c3b4c97a175fdfca9b26066c3008` |
| Três distribuições: `Profiles/Fifa17SDK.dll` | 3837440 | `c6a8e064507e9675bd8b1a0e30de4c99cf0da4e5beb4d9b8a7e9646bcd29db2f` |

Editor ZIP, Manager ZIP e Manager extraído declaram versão 1.0.6.3. Nos ZIPs, a leitura foi estática das strings do recurso PE, sem carregar assemblies. A versão comum não distingue as edições modificadas. O SDK comum dos ZIPs torna esse par candidato mais coerente que misturar o Editor com o Manager extraído; isso não demonstra compatibilidade do protocolo nem de execução.

Editor ZIP: 197 entradas, 333.174.918 bytes descompactados. Manager ZIP: 58 entradas, 172.366.668 bytes. A extração conjunta exigiria ~482 MiB, antes de novos caches. Ambos contêm `Final/` na raiz interna.

Plugins relevantes presentes no ZIP do Editor: `Plugins/Fifa/LegacyBigFilePlugin.dll`, `LegacyDatabasePlugin.dll`, `LegacyDdsPlugin.dll`, `LegacyKitPreviewPlugin.dll`, `LegacyLocalizedStringsPlugin.dll`, `LegacyTextPlugin.dll`; ainda `EbxToXmlPlugin.dll`, `ChunkResEditorPlugin.dll`, `ReferencesPlugin.dll`, `TypeExplorerPlugin.dll`, `TexturePlugin.dll`, `AtlasTexturePlugin.dll`, `SvgImagePlugin.dll`, `LuaPlugin.dll`, `BundleRefTablePlugin.dll`, `LaunchPlatformPlugin.dll`. Presença não valida carregamento ou suporte da tela.

Manager ZIP: plugins BiowareLocalization, BundleRefTable, FsLocalization e MeshSet. Manager extraído: BiowareLocalization, DifficultyWeaponTableData, FsLocalization, MeshSet e Swbf2Merger. Diferenças reforçam que não são pacotes idênticos. O extraído inclui instaladores `Prereqs/NET Framework 4.7.2.exe` e redistribuíveis VC++ 2015/2017; não foram executados. ZIPs declaram `.NETFramework,Version=v4.8` em seus `.exe.config`. Editor também traz bibliotecas SharpDX, FBX, compressão e áudio em `ThirdParty`; dependências nativas transitivas não foram resolvidas por execução.

`Final/FrostyCmd.exe` existe no Editor ZIP: SHA-256 `e8b6b975e434ef0e494c29ef472e955efbb329ea222b06f82ceaa51215201571`, versão declarada 1.0.0.0. Nenhuma CLI de exportação/importação foi validada.

## Utilitários e dependências

| Ferramenta | Evidência | Situação prática |
| --- | --- | --- |
| Git | `C:\Program Files\Git\cmd\git.exe`, 2.49.0.windows.1 | Comando funciona; projeto sem repositório válido |
| Python | `C:\Program Files\Python313\python.exe`, 3.13.2 | Script de inventário executado; biblioteca padrão suficiente; venv dispensável nesta fase |
| Codex CLI | `AppData\Local\Programs\OpenAI\Codex\bin\codex.exe`, 0.159.0 | Versão funciona; avisos de acesso negado ao limpar temporários/criar aliases; investigação local continuou |
| 7-Zip | `%USERPROFILE%\scoop\shims\7z.exe`, 24.09 x64 | `7z i` executado; ZIPs examinados por Python |
| Editor textual | Notepad do Windows, versão 10.0.26100.8875 | Arquivo presente; GUI não testada. `code` não está no PATH; caminhos usuais VS Code ausentes; pasta Cursor contém apenas `resources`, não instalação funcional comprovada |
| WinMerge | `<raiz>\winmerge\WinMergeU.exe`, 2.16.58.2 | Presença/versão, comparação gráfica não executada |
| ImHex | `<raiz>\imhex\imhex.exe` e `imhex-gui.exe` | Sem versão PE útil; não executado; funcionamento não verificado |
| .NET Framework | Registro Full: 4.8.09221, Release 533509 | Família 4.8 instalada; declaração dos ZIPs atendida em inventário; abertura ainda pendente |
| VC++ | Registro x64 `Installed=1`, v14.51.36247.00 | Não prova todas as DLLs nativas. Chave x86 consultada não retornou valor; não instalar preventivamente |
| dotnet | SDKs 8.0.420, 9.0.122, 10.0.402; runtimes Core/Desktop 8.0.32, 9.0.21, 10.0.13; ASP.NET 8.0.26, 9.0.21, 10.0.13 | Executados; não substituem .NET Framework |
| Visual Studio | Diretório `2022` sem instalação retornada; `devenv` e `vswhere` não encontrados nos pontos consultados | Compilador/workloads não verificados; condicional |
| ILSpy / Ghidra | Fora do PATH e não encontrados nas pastas usuais consultadas; `FrostyCore.pdb`, `FrostyModSupport.pdb` e outros PDBs acompanham a instalação local | Ausência global não demonstrada; ILSpy ainda não necessário. PDB permite mapear símbolos/linhas, mas não traz prova de revisão sem comparação com fonte |
| WSL | `wsl.exe` no PATH | Não usado; presença não comprova distribuição instalada |
| Captura | Ferramenta de recorte não confirmada pelas consultas usuais | Captura manual pode ser entregue por qualquer ferramenta disponível; não bloquear pesquisa estática |

## Reprodução dos diagnósticos

Comandos relevantes, todos de leitura salvo criação dos entregáveis:

```powershell
Get-Location
rg --files --hidden -g AGENTS.md
git status --short
git -C .. rev-parse --show-toplevel
Get-Item 'FIFA 17\FIFA17.exe' | ForEach-Object { $_.VersionInfo }
python scripts/audit-local.py
git --version
python --version
codex --version
7z i
dotnet --list-runtimes
dotnet --list-sdks
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
Get-PSDrive -PSProvider FileSystem
```

O script lê metadados/hashes dos ZIPs e arquivos relevantes; não extrai, modifica nem executa o conteúdo. Sua saída é um inventário temporário, não um log adicional versionado. CRC integral foi verificado separadamente por `zipfile.ZipFile(...).testzip()`; retorno `None` nos dois ZIPs. `Get-CimInstance Win32_OperatingSystem` teve acesso negado; registro e `$PSVersionTable` forneceram evidência alternativa. A rede do shell recusou consulta HTTPS via proxy local; navegação web obteve páginas públicas, mas não os fontes individuais/API. Ver detalhes e limites em `documentation-review.md`.
