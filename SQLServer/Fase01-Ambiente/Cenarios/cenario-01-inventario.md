# Cenário 01: Inventário da instância

## Contexto

Você acaba de assumir a administração de um servidor que ninguém documentou. Antes de mudar qualquer coisa, precisa saber exatamente o que está instalado e como está configurado.

## Tarefas

1. Escreva um script T-SQL que retorne, em um único resultado ou em poucos:
   - nome do servidor e da instância, versão, edição, nível de produto e CU (`SERVERPROPERTY`);
   - collation do servidor;
   - núcleos, memória física e memória visível ao SQL Server (`sys.dm_os_sys_info`);
   - contas de serviço, tipo de início e se o *Instant File Initialization* está habilitado (`sys.dm_server_services`);
   - caminhos padrão de dados, log e backup (`SERVERPROPERTY('InstanceDefaultDataPath')` e similares);
   - porta TCP em uso (`sys.dm_exec_connections` ou o log de erros);
   - valores atuais de `sp_configure` que **diferem do padrão** de instalação.
2. Liste todos os bancos com: tamanho de dados e log, recovery model, compatibility level, owner, collation, `page_verify_option` e data do último backup full (`msdb.dbo.backupset`).
3. Leia o *ERRORLOG* atual (`sp_readerrorlog` ou `xp_readerrorlog`) e anote as mensagens de inicialização que você não entende.
4. Pela linha de comando, confirme a mesma versão com `sqlcmd` e liste os serviços SQL com `Get-Service`.
5. Consulte a lista de builds do SQL Server 2022 e descubra quantas CUs a sua instância está atrasada.

## Entregáveis

- `Respostas/cenario-01.sql`: script de inventário reutilizável.
- `Runbooks/inventario-MSSQLSERVER.md`: ficha da instância (versão, configuração, bancos, observações do ERRORLOG). Ela será atualizada ao fim da Fase01.

## Para pesquisar

- O que significa cada valor de `page_verify_option` e qual deveria ser o padrão.
- Por que o owner dos bancos importa e por que se recomenda `sa` (ou um login desabilitado) como owner.
- Onde fica fisicamente o arquivo ERRORLOG e quantos arquivos são mantidos.
