# Fase05: Performance e tuning

**Status:** não iniciada.

## Temas previstos

- Planos de execução (estimado x real), operadores, estimativas de cardinalidade.
- Estatísticas: criação, atualização, histograma.
- Índices: clustered, nonclustered, cobertura com `INCLUDE`, filtrados, columnstore; índices ausentes e não usados.
- Parameter sniffing e soluções.
- Query Store.
- Wait stats, DMVs, Extended Events.
- tempdb: contenção, spills, version store.
- Ferramentas da comunidade: `sp_WhoIsActive` e First Responder Kit (`sp_Blitz`, `sp_BlitzCache`, `sp_BlitzIndex`, `sp_BlitzFirst`).

## Banco de estudo

O Northwind e o AdventureWorks são pequenos demais para os problemas de desempenho aparecerem. Use o banco **StackOverflow** publicado por Brent Ozar (a versão 2010, de cerca de 10 GB, cabe nesta máquina) e o `BibliotecaLab`.
