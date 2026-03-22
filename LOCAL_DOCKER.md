# Local Docker debug

1. Optional: copy env file if you want custom values:

```bash
cp .env.docker.example .env.docker
```

2. Build and run:

```bash
set -a; [ -f .env.docker ] && source .env.docker; set +a; docker compose up --build
```

3. Open app:

`http://localhost:8080`

4. Follow app logs:

```bash
docker compose logs -f app
```

5. Tear down:

```bash
docker compose down
```

6. Tear down and remove volumes:

```bash
docker compose down -v
```
