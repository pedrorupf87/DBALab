# Fase00: T-SQL

Base de linguagem: consultas, DML, cursores, transações, tratamento de erros, SQL dinâmico, XML/JSON, funções de janela e CTEs.

## Conteúdo

| Lista | Banco | Exercícios | Status |
|---|---|---|---|
| [northwind-lista-01](Exercicios/Enunciados/northwind-lista-01.md) a [07](Exercicios/Enunciados/northwind-lista-07.md) | Northwind | 330 | Concluída |
| [adventureworks-lista-01](Exercicios/Enunciados/adventureworks-lista-01.md) e [02](Exercicios/Enunciados/adventureworks-lista-02.md) | AdventureWorks2022 | 194 | Concluída |
| [northwind-livro-sql-practice-problems](Exercicios/Enunciados/northwind-livro-sql-practice-problems.md) | Northwind | 57 | Concluída |
| [northwindlab-fechamento](Exercicios/Enunciados/northwindlab-fechamento.md) | NorthwindLab | 14 | A fazer |
| [bibliotecalab-fechamento](Exercicios/Enunciados/bibliotecalab-fechamento.md) | BibliotecaLab | 12 | A fazer |

## Fechamento

As duas listas de fechamento cobrem o que faltou nas anteriores:

- **NorthwindLab:** procedures, funções, views e triggers reais, escrevendo em tabelas reais. Inclui o padrão de tratamento de erros com `XACT_ABORT`/`THROW`, a medição de cursor vs. set-based e uma primeira visão de bloqueios e deadlocks.
- **BibliotecaLab:** modelagem, DDL, constraints e a carga de um banco com 2 milhões de empréstimos, que será reaproveitado nas Fases 02 e 03.
