# Cenário 04 (incidente): Cadeia de backup quebrada

## Contexto

> **Chamado #1230:** "Precisamos restaurar o `BibliotecaLab` para ontem às 18h, mas o restore do diferencial falha com erro de base. Ninguém mexeu nos jobs de backup."

Ninguém mexeu nos jobs, mas alguém fez um backup "rápido" para levar uma cópia para o notebook, e outra pessoa "resolveu" um log cheio trocando o recovery model.

## Preparação (em `BibliotecaLab_C04`)

Execute em ordem, com carga entre cada passo:

1. Backup full na pasta oficial.
2. Dois backups de log.
3. Um backup full **ad hoc** numa pasta temporária, **sem** `COPY_ONLY`. Depois apague o arquivo, simulando a cópia levada para o notebook.
4. Mais um backup de log e um diferencial na pasta oficial.
5. `ALTER DATABASE ... SET RECOVERY SIMPLE`, alguma carga, e de volta para `FULL`.
6. Mais dois backups de log.

## Tarefas

1. **Investigação**
   - Usando a consulta de cadeia do cenário 01, reconstrua a linha do tempo. Encontre:
     - qual backup "roubou" a base do diferencial (`differential_base_lsn`);
     - onde está o buraco na cadeia de log (`first_lsn` de um backup diferente do `last_lsn` do anterior).
   - Procure no ERRORLOG e em `msdb.dbo.backupset` quem fez o backup ad hoc (usuário e máquina).
2. **Quais pontos no tempo ainda são recuperáveis?**
   - Teste e documente quais pontos você consegue restaurar com os arquivos que sobraram:
     - antes do passo 3;
     - entre os passos 3 e 5;
     - depois do passo 5.
   - O backup full ad hoc quebra a cadeia de **log**? E a de **diferenciais**? Prove com restores.
3. **Correção**
   - O que precisa ser feito imediatamente depois da troca de recovery model para a cadeia voltar a existir?
4. **Prevenção**
   - Escreva uma consulta de monitoramento que detecte: banco em `FULL` sem backup de log há mais de 1 hora; banco sem full há mais de 8 dias; backup feito fora da pasta oficial ou sem `COPY_ONLY`.

## Entregáveis

- `Runbooks/incidente-cadeia-quebrada.md`, com a linha do tempo reconstruída.
- `Respostas/cenario-04.sql`, com a consulta de monitoramento (ela vira alerta na Fase07).

## Para pesquisar

- Como as ferramentas de backup de terceiros (agentes de VM, por exemplo) podem quebrar a sua cadeia sem você perceber.
