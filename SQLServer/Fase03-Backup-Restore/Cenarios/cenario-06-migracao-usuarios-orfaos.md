# Cenário 06: Migrando um banco para outra instância

## Contexto

O `BibliotecaLab` vai sair da instância default e passar para a `INST02`, com a menor parada possível. A aplicação usa um login SQL; os relatórios usam um grupo do Windows.

## Preparação (na instância default)

1. Crie no `BibliotecaLab` os acessos:
   - login SQL `app_biblioteca`, com usuário no banco, membro de `db_datareader` e `db_datawriter`;
   - login Windows (o seu usuário ou um usuário local criado para o teste), com usuário de leitura;
   - uma role de banco `rl_relatorios` com `SELECT` em um schema.
2. Crie um job do Agent que dependa do banco (por exemplo, um que grave uma linha por minuto numa tabela de auditoria).

## Tarefas

1. **Migração com parada mínima**
   - Planeje e execute: backup full com a aplicação ainda no ar → restore `NORECOVERY` na `INST02` → diferencial ou logs → parada da carga → tail-log → restore final `WITH RECOVERY`.
   - Meça o tempo de parada real, do fim da carga ao banco disponível na `INST02`.
2. **Usuários órfãos**
   - Na `INST02`, tente conectar com `app_biblioteca`. Diagnostique com `sys.database_principals` × `sys.server_principals`, comparando os SIDs.
   - Corrija de duas formas:
     - `ALTER USER ... WITH LOGIN = ...`;
     - recriando o login com o **mesmo SID** (pesquise `sp_help_revlogin` ou use `Copy-DbaLogin`).
   - Qual das duas é a correta para uma migração definitiva, e por quê?
3. **O que o backup não leva**
   - Liste tudo o que ficou para trás e migre: logins, jobs, operadores, linked servers, credenciais, configurações de instância.
4. **Pós-migração**
   - Ajuste o compatibility level (se fosse uma migração de versão), o owner do banco, e rode `CHECKDB` e uma atualização de estatísticas.
   - Coloque o banco original em `READ_ONLY` ou `OFFLINE`, e não o apague por alguns dias.

## Entregáveis

- `Runbooks/migracao-entre-instancias.md`: checklist de antes, durante e depois.
- `Respostas/cenario-06.sql` e `.ps1`.

## Para pesquisar

- Por que o owner do banco volta como o usuário que fez o restore, e qual o risco disso.
- `Start-DbaMigration` do dbatools: o que ele faz, e por que entender o processo manual antes de usá-lo.
