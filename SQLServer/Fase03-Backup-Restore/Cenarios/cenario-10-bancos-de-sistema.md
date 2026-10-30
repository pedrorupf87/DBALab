# Cenário 10 (incidente): Perdemos o master

> **Somente na `INST02`.** Antes de começar, confirme que você tem backups de `master`, `msdb` e `model` da `INST02` e que **consegue lê-los** (`RESTORE HEADERONLY`).

## Contexto

> **Chamado #1290:** "Depois de uma intervenção no servidor, a instância `INST02` sobe, mas todos os logins, jobs e bancos de usuário sumiram. Parece uma instância recém-instalada."

Os bancos de sistema guardam a "identidade" da instância: `master` tem logins, configurações e a lista de bancos; `msdb` tem jobs, histórico de backup e alertas; `model` é o molde de todo banco novo.

## Preparação

1. Na `INST02`, crie um login de teste, um job e um banco pequeno, e faça backup de `master`, `msdb` e `model`.
2. Crie **depois** do backup mais um login, `login_pos_backup`.
3. Simule a perda: pesquise como **reconstruir os bancos de sistema** pelo setup (`setup.exe /ACTION=REBUILDDATABASE ...`) e execute na `INST02`.

## Tarefas

1. **Restaurar o master**
   - Inicie a `INST02` em modo single user (`-m`), restaure o `master` a partir do backup e observe: a instância desliga sozinha ao final. Por quê?
   - Suba normalmente e confira logins e configurações. O `login_pos_backup` existe? E o banco de usuário: aparece na lista? Em que estado?
2. **Restaurar o msdb**
   - Com o Agent **parado**, restaure o `msdb`. Confira jobs e histórico de backup.
3. **Bancos de usuário**
   - Se os arquivos `.mdf`/`.ldf` do banco de usuário ainda existem na pasta, o que é necessário para ele voltar: restore ou só `ONLINE`/attach?
4. **Rotina**
   - Garanta que `master` e `msdb` estão na rotina de backup do cenário 07 com a frequência adequada. O `model` também? E o `tempdb`?

## Entregáveis

- `Runbooks/restore-bancos-de-sistema.md`: ordem (master → msdb → model → bancos de usuário), modo de inicialização de cada etapa e o que conferir no fim.
- `Respostas/cenario-10.ps1` e `.sql`.

## Para pesquisar

- O que acontece ao restaurar um `master` de outra versão ou de outra CU.
- O banco `mssqlsystemresource` (*Resource database*): por que ele não aparece em `sys.databases` e não é copiado por backup.
