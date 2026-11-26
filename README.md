# POI — Kubernetes

Provisionamento de um cluster Kubernetes com Minikube na nuvem OpenStack do LSD/UFCG, juntamente do deploy de três mini APIs FastAPI (CPU-bound, Memory-bound e I/O-bound).

## Ambiente

- VM: `vm-k8s-grupo25`, Ubuntu Server 24.04.3 LTS, flavor `general.large` (4 vCPUs, 8 GiB de RAM, 20 GB de disco).
- IP privado utilizado: `10.5.11.243`.
- Docker Engine 29.10.1; Minikube v1.39.0; Kubernetes e kubectl v1.37.0; runtime containerd 2.3.4.
- Load Balancer compartilhado: `poi-atividades`, IP público `150.165.85.77`.

## Aplicações

Código e Dockerfiles [aqui](https://github.com/mathensley/virtualbox_test/tree/atividade4-docker-grupo25).

| Aplicação | Imagem Docker Hub | Porta pública | Porta VM/Service/Pod | NodePort |
| --- | --- | ---: | ---: | ---: |
| CPU | `mathensley/poi-cpu-grupo25:1.0` | 8025 | 8001 | 30081 |
| Memory | `mathensley/poi-memory-grupo25:1.0` | 8125 | 8002 | 30082 |
| I/O | `mathensley/poi-io-grupo25:1.0` | 8225 | 8003 | 30083 |

Cada aplicação possui um Deployment com uma réplica, um Service NodePort, requests e limits de recursos e probes HTTP no endpoint `/health`. As portas privadas da VM são publicadas pelo Docker para as NodePorts do Minikube.

## Deploy e testes das aplicações

Os scripts deste repositório partem de uma VM já provisionada no OpenStack, com Docker instalado e Minikube em execução. Para testar pelo IP privado, as portas 8001–8003 da VM devem estar publicadas para as NodePorts correspondentes e acessíveis a partir da máquina que executa o teste. Para testar pelo IP público, o Load Balancer deve encaminhar as portas públicas para essas mesmas portas da VM, conforme a tabela acima.

1. Na VM, com o contexto `minikube` ativo no `kubectl`, execute na raiz do repositório:

   ```bash
   bash scripts/deploy-apps.sh
   ```

   O script valida os manifestos em `k8s/` no servidor antes de aplicá-los, aguarda a conclusão do rollout dos três Deployments e lista os recursos resultantes. Pode ser executado novamente para aplicar alterações nos manifestos.

2. Na VM ou em outra máquina com acesso ao IP privado dela, execute o teste local com `curl` disponível. Substitua `IP_PRIVADO_DA_VM` pelo IP privado da VM:

   ```bash
   bash scripts/test-apps.sh local IP_PRIVADO_DA_VM
   ```

3. Em uma máquina com `curl` e acesso ao Load Balancer, execute o teste externo. Por padrão, o script usa o IP público `150.165.85.77`:

   ```bash
   bash scripts/test-apps.sh external
   ```

Em ambos os modos, o script consulta o endpoint `/health` e o endpoint funcional de cada uma das três APIs.

## Validação remota

- CPU: `http://150.165.85.77:8025/cpu?n=100000`
- Memory: `http://150.165.85.77:8125/memory?mb=50&hold_ms=1000`
- I/O: `http://150.165.85.77:8225/io?mb=20`

Os três endpoints funcionais retornaram HTTP 200 nos testes. Os três Deployments estavam disponíveis e os Pods em execução, sem reinicializações, na verificação final. As URLs dependem da disponibilidade da infraestrutura do laboratório.
