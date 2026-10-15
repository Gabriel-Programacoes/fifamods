# Projeto de modernização de interface — FIFA 16 / FIFA 17

**Responsável:** Gabriel  
**Data:** 13/10/2026  
**Status:** planejamento; arquivos do jogo ainda não inspecionados e compatibilidade local ainda não testada.  
**Ambiente previsto:** PC Windows, com Codex CLI como assistente de desenvolvimento.  
**Configuração de trabalho pretendida:** GPT-6 Sol, esforço médio, conforme disponibilidade na instalação do usuário.

## 1. Objetivo

Desenvolver um mod que modernize a interface nativa de um FIFA de PC, começando por uma única tela de estatísticas. O objetivo é modificar a apresentação de elementos reais: distribuição das colunas, espaçamento, alinhamento, hierarquia visual e estados de seleção, preservando os dados e a navegação do jogo.

O projeto inclui investigação dos formatos, uso de editores comunitários e, quando necessário, desenvolvimento de scripts, conversores ou extensões de ferramentas.

Instalar as ferramentas cria um ambiente de trabalho, mas não garante que a tela desejada seja editável. A primeira fase deve produzir evidência técnica antes de assumir compromisso com o redesign completo.

## 2. Escolha do jogo

**Escolha provisória: investigar primeiro o jogo que Gabriel já tenha instalado e funcionando.** Se ambos estiverem disponíveis, executar uma investigação curta de cada um e selecionar aquele em que for possível alterar a estrutura da tela com menor complexidade.

| Candidato | Base disponível | Limite da evidência | Primeira ferramenta |
| --- | --- | --- | --- |
| FIFA 16 PC | Creation Master 16 2.0 permite editar imagens e ícones de menus; há fluxos comunitários de regeneração de arquivos. [1][3] | Esses recursos não comprovam edição de posições, colunas ou lógica de tabelas. | Creation Master 16 2.0; explorar CG File Explorer 16 conforme necessidade. |
| FIFA 17 PC | Edição comunitária do Frosty dedicada ao jogo, com release 2.0 e correções de recursos Legacy. [2] | A release não documenta um editor completo de layout das tabelas. | Frosty Editor + Mod Manager da edição FIFA 17. |

Não desenvolver duas versões do mod em paralelo. O segundo jogo funciona como alternativa durante a investigação; portabilidade será avaliada depois do primeiro resultado.

**Revisão da recomendação anterior:** a disponibilidade de edição de imagens no FIFA 16, por si só, não demonstra que ele seja mais fácil para uma modernização estrutural de interface.

## 3. Escopo inicial

### 3.1 Tela candidata

Uma tabela de estatísticas de jogadores acessível em modo offline, preferencialmente em um save de teste reproduzível. A tela exata será escolhida após Gabriel fornecer captura e sequência de navegação.

Se essa tabela não tiver uma rota viável de edição, avaliar outra tela tabular nativa antes de ampliar o projeto para engenharia reversa de código executável.

### 3.2 Primeira entrega funcional — MVP

- Uma tela nativa modificada no jogo escolhido.
- Ao menos uma alteração estrutural verificável: largura ou posição de coluna, altura de linha, posição de cabeçalho ou organização de um grupo de elementos.
- Melhorias visuais complementares dentro do que o formato permitir: contraste, espaçamento, tipografia, divisórias e destaque da seleção.
- Os mesmos dados e campos do jogo original, corretamente associados aos títulos e jogadores.
- Navegação existente preservada: entrar, percorrer a lista, rolar, alternar abas quando houver e voltar.
- Mod aplicável e removível por procedimento documentado.
- Capturas antes/depois, registro das versões e lista dos arquivos alterados.

**Trocar somente o fundo, pintar uma textura ou apresentar um mockup externo não atende ao MVP.** Uma troca de imagem pode ser usada apenas para comprovar que a extração e aplicação funcionam.

### 3.3 Evolução após o MVP

1. Consolidar um padrão visual para tabelas semelhantes.
2. Estender o padrão para outras telas que compartilhem os componentes investigados.
3. Avaliar ordenação, filtros e novas interações, caso existam pontos de extensão identificados.
4. Avaliar novos indicadores apenas quando houver fonte de dados disponível e entendimento de como conectá-los à interface.
5. Considerar portabilidade para o outro FIFA com investigação própria.

### 3.4 Fora da primeira versão

- Interface inteira, menus completos ou substituição do sistema de UI.
- Novas estatísticas, novos modos, gameplay, elencos e alterações de carreira.
- Faces, estádios, uniformes e áudio.
- Compatibilidade com grandes patches de terceiros.
- Consoles e recursos online.
- Overlay externo como substituição automática da interface nativa.

Um overlay pode ser discutido como projeto alternativo, mas precisa ser identificado como tal e não como conclusão do objetivo original.

## 4. Requisitos do ambiente

### 4.1 O que Gabriel precisa disponibilizar

- [ ] FIFA 16 ou FIFA 17 para PC instalado e abrindo normalmente.
- [ ] Caminho da instalação e versão do executável; informar atualizações e patches existentes.
- [ ] Idioma, resolução, modo de exibição e controle utilizado.
- [ ] Captura da tela candidata e passos exatos para chegar a ela.
- [ ] Save ou perfil de teste, quando necessário, separado do progresso pessoal.
- [ ] Referências visuais e descrição do que deseja melhorar: densidade, colunas, legibilidade, cores e navegação.
- [ ] Cópia de segurança dos arquivos que serão modificados e dos saves envolvidos.
- [ ] Disponibilidade para abrir o jogo, executar etapas manuais e retornar capturas ou logs.

Os arquivos ficam no PC de desenvolvimento. Para analisar algo nesta conversa, fornecer apenas os trechos, exportações, listagens e capturas necessários; não é preciso enviar a instalação inteira.

### 4.2 Sistema e recursos

- Usar o Windows onde o jogo já funciona. Validar a compatibilidade de cada ferramenta antiga nesse sistema.
- Espaço livre para backup dos arquivos afetados, exportações e caches. Se possível, manter também uma cópia completa de referência; calcular a necessidade após medir a instalação.
- Git para versionar código e documentação; manter arquivos originais grandes fora do repositório.
- Permissão de leitura sobre o jogo e escrita sobre a área de trabalho e os destinos de mod necessários.
- Instalar runtimes .NET, Visual C++ ou DirectX somente conforme os requisitos da edição específica de cada programa. Não supor que instalar apenas o runtime mais novo satisfaça aplicações antigas.

Não há um requisito novo de GPU demonstrado para esta pesquisa além de executar o jogo e as ferramentas. A necessidade de RAM e disco deve ser medida durante as primeiras exportações.

### 4.3 Integração com o Codex

O Codex precisa ter acesso à pasta do projeto, exportações, documentação, logs e código das ferramentas quando disponível. Se estiver em WSL ou outro ambiente separado, verificar o acesso aos caminhos do Windows e como executar os programas nativos.

Acesso ao terminal não implica controle automático de interfaces gráficas. Os programas sem CLI podem exigir operação manual de Gabriel ou uma integração de automação de interface efetivamente disponível e testada.

## 5. Programas e ferramentas

### 5.1 Kit comum para instalar primeiro

| Programa | Finalidade | Critério de preparação |
| --- | --- | --- |
| Codex CLI | Analisar arquivos exportados, escrever scripts e documentar descobertas. | Executar uma leitura e um script simples na pasta do projeto. |
| Git for Windows | Versionar scripts, documentação e configurações. | Repositório local com arquivos grandes e originais excluídos. |
| Python 3 | Inventários, hashes, comparação binária e utilitários de conversão. | Ambiente virtual do projeto; dependências fixadas quando surgirem. |
| VS Code ou editor equivalente | Revisar código, Markdown, logs e dados textuais. | Abrir a pasta do projeto. |
| 7-Zip | Extrair pacotes de ferramentas e mods. | Extrair cada ferramenta para sua própria pasta. |
| WinMerge | Comparar arquivos e pastas antes/depois. | Comparação de uma exportação original com uma cópia. |
| HxD ou ImHex | Inspecionar cabeçalhos e diferenças em arquivos binários. | Começar em cópias de trabalho; registrar toda edição manual. |

Fontes oficiais de utilitários gerais: [Git](https://git-scm.com/downloads), [Python](https://www.python.org/downloads/), [VS Code](https://code.visualstudio.com/), [7-Zip](https://www.7-zip.org/), [WinMerge](https://winmerge.org/), [HxD](https://mh-nexus.de/en/hxd/), [ImHex](https://imhex.werwolv.net/). As versões serão registradas no inventário local.

### 5.2 Se o jogo escolhido for FIFA 16

| Ferramenta | Prioridade | Uso previsto e limite |
| --- | --- | --- |
| Creation Master 16 2.0 | Inicial | Inspeção e edição de recursos suportados, incluindo gráficos de menu; também oferece regeneração BH no fluxo documentado. Não é uma promessa de editor de layout. [1][3] |
| CG File Explorer 16 | Condicional, provavelmente útil na investigação | Explorar recursos e usar as operações de exportação/importação efetivamente disponíveis na versão obtida. Confirmar suporte ao arquivo candidato antes de adotá-lo. A referência comunitária lista a versão 0.8. [3] |
| i68 Controller / regenerator | Alternativa | Usar se a regeneração do CM16 ou CG File Explorer não atender ao fluxo. Não é necessário instalar três regeneradores para fazer a mesma operação. [3] |

Baixar o CM16 pela página que hospeda a publicação do autor: [Creation Master 16 2.0](https://dl.fifa-infinity.com/fifa-16/tools-fifa-16/creation-master-16/).

Para CG File Explorer e i68, os links históricos constam na [documentação do FIFA Freestyle 16](https://github.com/Joessarian/FIFA-Freestyle-16#installation-instructions). A disponibilidade e os binários desses links ainda precisam de validação local. O mod Freestyle não deve ser instalado como requisito deste projeto.

Definir um único fluxo de regeneração depois dos testes iniciais. Não alternar ferramentas sobre os mesmos arquivos sem registrar o resultado.

### 5.3 Se o jogo escolhido for FIFA 17

| Ferramenta | Prioridade | Uso previsto e limite |
| --- | --- | --- |
| Frosty Editor — FIFA 17 edition | Inicial | Explorar e exportar recursos suportados, montar o projeto e gerar o mod. |
| Frosty Mod Manager — edição compatível | Inicial | Aplicar o mod e iniciar o jogo pelo fluxo validado. Usar o par indicado pelo mantenedor. |
| Código-fonte da edição FIFA 17 | Condicional | Investigar serialização, suporte a formatos e eventuais extensões do editor quando os recursos da tela exigirem. |

Referência inicial: [Frosty Toolsuite — FIFA 17 edition 2.0](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/newrelease). Registrar data, hash e pacote baixado; conferir se há correções posteriores necessárias à instalação. [2]

Não assumir que uma versão genérica recente do Frosty, nem que ferramentas voltadas aos EA Sports FC atuais, tenham suporte equivalente ao FIFA 17. Validar abrir o jogo, salvar o projeto, exportar e aplicar o mod antes de começar o redesign.

### 5.4 Instalar somente quando o diagnóstico justificar

| Ferramenta | Quando faz sentido |
| --- | --- |
| GIMP ou outro editor com suporte ao formato encontrado | Quando houver texturas ou atlas a modificar. Preservar dimensões, compressão, transparência e mipmaps conforme o recurso original. |
| Visual Studio / Build Tools e SDKs correspondentes | Quando for necessário compilar uma ferramenta C#/C++. Determinar versões a partir do projeto; não instalar workloads por tentativa. |
| ILSpy | Quando for útil examinar uma ferramenta .NET, especialmente para entender leitores e gravadores de arquivos. |
| Ghidra e, se necessário, x64dbg | Quando a investigação realmente chegar a código nativo. Formam uma trilha adicional de pesquisa, com prazo próprio. |
| Process Monitor | Para investigar falhas de acesso a arquivos e inicialização. O acesso a um arquivo de pacote não identifica sozinho qual recurso interno pertence à tela. |
| OBS Studio | Para registrar transições, rolagem, seleção e comparações visuais que uma captura estática não mostra. |

Editores de banco de dados, Blender, ferramentas de áudio e grandes pacotes de mods não são requisitos do MVP. Um editor de banco não é, por si só, um editor da tabela visual exibida na tela.

Não escolher previamente um editor de SWF, um ambiente Lua ou um parser XML: primeiro identificar o formato real. A presença de scripts Lua em um mod externo não comprova que os menus nativos do FIFA usem Lua.

## 6. Plano de execução e critérios de passagem

### Fase 0 — Preparar e reproduzir o estado original

**Atividades:** registrar versões, testar abertura sem mods, preparar backup, criar perfil de teste, capturar a tela e documentar como acessá-la. Instalar o kit mínimo do jogo escolhido.

**Entregáveis:** inventário do ambiente, captura original e procedimento de restauração.

**Passagem:** conseguir abrir a mesma tela de forma previsível e restaurar os arquivos afetados.

### Fase 1 — Descobrir como a tela é construída

1. Gerar inventário de arquivos, extensões, tamanhos e hashes relevantes.
2. Explorar catálogos do editor e procurar candidatos por nomes, textos visíveis e referências.
3. Exportar um conjunto pequeno de candidatos, preservando a relação entre identificador interno e caminho exportado.
4. Identificar quais partes representam imagens, estilos, geometria, textos, dados, navegação ou código.
5. Investigar como a tabela recebe os dados e se o componente é compartilhado com outras telas.
6. Registrar cada hipótese junto da evidência que a sustenta.

**Entregável:** mapa preliminar da tela, com o que está confirmado, provável e desconhecido.

**Passagem:** identificar ao menos um candidato concreto para mudança estrutural e uma rota de reimportação. Se isso não ocorrer, produzir um relatório de bloqueio e escolher outra tela, outro jogo ou uma pesquisa de formato mais profunda.

### Fase 2 — Provar a edição estrutural

1. Exportar e reimportar um recurso sem alteração para validar o percurso completo.
2. Aplicar uma única mudança identificável, como deslocar um cabeçalho ou alterar a largura de uma coluna.
3. Testar no jogo, capturar o resultado e comparar com o original.
4. Remover o mod e confirmar a restauração.

**Passagem obrigatória para o redesign:** alteração estrutural comprovada dentro da tela nativa, mantendo os dados e sem quebrar a navegação relevante.

Se apenas texturas forem editáveis, registrar suporte visual parcial. Isso ainda não comprova viabilidade do MVP.

### Fase 3 — Projetar a tabela modernizada

- Definir a hierarquia entre título, cabeçalho, linhas, números e seleção.
- Alinhar valores numéricos e criar espaçamentos consistentes.
- Reservar espaço para nomes longos, acentos e variações de valores.
- Manter os campos e as ações existentes nesta primeira versão.
- Produzir um mockup usando as limitações confirmadas na fase anterior.
- Definir a resolução principal e uma segunda resolução de teste suportada pelo jogo.

**Entregável:** especificação visual com medidas e comportamento esperado por estado.

### Fase 4 — Implementar e tornar reproduzível

- Aplicar pequenas alterações por vez e versionar cada avanço funcional.
- Criar scripts apenas para as operações repetitivas ou sujeitas a erro.
- Validar tamanhos, referências e estrutura dos recursos antes de importá-los.
- Manter arquivos originais separados dos modificados.
- Gerar mod e manifesto de conteúdo com hashes e versões.
- Documentar etapas manuais que o editor não permite automatizar.

**Entregável:** primeira versão instalável do mod e seu procedimento de construção.

### Fase 5 — Validar e entregar

Executar a matriz abaixo, corrigir os defeitos encontrados e empacotar uma versão compatível com a instalação documentada.

**Entregáveis:** mod, fontes próprias, guia de instalação/remoção, capturas, limitações conhecidas e relatório de testes.

## 7. Matriz de aceitação

| Verificação | Resultado esperado |
| --- | --- |
| Aplicação | O mod carrega na versão do jogo registrada. |
| Estrutura | Pelo menos uma alteração de layout é comprovada dentro do jogo. |
| Dados | Títulos, jogadores e valores permanecem corretos e associados às mesmas colunas. |
| Atualização | Ao mudar o contexto ou avançar o save de teste, a tabela mostra os dados atuais; não é uma imagem estática. |
| Seleção | O destaque acompanha a linha correta. |
| Navegação | Entrar, rolar, alternar abas existentes e voltar funcionam nos dispositivos definidos para teste. |
| Casos extremos | Nomes longos, acentos, muitos registros e valores maiores não produzem sobreposição. |
| Resolução | A tela funciona na resolução principal e em uma segunda resolução suportada. |
| Componentes compartilhados | Telas que usam os mesmos recursos não apresentam regressões visíveis. |
| Repetição | A tela abre corretamente após reiniciar o jogo e reaplicar o mod. |
| Desempenho | Não surgem travamentos ou regressões perceptíveis em comparação com o estado original; medir se houver suspeita. |
| Remoção | Desativar ou restaurar os arquivos recupera o estado original. |

Registrar cada teste como aprovado, reprovado ou não executado, com versão do mod e evidência. Não declarar compatibilidade com configurações que não foram testadas.

## 8. Organização do projeto

| Caminho relativo | Conteúdo |
| --- | --- |
| `README.md` | Objetivo, jogo escolhido, estado atual e como reproduzir. |
| `AGENTS.md` | Instruções para o Codex, comandos válidos e critérios de conclusão. |
| `docs/environment.md` | Versões, caminhos locais, hashes e requisitos confirmados. |
| `docs/research.md` | Hipóteses, experimentos e descobertas. |
| `docs/ui-map.md` | Relação entre tela, componentes e recursos internos. |
| `docs/test-results.md` | Resultados da matriz de aceitação. |
| `docs/next-session.md` | Último resultado, bloqueio atual e próximo experimento. |
| `tools/` | Scripts e utilitários próprios. |
| `design/` | Especificação visual e fontes gráficas próprias. |
| `work/original/` | Exportações originais locais; fora do Git. |
| `work/modified/` | Recursos de trabalho derivados. |
| `evidence/` | Capturas antes/depois e logs relevantes. |
| `dist/` | Pacotes produzidos e manifestos de versão. |

Manter executáveis do jogo, saves pessoais, backups, caches e grandes exportações fora do Git. Guardar código das ferramentas de terceiros em checkouts separados, com a revisão utilizada registrada.

## 9. Como trabalhar com GPT-6 Sol em esforço médio

Esta é uma estratégia de trabalho proposta, não uma medição de desempenho do modelo nesse jogo. Não há garantia de que determinada configuração resolverá um formato desconhecido.

- Dar ao agente uma hipótese por tarefa: localizar um recurso, comparar exportações ou testar uma propriedade.
- Exigir que caminhos, formatos e comandos sejam baseados nos arquivos realmente disponíveis.
- Fornecer amostras pequenas e representativas em vez de exportações enormes sem índice.
- Manter um diário de descobertas para evitar repetir tentativas entre sessões.
- Pedir diffs e justificativa técnica para toda mudança em binários ou ferramentas.
- Usar testes de leitura/escrita e comparação para validadores e conversores próprios quando houver risco de corromper a estrutura.
- Diante de tentativas repetidas sem progresso, revisar a hipótese, obter nova evidência e considerar aumentar o esforço ou usar outro modelo para uma pergunta específica.

### Divisão do trabalho

| Codex | Gabriel |
| --- | --- |
| Inventariar arquivos acessíveis, analisar exportações, escrever scripts e documentar. | Disponibilizar instalação, versões, tela alvo e referências. |
| Investigar código de ferramentas e construir alterações quando viáveis. | Operar editores gráficos quando não houver automação disponível. |
| Preparar pacotes e verificações automatizadas. | Rodar o jogo, validar a interação e devolver evidências. |
| Consolidar resultados e indicar o próximo experimento. | Aprovar a direção visual e avaliar se a interface ficou melhor de usar. |

## 10. Esforço e decisões de continuidade

**Orçamento inicial proposto, não previsão de conclusão:** reservar de duas a quatro sessões de 1–2 horas para preparar o ambiente e tentar localizar uma rota de edição estrutural de uma tela. Esse limite serve para revisar a estratégia, não para prometer um resultado.

| Resultado da investigação | Próxima decisão |
| --- | --- |
| Layout editável e reimportação funcional | Estimar o MVP com base nos componentes identificados. |
| Formato compreendido, mas gravador incompleto | Criar uma tarefa limitada de extensão da ferramenta e testes de leitura/escrita. |
| Apenas imagens acessíveis | Investigar recursos estruturais ou trocar a tela/jogo; não declarar o objetivo cumprido. |
| Estrutura dependente de código ainda não compreendido | Separar uma etapa de engenharia reversa e reavaliar esforço antes de assumir o redesign. |
| Ferramenta incompatível com a instalação | Resolver a compatibilidade ou avaliar o outro jogo. |

Depois da prova estrutural, dividir a implementação em tarefas de uma sessão e reestimar com base no tempo real de cada ciclo de aplicar, abrir e validar. Engenharia reversa pode consumir semanas ou permanecer inconclusiva; não há prazo confiável antes do diagnóstico.

## 11. Riscos concretos e tratamento

| Risco | Tratamento |
| --- | --- |
| Ferramenta abre o recurso, mas não consegue salvá-lo corretamente | Validar exportação/reimportação sem alteração antes do redesign. |
| Recursos compartilhados afetam outras telas | Mapear referências e testar as telas relacionadas. |
| Patches existentes confundem o resultado | Começar com uma base conhecida e somente um mod de teste ativo. |
| Alteração visual troca o significado dos dados | Comparar campo a campo usando o mesmo save/contexto. |
| Layout e áreas de interação ficam desalinhados | Testar seleção e navegação depois de cada mudança de posição. |
| Pacotes antigos ou links históricos estão indisponíveis | Registrar a origem e versão obtidas; não apresentar download inacessível como dependência resolvida. |
| Mudança de versão quebra o mod | Fixar a combinação testada de jogo, editor e gerenciador. |

## 12. Checklist de início rápido

1. Escolher o jogo já disponível para a primeira investigação.
2. Capturar uma tela de estatísticas e anotar os passos de acesso.
3. Instalar Git, Python, editor, 7-Zip, comparador e editor hexadecimal.
4. Instalar CM16 2.0 para FIFA 16 ou o par Frosty FIFA 17 para FIFA 17.
5. Registrar as versões e testar a abertura do jogo e do editor.
6. Separar backup e perfil de teste.
7. Criar a pasta do projeto e o inventário inicial.
8. Exportar um pequeno conjunto de recursos candidatos e validar a reimportação.
9. Provar uma alteração estrutural na tela.
10. Só então fechar o design e a estimativa do MVP.

## 13. Instrução inicial para usar no Codex CLI

```text
Leia este planejamento e o AGENTS.md, caso exista. O objetivo é modernizar
uma tela nativa de estatísticas do FIFA, com alteração real de layout.

Comece pela fase de diagnóstico. Identifique o jogo, a versão, as ferramentas
disponíveis e os caminhos acessíveis. Registre o que foi confirmado e o que
ainda depende de inspeção ou teste manual.

Inventarie os arquivos e exportações relevantes, preservando os originais.
Investigue a relação entre os recursos candidatos e a tela escolhida.
Não presuma que a UI usa XML, Lua, SWF ou qualquer outro formato.

Monte o menor experimento que permita exportar, reimportar e comprovar uma
alteração estrutural, como largura de coluna ou posição de cabeçalho.
Uma troca de imagem não satisfaz o critério de edição estrutural.

Documente comandos executados, versões, arquivos alterados, resultados e
próximo passo. Se precisar de uma ação no editor ou de teste no jogo que você
não possa executar, descreva exatamente a ação e a evidência necessária.
Não declare sucesso no jogo apenas porque o arquivo foi salvo ou empacotado.
```

## 14. Fontes e limites da pesquisa

Consulta realizada em 13/10/2026. As fontes abaixo fundamentam a seleção inicial de ferramentas; o fluxo proposto, os critérios e as estimativas são decisões de planejamento. Nenhuma instalação ou edição do jogo foi realizada nesta etapa.

1. **Rinaldo — Creation Master 16 2.0**, publicação do autor hospedada em FIFA Infinity. Documenta edição de imagens e ícones dos menus e restrições dos recursos gráficos. Não demonstra edição estrutural de tabelas.  
   https://dl.fifa-infinity.com/fifa-16/tools-fifa-16/creation-master-16/
2. **Frosty Toolsuite — FIFA 17 edition 2.0**, release do projeto. Lista melhorias em meshes, duplicação de assets, áudio e correções de recursos Legacy. Esses avanços não comprovam edição de layout da tela pretendida.  
   https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/newrelease
3. **Joessarian — FIFA Freestyle 16**, documentação do autor de um mod. Registra opções de regeneração com CM16, CG File Explorer e i68. Seu fluxo serve como referência de ferramentas, não como validação do nosso futuro mod.  
   https://github.com/Joessarian/FIFA-Freestyle-16
4. **Vivianroberto — apresentação do Frosty FIFA 17 edition**, tópico do desenvolvedor com exemplos e discussão de correções.  
   https://soccergaming.com/forums/threads/frosty-editor-fifa-17-edition-2-0-released-mesh-importion-support-unlimited-real-faces-in-the-game-sound-editing-and-more.6475801/

**Primeiro marco do projeto:** confirmar, com evidência dentro do jogo, que conseguimos alterar a estrutura de uma tela nativa e restaurar o original. Esse resultado define a viabilidade e a próxima estimativa.
