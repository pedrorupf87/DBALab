# Cenário 04: Baseline de configuração

## Contexto

As duas instâncias rodam com os padrões de instalação, e muitos deles não servem para produção. Com apenas 7,7 GB de RAM para Windows, ferramentas e duas instâncias, a configuração de memória deixou de ser detalhe: se as duas instâncias disputarem memória sem limite, a máquina inteira fica lenta.

## Tarefas

1. **Definir a baseline**
   - Para cada item abaixo, escreva o valor escolhido e a justificativa:
     - `max server memory (MB)` de cada instância. Faça a conta: quanto reservar para o Windows e o VS Code, quanto para a default e quanto para a `INST02`?
     - `min server memory (MB)`;
     - `max degree of parallelism` (12 núcleos lógicos: qual NUMA e quantos núcleos físicos?);
     - `cost threshold for parallelism`;
     - `optimize for ad hoc workloads`;
     - `backup compression default` e `backup checksum default`;
     - `remote admin connections` (DAC);
     - número e tamanho dos arquivos do tempdb;
     - crescimento automático dos arquivos do `model`, que é o modelo de todo banco novo.
2. **Script idempotente**
   - Escreva um script que aplique a baseline usando `sp_configure` e `ALTER DATABASE`. Ele só deve alterar o que estiver diferente e deve imprimir o que mudou.
   - Rode na default e na `INST02`. Rode de novo e confirme que nada é alterado na segunda vez.
3. **SQL Server Agent**
   - Na instância default, mude o Agent para início automático e inicie o serviço. Ele será necessário na Fase03.
4. **Permissões do Windows**
   - Verifique se a conta de serviço tem *Perform volume maintenance tasks* (IFI) e avalie se faz sentido conceder *Lock pages in memory* nesta máquina.
   - Confirme o plano de energia do Windows (`powercfg /getactivescheme`).

## Entregáveis

- `Respostas/cenario-04-baseline.sql`: script idempotente.
- `Runbooks/baseline-configuracao.md`: tabela com item, valor, justificativa e fonte consultada.

## Para pesquisar

- O que o `max server memory` limita e o que fica fora dele.
- Contenção de alocação no tempdb (PFS/GAM/SGAM) e o motivo de vários arquivos de mesmo tamanho.
- Por que o valor padrão 5 do `cost threshold for parallelism` é considerado ultrapassado.
