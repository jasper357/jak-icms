# Dev Environment (VS Code Dev Container + Docker Compose)

이 저장소는 VS Code Dev Container와 Docker Compose를 이용해 아래 구성요소를 개발환경으로 제공합니다.

- Redpanda
- Vector
- Debezium Connect
- Debezium UI
- PostgreSQL 소스 DB

## 요구사항

- Docker Engine
- Docker Compose v2
- VS Code + Dev Containers 확장

## 빠른 시작

1. 환경 변수 파일 준비

```bash
cp .env.example .env
```

2. 기본 서비스 기동 (Redpanda + Vector + Debezium + PostgreSQL)

```bash
docker compose up -d
```

3. VS Code에서 `Reopen in Container` 실행

선택: 필요 시 오버레이 파일(`docker-compose.source-db.yml`)을 별도 실험용으로 함께 사용할 수 있습니다.

## Dev Container 기본 확장

- `ms-azuretools.vscode-docker`
- `redhat.vscode-yaml`
- `zainchen.json`
- `eamodio.gitlens`
- `mhutchie.git-graph`
- `GitHub.vscode-pull-request-github`
- `OpenAI.chatgpt`

`Reopen in Container` 이후 위 확장이 자동 설치됩니다.

## 서비스 엔드포인트

- Redpanda Kafka (host): `localhost:${REDPANDA_KAFKA_PORT:-19092}`
- Redpanda Admin API: `localhost:9644`
- Debezium Connect API: `localhost:${DEBEZIUM_CONNECT_PORT:-8083}`
- Debezium UI: `localhost:${DEBEZIUM_UI_PORT:-8080}`
- PostgreSQL: `localhost:${POSTGRES_PORT:-5432}`

## 동작 검증

1. 컨테이너 상태 확인

```bash
docker compose ps
```

2. Debezium Connect 확인

```bash
curl -s http://localhost:${DEBEZIUM_CONNECT_PORT:-8083}/connectors
```

3. Vector 로그가 Redpanda 토픽으로 들어오는지 확인 (`kcat` 필요)

```bash
kcat -b localhost:${REDPANDA_KAFKA_PORT:-19092} -t ${REDPANDA_TOPIC_VECTOR:-vector.logs} -C -o -5 -e
```

4. VS Code 확장 확인

- `OpenAI.chatgpt`
- `GitHub.vscode-pull-request-github`
- `mhutchie.git-graph`

5. PostgreSQL 샘플 데이터 확인

```bash
psql "postgresql://${POSTGRES_USER:-debezium}:${POSTGRES_PASSWORD:-debezium}@localhost:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-inventory}" -c "SELECT * FROM inventory.customers;"
```

## Debezium Connector 등록 예시

```bash
curl -X POST http://localhost:${DEBEZIUM_CONNECT_PORT:-8083}/connectors \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "inventory-connector",
    "config": {
      "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
      "database.hostname": "postgres",
      "database.port": "5432",
      "database.user": "debezium",
      "database.password": "debezium",
      "database.dbname": "inventory",
      "database.server.name": "inventory",
      "topic.prefix": "inventory",
      "schema.include.list": "inventory",
      "table.include.list": "inventory.customers",
      "plugin.name": "pgoutput"
    }
  }'
```

## 종료

```bash
docker compose down
```
