# Bitácora · Taller IaC con Terraform · Grupo N

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

### Evidencias
- Salida del primer `docker run`:
```
```
- Error del segundo `docker run` (mismo nombre):
```
```
- Resultado con `clickops-gN-2` y el mismo puerto:
```
```
- `docker ps -a` después de limpiar:
```
```

**Objetivo en forma imperativa (pasos en orden):**
1.
2.
3.

**Objetivo en forma declarativa (una frase):**

### Respuestas
1. ¿Qué error produjo el segundo `docker run`? ¿Qué dice sobre la idempotencia de un comando imperativo?
2. Si otro grupo necesitara mañana un servidor idéntico, ¿qué tendrían que contarle y dónde quedó registrado?
3. ¿Cuáles de los cuatro puntos de «Por qué duele» vivieron en esta fase?

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
