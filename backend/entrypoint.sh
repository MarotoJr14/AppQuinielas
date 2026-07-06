#!/bin/sh
set -e

echo "Esperando a que la base de datos esté disponible..."
python - << 'PYEOF'
import time
import sys
import psycopg
from app.core.config import settings

for i in range(30):
    try:
        conn = psycopg.connect(settings.PSYCOPG_DATABASE_URL)
        conn.close()
        print("Base de datos disponible.")
        sys.exit(0)
    except Exception as e:
        print(f"Intento {i+1}/30: {e}")
        time.sleep(2)
print("No se pudo conectar a la base de datos.")
sys.exit(1)
PYEOF

echo "Aplicando migraciones..."
alembic upgrade head

echo "Arrancando servidor..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
