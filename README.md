# Dev Environment Guide (VS Code Dev Container + Docker Compose)

이 저장소는 데이터 파이프라인 개발용 기본 스택을 제공합니다.

## 구성 요소

- Redpanda (Kafka 호환 브로커)
- Vector
- Debezium Connect
- Debezium UI
- PostgreSQL (소스 DB)

## 사전 요구사항

- Docker Engine
- Docker Compose v2
- VS Code
- VS Code Dev Containers extension
- 인터넷 연결 (Docker image pull)

## 빠른 시작

1. 환경 변수 파일 준비

```bash
cp .env.example .env
```

2. 기본 서비스 기동

```bash
docker compose up -d
```

3. VS Code에서 `Reopen in Container`

## 환경 변수 설명

- `REDPANDA_KAFKA_PORT` (기본: `19092`)
- `DEBEZIUM_CONNECT_PORT` (기본: `8083`)
- `DEBEZIUM_UI_PORT` (기본: `8080`)
- `POSTGRES_PORT` (기본: `5432`)
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- `DEBEZIUM_CONNECT_IMAGE`
- `DEBEZIUM_UI_IMAGE`

## 기본 서비스 엔드포인트

- Redpanda Kafka: `localhost:${REDPANDA_KAFKA_PORT:-19092}`
- Redpanda Admin: `localhost:9644`
- Debezium Connect API: `localhost:${DEBEZIUM_CONNECT_PORT:-8083}`
- Debezium UI: `localhost:${DEBEZIUM_UI_PORT:-8080}`
- PostgreSQL: `localhost:${POSTGRES_PORT:-5432}`

## 동작 검증

1. Compose 상태 확인

```bash
docker compose ps
```

2. Debezium Connect API 확인

```bash
curl -s http://localhost:${DEBEZIUM_CONNECT_PORT:-8083}/connectors
```

3. PostgreSQL 샘플 데이터 확인

```bash
psql "postgresql://${POSTGRES_USER:-debezium}:${POSTGRES_PASSWORD:-debezium}@localhost:${POSTGRES_PORT:-5432}/${POSTGRES_DB:-inventory}" -c "SELECT * FROM inventory.customers;"
```

4. Vector -> Redpanda 토픽 확인 (`kcat` 필요)

```bash
kcat -b localhost:${REDPANDA_KAFKA_PORT:-19092} -t ${REDPANDA_TOPIC_VECTOR:-vector.logs} -C -o -5 -e
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

## 트러블슈팅

### 1) Dev Container에서 docker 명령이 실패하는 경우

- `/var/run/docker.sock` 마운트 상태 확인
- Docker daemon 상태 확인

### 2) 포트 충돌 의심 시

```bash
docker compose ps
```

### 3) 이미지 pull 실패/네트워크 이슈

- 사내 프록시/방화벽 정책 점검
- Docker Hub/Quay 접근 가능 여부 확인
