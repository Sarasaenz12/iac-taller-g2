# Bitácora · Taller IaC con Terraform · Grupo 2

**Curso:** Arquitectura de Software II · 2026-2
**Integrantes:** Sara Valentina Sanchez Estrada · Juanjo · Laura

## Rotación de roles

Con 3 integrantes, Navegante y Bitácora los asume la misma persona.

| Fase  | Operador/a | Navegante + Bitácora | Revisor/a del plan |
|-------|------------|----------------------|--------------------|
| 0 y 1 | Sara       | Juanjo               | Laura              |
| 2     | Juanjo     | Laura                | Sara               |
| 3     | Laura      | Sara                 | Juanjo             |
| 4     | Sara       | Juanjo               | Laura              |
| 5     | Juanjo     | Laura                | Sara               |
| 6     | Laura      | Sara                 | Juanjo             |
| 7     | Sara       | Juanjo               | Laura              |
| 8     | Juanjo     | Laura                | Sara               |
| 9     | Laura      | Sara                 | Juanjo             |

---

## Fase 0 · Preparación del entorno

**Roles en esta fase:** Operadora: Sara · Navegante y Bitácora: Juanjo · Revisora del plan: Laura

### Evidencias

**1. Verificación de herramientas**

`terraform -version`
```
Terraform v1.17.0
on windows_amd64
```
Cumple el mínimo de la guía (1.6) y la versión recomendada (1.17 o posterior).

`docker version`
```
Client:
 Version:           28.0.1
 API version:       1.48
 Go version:        go1.23.6
 Git commit:        068a01e
 Built:             Wed Feb 26 10:41:52 2025
 OS/Arch:           windows/amd64
 Context:           desktop-linux

Server: Docker Desktop 4.39.0 (184744)
 Engine:
  Version:          28.0.1
  API version:      1.48 (minimum version 1.24)
  Go version:       go1.23.6
  Git commit:       bbd0a17
  Built:            Wed Feb 26 10:41:16 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.7.25
  GitCommit:        bcc810d6b9066471b0b6fa75f557a15a1cbf31bb
 runc:
  Version:          1.2.4
  GitCommit:        v1.2.4-0-g6c52b3f
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```
Aparecen las secciones Client y Server, así que el motor de Docker está corriendo.

`git --version`
```
git version 2.56.0.windows.4
```

**2. Imágenes del taller descargadas**

```
$ docker pull nginx:1.27-alpine
Status: Downloaded newer image for nginx:1.27-alpine
docker.io/library/nginx:1.27-alpine

$ docker pull nginx:1.28-alpine
Status: Downloaded newer image for nginx:1.28-alpine
docker.io/library/nginx:1.28-alpine
```

`docker images | grep -E "REPOSITORY|nginx|postgres"`
```
REPOSITORY   TAG           IMAGE ID       CREATED          SIZE
postgres     17-alpine     aac5ed9e090c   4 days ago       297MB
nginx        latest        936fef290c8f   5 months ago     161MB
postgres     16-alpine     fff3594bf464   5 months ago     276MB
nginx        1.28-alpine   dc73b49f5124   7 months ago     62.1MB
postgres     16            05c1acb89ae4   11 months ago    451MB
postgres     15-alpine     acc286cc12c5   18 months ago    273MB
postgres     15            075d2bd86e2e   18 months ago    430MB
nginx        1.27-alpine   6769dc3a703c   19 months ago    48.2MB
```
Las tres imágenes que pide la guía están disponibles: `nginx:1.27-alpine`, `nginx:1.28-alpine` y `postgres:17-alpine`.

**3. Sin contenedores corriendo antes de empezar** (para evitar conflictos de puertos)

`docker ps`
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### Respuestas
No aplica (fase de preparación).

---

## Fase 1 · Arranque: hacerlo a mano

**Roles en esta fase:** Operadora: Sara · Navegante y Bitácora: Juanjo · Revisora: Laura

### Evidencias

**1. Servidor creado de forma imperativa**
```
$ docker run -d --name clickops-g2 -p 8090:80 nginx:1.27-alpine
7d77e9ef777d9dc7d3c52d058747544ba7c74f2a2baa9066ae48a5f48fda03de
```
En http://localhost:8090 apareció la página de bienvenida de nginx.

**2a. Repetir exactamente el mismo comando**
```
$ docker run -d --name clickops-g2 -p 8090:80 nginx:1.27-alpine
44f3bb2e25dd9f30e027fa96e8875373db9f38d24eab3e66c7251e204c7bbe6d

$ docker run -d --name clickops-g2 -p 8090:80 nginx:1.27-alpine
docker: Error response from daemon: Conflict. The container name "/clickops-g2" is already in use by container "44f3bb2e25dd9f30e027fa96e8875373db9f38d24eab3e66c7251e204c7bbe6d". You have to remove (or rename) that container to be able to reuse that name.

Run 'docker run --help' for more information

$ docker rm -f clickops-g2
clickops-g2
```

**2b. Otro nombre (`clickops-g2-2`) con el mismo puerto**
```
$ docker run -d --name clickops-g2-2 -p 8090:80 nginx:1.27-alpine
750e16cfed92fc792a829122d86b240dadf744d1d7462763cfd13cf8d24e0681
docker: Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint clickops-g2-2 (aa7d69b7f447ccd6a3229f7ab447b66acd9a4bc2b0ded1517bec112ec31dddf7): Bind for 0.0.0.0:8090 failed: port is already allocated
```
Docker alcanzó a crear el contenedor (devolvió un ID), pero no pudo arrancarlo porque el puerto 8090 ya estaba ocupado por `clickops-g2`. Quedó un contenedor a medio hacer que hubo que borrar a mano.

**3. Limpieza**
```
$ docker rm -f clickops-g2 clickops-g2-2
clickops-g2
clickops-g2-2
```

**Punto de control:** `docker ps -a` ya no muestra ningún contenedor `clickops`.
```
$ docker ps -a | grep clickops

$
```
El comando no devolvió ninguna línea: no queda ningún contenedor `clickops`.

**4. El mismo objetivo de dos formas**

*Imperativa (pasos en orden):*
1. Descargar la imagen `nginx:1.27-alpine` si no existe.
2. Crear un contenedor llamado `clickops-g2` a partir de esa imagen.
3. Publicar el puerto 80 del contenedor en el puerto 8090 del computador.
4. Arrancar el contenedor en segundo plano.
5. Abrir http://localhost:8090 y comprobar que responde.

*Declarativa (una frase):*
> Debe existir un único contenedor `clickops-g2`, corriendo con `nginx:1.27-alpine`, que sirva la página de nginx en el puerto 8090.

### Respuestas

**1. ¿Qué error produjo el segundo `docker run`? ¿Qué dice eso sobre la idempotencia de un comando imperativo?**

Docker respondió `Conflict. The container name "/clickops-g2" is already in use`: el nombre `clickops-g2` ya estaba en uso por otro contenedor y había que borrarlo o renombrarlo para reutilizarlo. Un comando imperativo no es idempotente: describe una acción ("crea un contenedor"), no un resultado, así que no revisa si lo que pedimos ya existe. La primera vez funciona, la segunda falla con exactamente la misma instrucción. Y cuando cambiamos solo el nombre fue peor: el contenedor `clickops-g2-2` sí se creó pero no arrancó por el puerto ocupado, y quedó un estado intermedio que nadie pidió. Para usar el comando de forma segura, la persona tiene que verificar a mano el estado antes de ejecutarlo.

**2. Si otro grupo necesitara mañana un servidor idéntico, ¿qué tendrían que contarle y dónde quedó registrado lo que hicieron?**

Tendríamos que contarle el comando exacto: la imagen y su versión (`nginx:1.27-alpine`), el nombre del contenedor, el mapeo de puertos (8090 → 80) y que corre en segundo plano, además de advertirle que el puerto y el nombre no pueden estar en uso. Lo que hicimos no quedó registrado en ningún sitio que se pueda reutilizar: solo en el historial de la terminal de un computador y en esta bitácora, que escribimos a mano. Es justo el problema de «el conocimiento se va con la persona». No hay un archivo versionado que el otro grupo pueda ejecutar para obtener el mismo resultado; depende de la memoria y de copiar bien cada parámetro.

**3. ¿Cuáles de los cuatro puntos de la diapositiva «Por qué duele» vivieron en esta fase?**

Vivimos los cuatro:
- **Lento y propenso a errores humanos:** al reutilizar el puerto 8090 con otro nombre cometimos un error que dejó el contenedor `clickops-g2-2` creado pero sin arrancar, y tuvimos que limpiarlo a mano.
- **Imposible de reproducir igual dos veces:** el mismo `docker run` funcionó la primera vez y falló la segunda; el resultado depende de lo que ya exista en la máquina.
- **Sin historial: nadie sabe quién cambió qué:** nada registra quién creó o borró los contenedores ni cuándo; solo lo sabemos porque lo anotamos a mano en esta bitácora.
- **El conocimiento se va con la persona:** la configuración (imagen, puerto, nombre) solo la conoce quien escribió el comando; si esa persona no está, el resto del grupo tendría que adivinarla.

---

## Fase 2 · Primer despliegue

### Evidencias
- `terraform init`, `terraform validate`, `terraform plan` (línea `Plan:`), aprobación del revisor, `terraform apply`, `terraform output`, `docker ps`, `git status`.

### Respuestas
1.
2.
3.
4.
5.

---

## Fase 3 · Idempotencia y estado

### Evidencias
- Segundo `apply`, `state list`, `state show`, `serial` antes/después, plan con `-/+`.

### Respuestas
1.
2.
3.
4.
5.

---

## Fase 4 · Drift

### Evidencias

| Experimento | ¿El plan lo detectó? | ¿Qué propuso Terraform? | ¿Cómo quedó corregido? |
|---|---|---|---|
| A · Apagar | | | |
| B · Borrar | | | |
| C · Cambiar por dentro | | | |

### Respuestas
1.
2.
3.

---

## Fase 5 · Flexibilidad

### Evidencias
### Respuestas
1.
2.
3.
4.

---

## Fase 6 · Módulos

### Evidencias
### Respuestas
1.
2.
3.
4.

---

## Fase 7 · State remoto y ambientes

> ⚠️ Nunca pegar aquí la contraseña del backend ni el valor de PG_CONN_STR.

### Evidencias
### Respuestas
1.
2.
3.
4.
5.
6.

---

## Fase 8 · Testing y calidad

### Evidencias
### Respuestas
1.
2.
3.
4.
5.

---

## Fase 9 · Auditoría cruzada y cierre

### Evidencias
### Respuestas
1.
2.
3.
