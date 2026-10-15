# FIFA 17 — Plano de modernização da interface nativa

**Responsável:** Gabriel  
**Data:** 13/10/2026  
**Plataforma:** FIFA 17 para PC Windows  
**Assistente de desenvolvimento previsto:** Codex CLI com GPT-6 Sol em esforço médio  
**Status:** plano técnico; instalação, recursos da tela e compatibilidade local ainda não inspecionados.

62994543630
## 1. Objetivo e primeira entrega

Modernizar uma tela de estatísticas do FIFA 17, alterando o layout nativo e preservando os dados e a navegação. O projeto deve produzir um mod que funcione dentro do jogo e um processo reproduzível de construção, aplicação e remoção.

**Tela candidata:** uma tabela de estatísticas de jogadores acessível em modo offline, preferencialmente em um save de carreira de teste. A tela exata e seu caminho de navegação serão registrados a partir de uma captura fornecida por Gabriel; não se presume um nome de menu antes dessa confirmação.

**MVP:** reorganizar o espaço da tabela, melhorar a leitura dos cabeçalhos e valores e ajustar o destaque da seleção. A entrega precisa conter pelo menos uma alteração estrutural demonstrada no jogo, como largura de coluna, altura de linha ou posição de cabeçalho.

Troca de textura serve como teste de carregamento, mas não conclui esse objetivo. Novas estatísticas, filtros inéditos e ordenação adicional ficam para uma fase posterior: exigem investigar a lógica e a origem dos dados, além da apresentação.

## 2. Estratégia específica para FIFA 17

O fluxo inicial será **Frosty Editor da edição FIFA 17 → projeto do mod → exportação → Frosty Mod Manager compatível → teste no jogo**.

A release comunitária 2.0 consultada anuncia melhorias de importação de modelos, duplicação de recursos, áudio e correções de recursos Legacy. Ela fornece uma base de investigação, mas não comprova suporte à edição estrutural da tela pretendida. [1]

O trabalho terá três níveis, usados conforme a evidência:

| Nível | Abordagem | Quando avançar |
| --- | --- | --- |
| A — Recursos expostos pelo editor | Localizar propriedades ou arquivos da tela, editar pelo suporte existente e empacotar. | Primeira opção; seguir se a alteração sobreviver à aplicação no jogo. |
| B — Ferramenta complementar | Ler o formato exportado e criar um conversor, gravador ou extensão do Frosty quando necessário. | Só quando houver um arquivo identificado e uma limitação concreta de edição. |
| C — Investigação de código nativo | Analisar o comportamento que não foi encontrado em recursos editáveis. | Tratar como etapa adicional de pesquisa, com objetivo e esforço próprios. |

**O primeiro compromisso é comprovar a viabilidade, não prometer antecipadamente um redesign completo.** Não substituir a UI nativa por um overlay sem discutir essa mudança de objetivo.

## 3. Escopo da versão 0.1

### Incluído

- Uma tela, em uma versão identificada do FIFA 17 PC.
- Os campos e as estatísticas já exibidos pelo jogo.
- Mudança comprovada na organização de elementos da tabela.
- Refinamento de contraste, divisórias, alinhamento, espaçamento e seleção, conforme o suporte encontrado.
- Fonte original inicialmente; tamanho e estilo só serão alterados quando a estrutura permitir.
- Navegação existente por controle e teclado, conforme suporte original da tela.
- Idioma PT-BR como alvo inicial se estiver disponível na instalação.
- Resolução principal de 1920 × 1080, se suportada pelo ambiente; segunda resolução definida no diagnóstico.
- Mod, projeto editável, scripts próprios, instruções e evidências de teste.

### Fora da versão 0.1

- Reformulação de todos os menus.
- Alteração de gameplay, saves, elencos ou regras de carreira.
- Inclusão de campos sem fonte de dados conhecida.
- Novos filtros, ordenação e comandos de navegação.
- Faces, uniformes, estádios, música e narração.
- Compatibilidade com patches de terceiros, outras versões ou consoles sem teste específico.

## 4. Requisitos que Gabriel deve fornecer

| Informação ou acesso | Motivo |
| --- | --- |
| Instalação funcional e caminho de `FIFA17.exe` | Identificar a base e configurar o editor/gerenciador. |
| Versão do executável e lista de atualizações ou mods | Evitar comparar resultados de instalações diferentes. |
| Forma atual de iniciar o jogo e launcher utilizado | Reproduzir o funcionamento antes de introduzir o Frosty. |
| Captura da tabela e passos de acesso | Definir a tela alvo sem depender de suposições sobre os menus. |
| Save de teste que chega à tela | Repetir os testes sem comprometer o progresso pessoal. |
| Idioma, resolução e dispositivos de entrada | Fixar os critérios de compatibilidade inicial. |
| Referência visual ou descrição das melhorias desejadas | Orientar o design depois da prova técnica. |
| Acesso do Codex à pasta do projeto e às exportações | Permitir análise e automação. |

O jogo deve abrir e alcançar a tela sem o novo mod antes de qualquer alteração. Manter backup dos saves e dos arquivos afetados; se houver espaço, guardar uma cópia completa da instalação de referência.

O Codex no terminal não tem automaticamente controle de aplicativos gráficos. Exportações no Frosty e validação no jogo podem exigir ações manuais de Gabriel. Registrar essas ações no procedimento de construção.

## 5. Programas a preparar

### 5.1 Kit inicial obrigatório para este fluxo

| Programa | Uso no projeto | Validação inicial |
| --- | --- | --- |
| **Frosty Editor — FIFA 17 edition** | Explorar recursos, criar projeto, importar alterações e exportar mod. | Abrir a instalação, listar recursos e salvar/reabrir um projeto. |
| **Frosty Mod Manager compatível com essa edição** | Aplicar o pacote e iniciar o jogo. | Testar a inicialização e um mod mínimo isolado. |
| **Codex CLI** | Investigar exportações, escrever scripts e manter a documentação. | Acessar a pasta do projeto e executar um script local. |
| **Git for Windows** | Versionar código, especificações e registro de investigação. | Criar repositório local com exclusões apropriadas. |
| **Python 3** | Inventariar, calcular hashes, comparar e validar arquivos. | Criar ambiente virtual e executar inventário simples. |
| **7-Zip** | Extrair pacotes das ferramentas. | Manter cada versão em uma pasta separada. |
| **VS Code ou editor equivalente** | Revisar texto, código, logs e dados exportados. | Abrir a pasta de trabalho. |

**Download principal:** [Frosty Toolsuite — FIFA 17 edition 2.0](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/newrelease). Consultar também as [releases do projeto](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases) para verificar correções aplicáveis. [1]

Usar Editor e Mod Manager da combinação indicada pelo mantenedor. Não misturar DLLs, plugins ou executáveis de edições diferentes para resolver erros por tentativa.

### 5.2 Kit de inspeção recomendado desde o início

| Programa | Uso |
| --- | --- |
| WinMerge | Comparar exportações, arquivos textuais e pastas. |
| HxD ou ImHex — escolher um | Examinar cabeçalhos e diferenças em arquivos binários. |
| Ferramenta de captura do Windows | Registrar cada experimento na tela. |
| OBS Studio, opcional | Gravar rolagem, seleção, transições e defeitos intermitentes. |

### 5.3 Ferramentas condicionais

| Ferramenta | Instalar quando |
| --- | --- |
| GIMP ou editor gráfico equivalente | Surgir necessidade de editar texturas ou atlas associados à tabela. |
| Visual Studio e componentes de compilação | For necessário compilar ou estender uma ferramenta. |
| ILSpy | A análise de uma ferramenta .NET for útil para entender importação ou serialização. |
| Process Monitor | Houver problema de inicialização ou acesso a arquivos. |
| Ghidra / x64dbg | A investigação justificar análise estática ou dinâmica de código nativo. |

O README do fork consultado menciona Visual Studio 2019 e configuração `DeveloperDebug/x64`. Suas instruções também fazem referência à branch `1.0.6`, enquanto a página apresenta `main`; portanto, a receita de compilação precisa ser confrontada com a revisão efetivamente usada, antes de instalar SDKs ou escolher uma branch. [2]

Não instalar preventivamente um editor de SWF, framework Lua, Blender ou editor de banco de dados. O formato da tela ainda é desconhecido, e essas ferramentas não constituem requisitos demonstrados para o MVP.

### 5.4 Fontes oficiais dos utilitários

- [Git for Windows](https://git-scm.com/downloads/win)
- [Python](https://www.python.org/downloads/)
- [VS Code](https://code.visualstudio.com/)
- [7-Zip](https://www.7-zip.org/)
- [WinMerge](https://winmerge.org/)
- [HxD](https://mh-nexus.de/en/hxd/) ou [ImHex](https://imhex.werwolv.net/)
- [GIMP](https://www.gimp.org/downloads/)
- [Visual Studio](https://visualstudio.microsoft.com/)
- [ILSpy](https://github.com/icsharpcode/ILSpy)
- [Process Monitor](https://learn.microsoft.com/sysinternals/downloads/procmon)
- [OBS Studio](https://obsproject.com/)
- [Ghidra](https://github.com/NationalSecurityAgency/ghidra) e [x64dbg](https://x64dbg.com/)

Versões exatas, runtimes .NET e dependências Visual C++ serão fixados após a validação local. Não há fundamento para afirmar que instalar apenas a versão mais recente de cada componente resolverá requisitos de ferramentas antigas.

## 6. Preparação do workspace

Usar, por exemplo, `D:\Projetos\FIFA17-UI\` como pasta de desenvolvimento, separada da instalação do jogo. Esse caminho é apenas uma sugestão.

| Pasta ou arquivo | Conteúdo |
| --- | --- |
| `README.md` | Objetivo, estado atual e como reproduzir. |
| `AGENTS.md` | Regras para o agente e critérios de conclusão. |
| `docs/environment.md` | Jogo, ferramentas, hashes, caminhos e dependências. |
| `docs/ui-map.md` | Relação entre tela, recursos e dependências. |
| `docs/experiments.md` | Uma entrada por experimento. |
| `docs/test-results.md` | Matriz de testes e evidências. |
| `docs/next-session.md` | Último resultado e próximo passo. |
| `scripts/` | Inventário, validação e automações próprias. |
| `design/` | Especificação da tabela e fontes visuais. |
| `frosty-project/` | Projeto salvo pelo editor; registrar o formato real gerado. |
| `work/original/` | Exportações originais, imutáveis durante o experimento. |
| `work/modified/` | Recursos alterados. |
| `evidence/` | Capturas e logs. |
| `dist/` | Pacotes finais e manifesto. |

Excluir do Git a instalação do jogo, saves pessoais, caches, backups, grandes exportações e dependências baixadas. Versionar fontes próprias e documentação. Se o projeto Frosty for grande, armazená-lo separadamente e registrar seu hash e versão no Git.

## 7. Fase 0 — Validar a instalação e o Frosty

1. Registrar versão e hash SHA-256 de `FIFA17.exe`, idioma, resolução e forma de inicialização.
2. Confirmar abertura da tela candidata sem mods e salvar uma captura de referência.
3. Registrar versões e hashes dos pacotes Frosty utilizados.
4. Abrir o Editor, apontar para a instalação e aguardar a preparação inicial.
5. Confirmar que o catálogo pode ser explorado e que um projeto salva e reabre.
6. Preparar o Mod Manager e validar o fluxo de inicialização.
7. Aplicar, se necessário, uma alteração visual mínima em um recurso reconhecido apenas para comprovar o carregamento de mods.
8. Desativar o teste e confirmar retorno ao estado original.

**Passagem:** Editor e Manager funcionam na instalação, e a aplicação/remoção de um mod mínimo é reproduzível.

Se o jogo deixar de abrir, comparar com o lançamento original, coletar logs e isolar o problema. Não começar a editar layout enquanto o carregamento de mods estiver instável.

## 8. Fase 1 — Mapear a tela de estatísticas

### 8.1 Investigar os recursos expostos

Explorar tanto os recursos apresentados no catálogo principal quanto os recursos Legacy disponíveis nessa edição do Frosty. Não presumir que toda a interface esteja em uma única categoria.

Usar como pistas termos associados à função da tela, por exemplo `ui`, `frontend`, `career`, `stats`, `statistics`, `table`, `leaderboard` e textos realmente vistos no jogo. São termos de busca, não nomes de arquivos confirmados.

Para cada candidato, registrar:

- Nome e identificador apresentados pelo editor.
- Tipo do recurso, caminho exportado e hash original.
- Referências ou dependências expostas.
- Motivo da hipótese de ligação com a tela.
- Se há visualizador, edição de propriedades, exportação e reimportação.
- Se o recurso parece compartilhado com outras telas.

### 8.2 Separar as responsabilidades da tela

| Parte | Pergunta a responder |
| --- | --- |
| Geometria | Onde se definem posição, tamanho, ancoragem e recorte? |
| Aparência | Quais recursos controlam fonte, cores, divisórias e seleção? |
| Dados | Como os valores chegam às linhas e colunas? |
| Interação | Onde ficam foco, rolagem, abas e ações de retorno? |
| Localização | Como títulos e nomes são associados aos textos traduzidos? |

Exportar poucos candidatos por vez. O fato de um arquivo conter a palavra de um cabeçalho não prova que controle seu layout.

**Passagem:** identificar um candidato estrutural e uma rota concreta para salvá-lo e aplicá-lo. Se não for encontrado, registrar o que foi excluído e investigar o leitor correspondente no código da ferramenta.

## 9. Fase 2 — Prova estrutural mínima

### Experimento A: ida e volta sem alteração

Exportar e reimportar um recurso candidato, gerar o mod, fechar/reabrir o projeto e aplicar pelo Manager. Verificar se a tela continua íntegra. Comparar conteúdo decodificado quando disponível; diferenças binárias podem decorrer de reserialização e precisam ser explicadas.

### Experimento B: uma mudança de layout

Escolher uma propriedade identificada e executar uma única mudança reversível: deslocar um cabeçalho, ajustar a largura de uma coluna ou a altura de uma linha. Não editar offsets binários sem entender o campo e seus limites.

Aplicar o mod, abrir o mesmo save/contexto, capturar o resultado e testar foco, rolagem e retorno. Restaurar o valor original e confirmar a reversão.

### Experimento C: dados e reutilização

Abrir a tabela em outro contexto ou atualizar o save de teste para verificar que os valores continuam dinâmicos. Visitar outras telas que compartilhem o componente, quando identificadas.

**Marco de viabilidade:** a mudança estrutural aparece dentro do FIFA 17, sobrevive ao reinício e não rompe a associação entre dados, seleção e colunas.

Um pacote exportado sem erros não comprova esse marco. A evidência precisa vir do jogo.

## 10. Fase 3 — Especificar a modernização

Após a prova, desenhar uma proposta limitada aos controles e propriedades encontrados.

| Elemento | Direção de design |
| --- | --- |
| Cabeçalho | Hierarquia clara, alinhamento com as colunas e contraste suficiente. |
| Nomes | Prioridade de espaço para jogadores/equipes e tratamento consistente de nomes longos. |
| Números | Alinhamento consistente que facilite comparar valores. |
| Linhas | Espaçamento uniforme e separação discreta. |
| Seleção | Destaque legível sem ocultar textos ou valores. |
| Área útil | Distribuição mais eficiente, respeitando recorte e rolagem nativos. |
| Abas e ajuda de botões | Preservar visibilidade e comportamento existentes. |

Definir medidas a partir da captura e das coordenadas reais do recurso. Evitar dimensionar o mockup como se fosse HTML/CSS: a interface precisa respeitar a representação efetiva do jogo.

**Entregável:** especificação visual com estado normal, seleção, lista rolada e nomes longos, além de capturas de referência.

## 11. Fase 4 — Implementar e automatizar

1. Implementar por componente: cabeçalho, colunas, linhas e seleção.
2. Salvar uma versão funcional antes de cada nova alteração.
3. Criar scripts para tarefas repetidas que a investigação tenha confirmado.
4. Validar a entrada de cada script: hash/versão esperados, estrutura e destino.
5. Produzir o projeto Frosty e o pacote exportado correspondente.
6. Aplicar apenas esse mod durante a validação inicial.
7. Registrar conflitos potenciais com recursos compartilhados.

Se for necessário ampliar uma ferramenta, começar com um leitor e comparação de resultados. Só escrever o recurso após compreender tamanhos, referências e demais campos relevantes. Criar testes de leitura/escrita para esse código, inclusive rejeição de entrada incompatível.

O repositório do fork expõe componentes como `FrostySdk`, `Plugins` e `FrostyCmd`. Eles são pontos de investigação; sua presença não significa que exista um comando pronto para automatizar o fluxo necessário. Verificar a implementação antes de propor uma CLI. [2]

Se houver distribuição de alterações de ferramentas de terceiros, conferir a licença da revisão utilizada antes de empacotá-las. Disponibilidade pública de código não implica permissão irrestrita de redistribuição.

## 12. Fase 5 — Testar e entregar

| Teste | Critério de aprovação |
| --- | --- |
| Carregamento | Jogo abre e a tela funciona com o mod ativo. |
| Layout | A mudança estrutural é visível e corresponde à especificação. |
| Valores | Nomes, números e cabeçalhos correspondem ao estado original no mesmo contexto. |
| Atualização | A tabela continua refletindo mudanças reais de contexto/dados. |
| Seleção | O destaque acompanha a linha correta. |
| Rolagem | Primeira, intermediária e última posição da lista funcionam. |
| Navegação | Entrada, abas existentes e retorno não prendem o usuário na tela. |
| Entradas | Controle e teclado funcionam conforme o suporte original. |
| Textos | Acentos, nomes longos e valores maiores não se sobrepõem. |
| Resolução | Resolução principal e segunda resolução escolhida funcionam. |
| Reutilização | Telas com o mesmo componente não apresentam regressões observadas. |
| Reinício | Resultado persiste após fechar e abrir jogo e Manager. |
| Desempenho | Não há novos travamentos; investigar e medir qualquer regressão observada. |
| Reversão | Remover/desativar o mod recupera o comportamento original. |

Registrar teste, versão, resultado e evidência. Marcar como não executado o que não foi verificado.

**Pacote de entrega:** mod no formato gerado pelo editor validado, projeto editável, fontes próprias, manifesto de recursos, versões compatíveis, guia de instalação/remoção, resultados dos testes e capturas antes/depois. Não incluir a instalação completa do jogo.

## 13. Diagnóstico de falhas

| Sintoma | Próxima investigação |
| --- | --- |
| Manager inicia, mas o jogo não abre | Comparar lançamento original, versões, caminhos e logs; resolver antes de editar novos recursos. |
| Mod aplica, mas nada muda | Confirmar recurso e estado da tela, projeto exportado, mod ativo e outros mods; só depois investigar cache. |
| Imagem muda, mas posição não | A alteração pode atingir apenas aparência; procurar recurso estrutural ou regra de layout. |
| Mudança funciona até reabrir o projeto | Investigar serialização/persistência no editor e comparar o conteúdo salvo. |
| Texto recorta ou seleção fica deslocada | Verificar limites de recorte, áreas de foco e geometria compartilhada. |
| Outra tela quebra | Mapear o uso comum do recurso; limitar a mudança ou avaliar duplicação apenas se as referências puderem ser redirecionadas. |
| Reimportar o original já quebra | Tratar suporte do formato como bloqueio e analisar o gravador da ferramenta. |

Não usar limpeza indiscriminada de caches como primeira resposta. Registrar qual cache pertence à ferramenta, seu propósito e como será recriado antes de qualquer remoção.

## 14. Backlog e marcos

| ID | Tarefa | Evidência de conclusão |
| --- | --- | --- |
| F17-01 | Inventário e baseline | Versões, hashes e captura original. |
| F17-02 | Validar Editor e Manager | Projeto reabre; mod mínimo aplica e é removido. |
| F17-03 | Mapear tela | Candidatos, referências e formatos documentados. |
| F17-04 | Validar reimportação | Tela íntegra após ida e volta do recurso. |
| F17-05 | Provar layout | Alteração estrutural no jogo e reversão confirmadas. |
| F17-06 | Especificar design | Estados e medidas definidos com base no suporte real. |
| F17-07 | Implementar MVP | Tabela modernizada com dados corretos. |
| F17-08 | Validar | Matriz de testes preenchida. |
| F17-09 | Empacotar | Mod, projeto, fontes e guias correspondentes. |

**Orçamento inicial proposto:** duas a quatro sessões de 1–2 horas para preparar o ambiente e investigar a viabilidade. Esse intervalo é um ponto de revisão de estratégia, não uma promessa de encontrar o formato ou concluir o mod.

Após F17-05, estimar o restante com base no tempo real de cada ciclo de edição e teste. Se for necessário engenharia reversa de um formato ou de código nativo, abrir uma tarefa própria; a duração pode ser muito maior e o resultado permanece incerto.

## 15. Uso do Codex com GPT-6 Sol médio

Usar tarefas pequenas, evidência explícita e checkpoints. O plano não depende de uma promessa de capacidade específica do modelo.

- Uma hipótese e uma alteração por experimento.
- Distinguir descoberta confirmada, inferência e tentativa ainda não testada.
- Não inventar propriedades, formatos, comandos ou suporte da ferramenta.
- Não confundir salvar o arquivo com validar o resultado no FIFA 17.
- Manter `docs/next-session.md` atualizado para retomar sem repetir a pesquisa.
- Se houver duas ou três tentativas sem nova evidência, revisar a hipótese antes de insistir.
- Aumentar esforço ou consultar outro modelo para um bloqueio delimitado, levando amostras, logs e o que já foi descartado.

### Modelo de registro de experimento

```text
ID:
Hipótese:
Versão do jogo / editor / manager:
Recurso e hash original:
Alteração única:
Resultado esperado:
Passos de aplicação e reprodução:
Resultado observado:
Evidência:
Restauração confirmada:
Conclusão e próximo passo:
```

## 16. Prompt para iniciar o projeto no Codex CLI

```text
Vamos desenvolver um mod de interface nativa exclusivamente para FIFA 17 PC.
Leia Planejamento_Mod_Interface_FIFA_17.md e o AGENTS.md, se existir.

Objetivo: modernizar uma tabela de estatísticas com alteração estrutural de
layout, mantendo os dados dinâmicos e a navegação original. Trocar apenas
uma textura ou construir um overlay não atende ao objetivo.

Comece por F17-01 e F17-02. Identifique caminhos, versão do FIFA17.exe,
Frosty Editor e Mod Manager, launcher, idioma, resolução e mods existentes.
Não presuma caminhos nem dependências. Separe originais e área de trabalho.

Depois, investigue os recursos da tela escolhida, incluindo o catálogo
principal e recursos Legacy disponíveis. Documente candidatos, referências,
formatos e operações de exportação/importação realmente suportadas.
Não presuma XML, Lua, SWF, HTML ou outro formato para a interface.

Valide exportação/reimportação sem mudança antes de alterar estrutura.
Proponha e execute o menor experimento reversível que comprove uma mudança
real, como largura de coluna ou posição de cabeçalho. Preserve campos e
valores. Não avance ao redesign sem evidência no jogo.

Use o código das ferramentas quando ajudar a resolver um bloqueio concreto.
Não misture binários de versões diferentes e não invente comandos de CLI.
Se depender de um passo gráfico ou teste manual, forneça os passos exatos
e a evidência necessária. Continue as tarefas independentes possíveis.

Registre descobertas, arquivos alterados, resultados e próximo passo em docs/.
Uma tarefa só estará validada no jogo quando houver teste correspondente.
```

## 17. Fontes e limites

Fontes consultadas em 13/10/2026:

1. [Release Frosty Toolsuite — FIFA 17 edition 2.0](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition/releases/tag/newrelease): referência para seleção da edição específica e funcionalidades anunciadas.
2. [Repositório Frosty Toolsuite — FIFA 17 edition](https://github.com/sadistaaa14-sketch/Frosty-Toolsuite-FIFA-17-edition): estrutura do código e instruções de compilação a validar contra a revisão utilizada.
3. [Tópico do desenvolvedor no Soccer Gaming](https://soccergaming.com/forums/threads/frosty-editor-fifa-17-edition-2-0-released-mesh-importion-support-unlimited-real-faces-in-the-game-sound-editing-and-more.6475801/): explicações e discussão técnica sobre a edição.

As etapas, critérios de aceitação e orçamento de investigação são propostas para este projeto. Nenhuma fonte consultada comprova, por si só, que a tabela desejada pode ter seu layout alterado. Essa confirmação é o propósito de F17-03 a F17-05.
