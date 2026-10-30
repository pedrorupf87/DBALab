# Cenário 01: Estratégia de backup e anatomia de um backup

## Contexto

A diretoria da rede de bibliotecas definiu os requisitos do `BibliotecaLab`:

- **RPO** (perda máxima de dados aceitável): 15 minutos;
- **RTO** (tempo máximo até o sistema voltar): 1 hora;
- retenção: 7 dias em disco, mais um backup mensal guardado por 1 ano.

Os bancos `Northwind` e `AdventureWorks2022` são só de consulta e aceitam perder 24 horas.

## Tarefas

1. **Desenho da estratégia**
   - Para cada banco, defina recovery model, frequência de full, diferencial e log, e retenção. Justifique a partir do RPO e do RTO.
   - Estime o espaço em disco que a retenção vai consumir. Use o tamanho de um backup full comprimido e o volume de log gerado por hora (meça com uma carga simulada).
2. **Executando à mão**
   - Faça, no `BibliotecaLab`, a sequência: full → log → log → diferencial → log. Use `CHECKSUM` e `COMPRESSION` e gere carga entre os backups.
   - Para cada arquivo, rode `RESTORE HEADERONLY`, `RESTORE FILELISTONLY` e `RESTORE VERIFYONLY`.
3. **Lendo a cadeia no msdb**
   - Escreva uma consulta em `msdb.dbo.backupset` e `msdb.dbo.backupmediafamily` que mostre, para cada backup: tipo, início, fim, tamanho, tamanho comprimido, caminho, `first_lsn`, `last_lsn`, `database_backup_lsn` e `differential_base_lsn`.
   - Explique como os LSNs "encaixam" um backup de log no anterior e como o diferencial aponta para o seu full.
4. **Gerando o script de restore**
   - A partir dessa consulta, escreva uma procedure `dba.usp_GerarScriptRestore @Database, @StopAt` que monte o `RESTORE` completo (full + último diferencial + logs até `@StopAt`).
   - Ela será sua principal ferramenta nos próximos incidentes.

## Entregáveis

- `Runbooks/estrategia-backup.md`: tabela banco × recovery × agenda × retenção × RPO/RTO, com a estimativa de espaço.
- `Respostas/cenario-01.sql`, com a consulta de cadeia e a procedure.

## Para pesquisar

- `COPY_ONLY`: o que ele altera, e o que não altera, em backups full e de log.
- Por que `RESTORE VERIFYONLY` não garante que o restore vai funcionar.
- Backup para URL (Azure Blob Storage) como cópia fora do servidor.
