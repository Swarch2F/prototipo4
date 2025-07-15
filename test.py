import psycopg2

# Configuración de las bases de datos con las credenciales corregidas
dbs = [
    {
        "nombre": "authdb",
        "host": "bh4bhaewrpd8qqcreso5-postgresql.services.clever-cloud.com",
        "dbname": "bh4bhaewrpd8qqcreso5",
        "user": "uo8h6cfqdm4u5xv6lfqq",
        "port": 5432,
        "password": "dsJBQr44561wnu9YizPLTeP1GFh0eO"
    },
    {
        "nombre": "sia_colegios",
        "host": "bsbw9dp2f3op72g15kex-postgresql.services.clever-cloud.com",
        "dbname": "bsbw9dp2f3op72g15kex",
        "user": "uqk2fld6uttfdd7auvj5",
        "port": 5432,
        "password": "iDbHihYT1wr6W4cbd0RaZ3rJ2TMyz8"
    }
]

def probar_permisos_y_tablas(dbconf):
    print(f"\nConectando a la base de datos: {dbconf['nombre']}")
    try:
        conn = psycopg2.connect(
            host=dbconf["host"],
            dbname=dbconf["dbname"],
            user=dbconf["user"],
            port=dbconf["port"],
            password=dbconf["password"]
        )
        conn.autocommit = True
        cur = conn.cursor()

        # Listar tablas
        print("Tablas existentes:")
        cur.execute("""
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_type='BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema')
            ORDER BY table_schema, table_name;
        """)
        tablas = cur.fetchall()
        if tablas:
            for schema, tabla in tablas:
                print(f"  {schema}.{tabla}")
        else:
            print("  No hay tablas en la base de datos.")

        # Probar permisos: crear tabla temporal
        try:
            cur.execute("CREATE TABLE IF NOT EXISTS test_permiso (id SERIAL PRIMARY KEY, dato TEXT);")
            print("✅ Permiso para crear tablas: OK")
        except Exception as e:
            print(f"❌ No se pudo crear tabla: {e}")

        # Probar permisos: insertar
        try:
            cur.execute("INSERT INTO test_permiso (dato) VALUES ('prueba');")
            print("✅ Permiso para insertar datos: OK")
        except Exception as e:
            print(f"❌ No se pudo insertar datos: {e}")

        # Probar permisos: leer
        try:
            cur.execute("SELECT * FROM test_permiso;")
            rows = cur.fetchall()
            print(f"✅ Permiso para leer datos: OK ({len(rows)} filas leídas): {rows}")
        except Exception as e:
            print(f"❌ No se pudo leer datos: {e}")

        # Probar permisos: actualizar
        try:
            cur.execute("UPDATE test_permiso SET dato='modificado' WHERE dato='prueba';")
            print("✅ Permiso para actualizar datos: OK")
        except Exception as e:
            print(f"❌ No se pudo actualizar datos: {e}")

        # Probar permisos: borrar
        try:
            cur.execute("DELETE FROM test_permiso WHERE dato='modificado';")
            print("✅ Permiso para borrar datos: OK")
        except Exception as e:
            print(f"❌ No se pudo borrar datos: {e}")

        # Probar permisos: crear índice
        try:
            cur.execute("CREATE INDEX test_permiso_idx ON test_permiso(dato);")
            print("✅ Permiso para crear índices: OK")
        except Exception as e:
            print(f"❌ No se pudo crear índice: {e}")

        # Limpiar tabla de prueba
        try:
            cur.execute("DROP TABLE IF EXISTS test_permiso;")
        except:
            pass

        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error al conectar o ejecutar en la base de datos {dbconf['nombre']}: {e}")

if __name__ == "__main__":
    print("=== Script de prueba de permisos y tablas en PostgreSQL ===")
    for db in dbs:
        probar_permisos_y_tablas(db)
