# Cenário 07: Automação com dbatools

## Contexto

Você agora administra duas instâncias e repetiu várias tarefas à mão em cada uma. Em empresas com dezenas de instâncias, isso é feito com PowerShell. O módulo **dbatools** é o padrão de mercado para isso.

## Tarefas

1. **Instalação**
   - Instale o módulo para o seu usuário (`Install-Module dbatools -Scope CurrentUser`).
   - Configure a confiança de certificado para o laboratório (pesquise `Set-DbatoolsInsecureConnection`) e entenda o que essa opção desliga.
2. **Inventário e verificação das duas instâncias de uma vez**
   - Use `Connect-DbaInstance` com `.` e `.\INST02`.
   - Compare os resultados abaixo com o que você levantou à mão nos cenários 01 e 04:
     - `Test-DbaBuild -Latest`
     - `Test-DbaMaxMemory`
     - `Test-DbaMaxDop`
     - `Test-DbaTempDbConfig`
     - `Get-DbaDatabase`
     - `Get-DbaLastBackup`
   - Alguma recomendação do dbatools diverge da sua baseline? Quem está certo, e por quê?
3. **Copiar objetos entre instâncias**
   - Crie na default um login SQL de teste e um job simples do Agent.
   - Copie-os para a `INST02` com `Copy-DbaLogin` e `Copy-DbaAgentJob`.
   - Copie o `Northwind` com `Copy-DbaDatabase -BackupRestore -SharedPath ...` e confirme que o login copiado mantém o mesmo **SID** nas duas instâncias.
4. **Relatório**
   - Monte um script que gere um CSV com instância, versão, edição, memória máxima, MAXDOP e quantidade de bancos das duas instâncias.

## Entregáveis

- `Respostas/cenario-07.ps1`.
- Atualize as fichas de inventário com o que o dbatools revelou e você não tinha visto.

## Para pesquisar

- Por que o SID do login importa ao mover bancos entre instâncias (é a base do cenário de usuários órfãos da Fase03).
- `Get-Help <comando> -Examples`: crie o hábito de ler os exemplos antes de usar um comando novo.
