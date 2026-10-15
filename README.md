# FIFA 17 UI Mod Lab

Pesquisa e desenvolvimento de um mod para modernizar a tela nativa **Player Stats** do modo Carreira no FIFA 17 para PC, preservando os dados, a navegação, a seleção e a rolagem.

## Estado atual

O projeto está em investigação técnica. A tela e o recurso Legacy `data/ui/game/screens/career/Stats/LeagueStats.big` foram identificados; leituras parciais do DAT/APT localizaram cabeçalhos e referências a componentes de linhas e rolagem.

O pacote `LeagueStatsRoundtrip` é somente um experimento de ida e volta e apresentou uma regressão: os dados da tabela desaparecem com o pacote ativo e retornam sem ele. **Não é uma versão de mod pronta para uso ou distribuição.** A reconstrução BIG foi validada estaticamente contra o parser local do plugin; a integração do Collector e a saída aplicada pelo Manager ainda precisam ser investigadas.

## Estrutura versionada

- `Planejamento_Mod_Interface_FIFA_17.md`: escopo e critérios do projeto FIFA 17.
- `Planejamento_Mod_Interface_FIFA_16_17.md`: planejamento histórico, mantido como referência.
- `docs/`: auditoria do ambiente, revisão documental e estado de prontidão.
- `scripts/`: leitores e verificadores locais, somente leitura.

Instalações do jogo e do Frosty, saves, capturas de tela, projetos, mods exportados e membros DAT/APT ficam fora do Git. Os scripts que dependem desses arquivos só funcionarão quando os dados e ferramentas forem obtidos localmente de uma instalação própria do jogo.

## Diagnósticos locais

Na raiz do projeto:

```powershell
python .\scripts\inspect-leaguestats.py
pwsh -NoProfile -File .\scripts\inspect-legacy-plugin-il.ps1
```

O leitor APT espera `work/original/leaguestats.DAT` e `work/original/leaguestats.APT`. O inspetor FBMOD requer o caminho para a instalação local do Frosty e para o pacote de teste; consulte `docs/documentation-review.md` para o estado validado e as limitações. Os scripts analisam entradas conhecidas e não substituem uma validação no jogo.

## Conteúdo e distribuição

Este repositório não inclui executáveis do jogo/Frosty, saves, recursos originais do jogo nem o pacote de teste. O código e os documentos deste repositório estão sob a licença MIT; ela não inclui nem concede direitos sobre o jogo, marcas ou recursos de terceiros. FIFA é uma marca de seus respectivos titulares; este é um projeto de modificação independente.
