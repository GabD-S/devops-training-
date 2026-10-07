# devops-training

Repositório do treinamento hands-on de **Kubernetes + GitOps** da Switch Dreams (Aula 1).

Cada dupla sobe um cluster local com **kind**, instala **Argo CD**, **ingress-nginx** e o operator do **CloudNativePG**, e implanta uma app Rails (lista de tarefas) com Postgres, **somente via Git**.

> Regra do dia: **só o Git escreve; o `kubectl` é para ler.**

## Estrutura

```
devops-training/
├── kind-config.yaml             # cluster local (portas 80/443 expostas)
├── apps/
│   └── treino-rails.yaml        # Application do Argo CD (aponta para os manifests)
├── manifests/treino-rails/      # Manifests puros da app (sem Helm)
│   ├── deployment.yaml          # app + initContainer de migração
│   ├── service.yaml
│   ├── ingress.yaml             # host app.localtest.me
│   └── postgres.yaml            # Cluster do CNPG
├── rails-app/                   # código da app (Rails 8 + Postgres) e Dockerfile
├── scripts/
│   ├── install-infra.sh         # instala Argo CD, ingress-nginx e CNPG (plano B)
│   └── sabotar.sh               # injeta falhas para o bloco de diagnóstico
└── .github/workflows/image.yml  # publica a imagem no GHCR (só no repo do instrutor)
```

## Para os participantes

Pré-requisitos: Docker (com 6 GB de RAM ou mais), `kind`, `kubectl`, `git` e conta no GitHub. As portas 80 e 443 da máquina precisam estar livres.

1. Clique em **Use this template** para criar o **seu** repositório (público).
2. Clone e crie o cluster: `kind create cluster --name treino --config kind-config.yaml`.
3. Em `apps/treino-rails.yaml`, troque `<SEU-USUARIO>` pelo seu usuário do GitHub.
4. Siga o roteiro da aula.

Resultado esperado: `http://app.localtest.me` abre a lista de tarefas, a Application aparece **Synced + Healthy** no Argo CD e as tarefas sobrevivem a apagar o Pod da app.

`localtest.me` e seus subdomínios resolvem para `127.0.0.1`, então não é preciso editar o `/etc/hosts`.

## Para o instrutor

### Publicar a imagem

O chart usa `ghcr.io/switchdreams/devops-training:1.0.0`. Para a imagem existir:

1. Crie a tag: `git tag v1.0.0 && git push origin v1.0.0` (e `v1.1.0` para o exercício de troca de versão). O workflow **Publicar imagem** constrói para amd64 e arm64 e faz o push no GHCR. O build com QEMU leva alguns minutos.
2. No GitHub, em **Packages**, torne o pacote **público** e confirme que está ligado a este repositório. Sem isso o kind não consegue baixar a imagem.
3. Em **Settings**, marque este repositório como **Template repository** e deixe-o **público** (o Argo CD lê o Git sem credenciais).

A versão e o nome do Pod aparecem no rodapé da app (`APP_VERSION` vem do build, `HOSTNAME` do Kubernetes), o que torna visíveis o rolling update e o balanceamento entre réplicas.

### Antes da aula

- Fixar as versões em `scripts/install-infra.sh` (ingress-nginx e CNPG estão com versões de exemplo).
- Fazer um **ensaio completo e cronometrado** com alguém que não seja de DevOps.
- Abrir o pacote da imagem como público e testar o pull a partir de um kind limpo.

### Como a app se conecta ao banco

O `database.yml` de produção lê `RAILS_DATABASE_HOST` e `RAILS_APP_DATABASE_PASSWORD`, com banco `rails_app_production` e usuário `rails_app`. O `Cluster` do CNPG cria exatamente esse banco/usuário (`bootstrap.initdb`) e gera o Secret `treino-postgres-app`, de onde o Deployment lê `host` e `password`. Não há senha de banco no Git.

### Diferenças da app em relação ao scaffold original

- `config/environments/production.rb`: `force_ssl` e `assume_ssl` só ligam com `FORCE_SSL=true`. Sem TLS, o cookie de sessão sairia como `Secure` e seria descartado pelo navegador em HTTP, causando erro 422 (CSRF) ao criar uma tarefa.
- Rodapé com versão e Pod no layout; `APP_VERSION` no Dockerfile.

## Produção real

Esta aula é uma simplificação. Em produção há registry privado, tag por hash de commit, SealedSecrets, TLS com cert-manager, DNS real, hub-and-spoke e backup do banco. Veja o repositório `switch-deployment`.
