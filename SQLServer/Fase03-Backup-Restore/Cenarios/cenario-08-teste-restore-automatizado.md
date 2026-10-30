# Cenário 08: Teste de restore automatizado

## Contexto

A auditoria pergunta: "Qual foi a última vez que vocês **comprovaram** que os backups restauram?" A resposta tem de ser uma data recente, com evidência. Não "acho que funciona".

## Tarefas

1. **Teste com dbatools**
   - Use `Test-DbaLastBackup -SqlInstance . -Destination .\INST02` para restaurar os últimos backups de cada banco na `INST02`, rodar `CHECKDB` e apagar a cópia em seguida.
   - Leia o resultado: tempo de restore, resultado do `CHECKDB`, tamanho.
2. **Teste a partir só dos arquivos**
   - Simule a perda total do servidor: o `msdb` da default não está disponível, só a pasta de backups.
   - Use `Restore-DbaDatabase -Path C:\SQLBackup\...` na `INST02` para reconstruir o `BibliotecaLab` com base apenas nos arquivos. Ele precisa descobrir a cadeia sozinho, lendo os cabeçalhos.
3. **Automatização e evidência**
   - Agende o teste semanalmente: um job do Agent com etapa PowerShell, ou o Agendador de Tarefas do Windows.
   - Grave o resultado de cada teste numa tabela `DBAdmin.dbo.RestoreTestLog` (data, banco, arquivo usado, duração do restore, resultado do `CHECKDB`).
4. **RTO medido x RTO prometido**
   - Compare o tempo de restore medido com o RTO de 1 hora do cenário 01. Projete: com o banco 10 vezes maior, o RTO ainda seria cumprido? O que mudaria na estratégia?

## Entregáveis

- `Respostas/cenario-08.ps1`.
- `Runbooks/teste-restore.md`: como o teste funciona, onde ver as evidências e o que fazer quando ele falhar.

## Para pesquisar

- Por que restaurar numa instância diferente da de produção é parte do teste.
- Ferramentas que leem só os cabeçalhos dos backups e por que isso é essencial quando o `msdb` foi perdido junto com o servidor.
