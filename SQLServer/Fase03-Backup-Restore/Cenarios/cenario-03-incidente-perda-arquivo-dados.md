# Cenário 03 (incidente): O arquivo de dados sumiu

## Contexto

> **Chamado #1215:** "Houve falha no volume de dados. O arquivo `.mdf` do sistema foi perdido, mas o volume do log está intacto. A diretoria pergunta: perdemos alguma coisa?"

Com recovery `FULL` e o arquivo de log intacto, a resposta certa é **nenhuma transação confirmada**, desde que você faça o *tail-log backup* antes de qualquer outra ação.

## Preparação (em `BibliotecaLab_C03`)

1. Faça full, alguns backups de log e um diferencial, com carga entre eles.
2. Registre algumas transações **depois** do último backup de log e anote a última linha inserida. É ela que prova a perda zero.
3. Simule a falha: **pare o serviço** da instância, **renomeie** o arquivo `.mdf` (não apague; renomear permite voltar atrás se você errar) e inicie o serviço de novo. Se preferir não reiniciar a instância default, faça este cenário com a cópia restaurada na `INST02`.

## Tarefas

1. **Diagnóstico**
   - Qual é o estado do banco em `sys.databases`? Quais mensagens aparecem no ERRORLOG?
2. **Tail-log backup**
   - Faça o backup do final do log com o banco danificado. Pesquise a diferença entre `NO_TRUNCATE`, `NORECOVERY` e `CONTINUE_AFTER_ERROR` e escolha a opção correta.
3. **Restore com perda zero**
   - Restaure na sequência: full → diferencial → logs → tail-log, com `NORECOVERY` em todos menos o último.
   - Confirme que a última linha anotada na preparação existe.
4. **E se não houvesse o tail-log?**
   - Repita o cenário sem fazer o tail-log e meça exatamente o que se perde.
5. **Variação: o log se perdeu, não os dados**
   - Restaure de novo a cópia, pare o serviço e renomeie o `.ldf` em vez do `.mdf`.
   - O que acontece ao subir a instância? Com desligamento limpo, o SQL Server consegue reconstruir o log (pesquise `FOR ATTACH_REBUILD_LOG`)? E se houvesse transações em andamento?
   - Pesquise `ALTER DATABASE ... SET EMERGENCY` e por que ele é o último recurso.

## Entregáveis

- `Runbooks/incidente-perda-arquivo.md`: inclua um quadro "perdeu o `.mdf`" × "perdeu o `.ldf`" × "perdeu os dois", com o que é possível recuperar em cada caso.
- `Respostas/cenario-03.sql`.

## Para pesquisar

- Por que a regra "primeiro o tail-log, depois o restore" é tão repetida, e o que `WITH REPLACE` faz se você pular essa etapa.
