# Cenário 05 (incidente): Aplicação não conecta na instância nomeada

## Contexto

> **Chamado #1042:** "A aplicação nova aponta para `SEUSERVIDOR\INST02` e dá erro ao abrir a conexão. No SSMS do servidor funciona, mas da máquina do desenvolvedor não."

Na sua máquina o SQL Server Browser está **desabilitado** desde a instalação, então você provavelmente já tem o problema montado.

## Preparação

1. Na `INST02`, deixe o protocolo TCP/IP habilitado com **porta dinâmica**, que é o padrão de instância nomeada.
2. Simule o "cliente remoto" conectando por TCP explícito, em vez de memória compartilhada:
   ```
   sqlcmd -S tcp:SEUSERVIDOR\INST02 -E -C
   ```

## Tarefas

1. **Diagnóstico**
   - Reproduza o erro e anote o número e a mensagem. Pesquise o que significam os erros 26 e 40 do cliente.
   - Descubra a porta dinâmica que a `INST02` está usando de três formas: ERRORLOG, `sys.dm_exec_connections` e `netstat -ano` combinado com o PID do serviço.
   - Conecte informando a porta (`tcp:SEUSERVIDOR,porta`). Por que funciona?
2. **Correção A: porta fixa**
   - Configure uma porta fixa, por exemplo 14330, no *SQL Server Configuration Manager* e reinicie o serviço.
   - Crie a regra de entrada no Firewall do Windows para essa porta (`New-NetFirewallRule`).
   - Conecte com `tcp:SEUSERVIDOR,14330`.
3. **Correção B: SQL Server Browser**
   - Habilite e inicie o Browser e conecte pelo nome `SEUSERVIDOR\INST02`.
   - Qual porta UDP o Browser usa?
   - Volte o Browser para desabilitado ao final e registre qual das duas correções você recomendaria e por quê.
4. **Alias de cliente**
   - Crie um alias (ex.: `SQLAPP`) apontando para a `INST02` com a porta fixa e conecte usando só `SQLAPP`.

## Entregáveis

- `Respostas/cenario-05.ps1`: comandos de diagnóstico, firewall e testes.
- `Runbooks/incidente-conectividade.md`: árvore de diagnóstico ("o erro é X → verifique Y") para os próximos chamados.

## Para pesquisar

- Diferença entre os protocolos *Shared Memory*, *Named Pipes* e *TCP/IP*.
- O que `Encrypt` e `TrustServerCertificate` fazem nas conexões e por que o `sqlcmd` recente exige `-C` em servidores com certificado autoassinado.
