# Cenário 03: Segunda instância por instalação desassistida

## Contexto

A empresa vai padronizar a instalação de novos servidores. Nada de clicar "Avançar" no assistente: toda instância nova deve sair de um arquivo de configuração versionado no Git, para que todas fiquem idênticas.

Essa nova instância, `INST02`, também será o seu "servidor de testes" para os cenários destrutivos e, na Fase03, o destino dos restores.

## Tarefas

1. **Gerar o arquivo de configuração**
   - Rode o assistente de instalação até a tela *Ready to Install*, copie o caminho do `ConfigurationFile.ini` gerado e **cancele** a instalação.
   - Edite o arquivo para a instância nomeada `INST02` com:
     - apenas os recursos `SQLENGINE` e `REPLICATION`;
     - pastas separadas para dados, log, tempdb e backup (ex.: `C:\SQLData\INST02\Data`, `...\Log`, `...\TempDB`, `...\Backup`);
     - contas virtuais (`NT Service\MSSQL$INST02`) para o motor e o Agent;
     - Agent com início **automático**;
     - autenticação Windows apenas;
     - seu usuário Windows como sysadmin;
     - 4 arquivos de tempdb de 64 MB, crescimento de 64 MB;
     - `SQLSVCINSTANTFILEINIT="True"`.
2. **Instalar pela linha de comando**
   - `setup.exe /ConfigurationFile=... /IAcceptSQLServerLicenseTerms /QS`.
   - Aplique a mesma CU do cenário 02 também pela linha de comando.
3. **Validar**
   - Conecte com `sqlcmd -S .\INST02 -E` e confirme versão, collation, caminhos padrão e arquivos do tempdb.
   - Rode o script de inventário do cenário 01 nas duas instâncias e compare as diferenças.

## Entregáveis

- `Respostas/INST02-ConfigurationFile.ini`: sem nenhuma senha. Se alguma for necessária, use um parâmetro na linha de comando, nunca o arquivo versionado.
- `Respostas/cenario-03.ps1`: os comandos de instalação, patch e validação.
- `Runbooks/inventario-INST02.md`.

## Para pesquisar

- O que é uma conta virtual (*virtual account*) e por que é preferível a `LocalSystem`.
- A collation do servidor pode ser mudada depois da instalação? O que isso envolve?
- Diferença entre instância default e nomeada no nome dos serviços e na forma de conectar.
