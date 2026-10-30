# Fase08: Alta disponibilidade e replicação

**Status:** não iniciada.

## Temas previstos

- Log shipping.
- Replicação: snapshot, transacional e merge; distribuidor, publicador e assinante; monitoramento e latência.
- Always On Availability Groups: réplicas, modos de sincronismo, failover, listener, réplicas de leitura.
- Failover Cluster Instance (FCI): conceitos.
- Comparação entre as soluções: RPO, RTO, custo e edição necessária.

## Limitação do laboratório

Log shipping e replicação funcionam entre a instância default e a `INST02` na mesma máquina. Já um Availability Group "de verdade" precisa de um Windows Server Failover Cluster com duas ou mais VMs, o que não cabe em 7,7 GB de RAM. Antes desta fase, avalie: ampliar a memória, usar VMs temporárias na nuvem ou montar um AG sem cluster (*read-scale*) apenas para estudo.
