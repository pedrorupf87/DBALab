# Cenário 06 (incidente): A instância não sobe

> **Somente na `INST02`.** Faça backup de `master` e `msdb` da `INST02` antes de começar.

## Contexto

> **Chamado #1077 (madrugada):** "O servidor reiniciou após uma manutenção de storage e o SQL Server não inicia mais. O serviço sobe e cai em seguida."

Neste cenário você provoca duas falhas diferentes e recupera a instância sem reinstalar nada.

## Parte A: tempdb num caminho que deixou de existir

1. **Preparação**
   - Mova os arquivos do tempdb para uma pasta nova (`ALTER DATABASE tempdb MODIFY FILE ...`), por exemplo `C:\SQLData\INST02\TempDB2`.
   - Pare o serviço, **apague a pasta** `TempDB2` e tente iniciar o serviço.
2. **Diagnóstico**
   - O serviço não inicia. Encontre a causa sem abrir o SSMS: Visualizador de Eventos do Windows e o arquivo ERRORLOG direto na pasta `Log` da instância.
3. **Recuperação**
   - Inicie a instância em modo de configuração mínima pela linha de comando. Pesquise `sqlservr.exe -f`, `-m` e o trace flag 3608.
   - Corrija o caminho do tempdb, reinicie normalmente e confirme os arquivos em `sys.master_files`.

## Parte B: memória configurada errada

1. **Preparação**
   - Configure `max server memory` da `INST02` para **128 MB** e reinicie.
2. **Diagnóstico**
   - Tente conectar pelo SSMS, abrir o Object Explorer e rodar consultas. O que acontece?
   - Verifique o ERRORLOG.
3. **Recuperação**
   - Use a conexão administrativa dedicada (`sqlcmd -S admin:.\INST02 -E`) ou o modo `-f` para voltar o valor ao definido na baseline do cenário 04.

## Entregáveis

- `Runbooks/incidente-instancia-nao-sobe.md`: onde olhar primeiro (Event Viewer, ERRORLOG, permissões de pasta, conta de serviço), como subir em modo mínimo e como sair dele.
- `Respostas/cenario-06.ps1`.

## Para pesquisar

- Outras causas comuns de serviço que não sobe: senha da conta de serviço alterada, permissão negada na pasta de dados, `master` corrompido, porta em uso.
- Diferença entre `-m` (single user) e `-f` (configuração mínima), e como restringir o single user a um aplicativo (`-m"SQLCMD"`).
- Onde o caminho do `master` fica gravado e como alterá-lo (*startup parameters* `-d`, `-l`, `-e`).
