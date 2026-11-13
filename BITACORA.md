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

## Fase 2 · Primer despliegue: write → init → plan → apply

**Roles en esta fase:** Operador: Juanjo · Navegante y Bitácora: Laura · Revisora del plan: Sara

### Evidencias

**1. write:** se creó `infra/main.tf` con el bloque `terraform`, el provider `docker`, los recursos `docker_image.nginx` y `docker_container.web` (nombre `web-g2`, puerto 8080 → 80) y el output `url`. En el provider se agregó `host = "npipe:////.//pipe//docker_engine"`, la solución que da la guía para Windows.

**2. init**
```
$ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 4.6"...
- Installing kreuzwerker/docker v4.6.0...
- Installed kreuzwerker/docker v4.6.0 (self-signed, key ID 0DCE698927DAF8EC)
Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://developer.hashicorp.com/terraform/cli/plugins/signing

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

Lo que apareció en la carpeta después del `init`:
```
$ ls -a
./  ../  .terraform/  .terraform.lock.hcl  main.tf
```

**3. Formato y sintaxis**
```
$ terraform fmt

$ terraform validate
Success! The configuration is valid.
```

**4. plan**
```
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.web will be created
  + resource "docker_container" "web" {
      + name         = "web-g2"
      + image        = (known after apply)
      + must_run     = true
      + network_mode = "bridge"
      + start        = true
      ...
      + ports {
          + external = 8080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = true
      + name         = "nginx:1.27-alpine"
      + repo_digest  = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + url = "http://localhost:8080"
```
(Se recortaron con `...` los atributos del contenedor que Terraform marca como `known after apply` o con su valor por defecto.)

**Aprobación de la revisora (Sara):** «Aprobado: 2 a crear, 0 a cambiar, 0 a destruir».

**5. apply**
```
$ terraform apply
...
Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.nginx: Creating...
docker_image.nginx: Creation complete after 3s [id=sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050eanginx:1.27-alpine]
docker_container.web: Creating...
docker_container.web: Creation complete after 2s [id=14949ea8f955b5c103fd7b25e99f51c74bc0f0ad6375c9715c3b2f88a03e861d]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

url = "http://localhost:8080"
```

**6. Verificación**
```
$ terraform output
url = "http://localhost:8080"

$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
14949ea8f955   6769dc3a703c   "/docker-entrypoint.…"   32 seconds ago   Up 31 seconds   0.0.0.0:8080->80/tcp   web-g2
```
En http://localhost:8080 apareció la página «Welcome to nginx!».

**Punto de control: qué entra a Git**
```
$ git status --short -uall
?? infra/.terraform.lock.hcl
?? infra/main.tf
```
Aunque en `infra/` existen `.terraform/` y `terraform.tfstate`, Git no los ve: los ignora el `.gitignore` (reglas `.terraform/` y `*.tfstate`).

### Respuestas

**1. Pidieron un solo servidor. ¿Cuántos recursos creó el plan y por qué?**

El plan creó 2 recursos: `docker_image.nginx` y `docker_container.web`. Aunque pedimos un solo servidor, en Terraform la imagen también es un recurso que se administra por separado: el contenedor no puede existir sin una imagen de la cual partir. Así Terraform sabe exactamente qué versión de imagen usa el servidor y puede reemplazarlo cuando la imagen cambie.

**2. El contenedor usa `docker_image.nginx.image_id`. ¿Qué orden de creación impone esa referencia? Relaciónenlo con la diapositiva «Qué ocurre cuando aplicas».**

La referencia crea una dependencia implícita: primero se crea la imagen y después el contenedor, porque el contenedor necesita el `image_id` que solo se conoce cuando la imagen existe (por eso el plan mostraba `image = (known after apply)`). El `apply` lo confirma: `docker_image.nginx: Creation complete` aparece antes de `docker_container.web: Creating...`. Esto ocurre en el paso 2 de la diapositiva, «Calcula el plan»: Terraform lee el código, arma el grafo de dependencias y decide el orden; luego, en el paso 3, «Llama al provider» en ese orden, y Docker (paso 4) responde con los datos como el `image_id` y el `id` del contenedor.

**3. ¿Qué descargó `terraform init`, dónde lo guardó y para qué sirve `.terraform.lock.hcl`?**

Descargó el provider `kreuzwerker/docker` versión 4.6.0, el plugin que traduce nuestro código a llamadas a la API de Docker. Lo guardó en la carpeta `.terraform/` dentro de `infra/`, que no se sube a Git porque se puede volver a descargar con `init`. El archivo `.terraform.lock.hcl` registra la versión exacta del provider elegida (4.6.0, dentro del rango `~> 4.6`) y sus firmas, para que todo el equipo y cualquier computador use exactamente la misma versión. Por eso sí se versiona.

**4. De los cuatro bloques de la diapositiva «Cómo se escribe Terraform», ¿cuál no aparece todavía en su archivo?**

Falta el bloque `variable`. Ya tenemos `provider` (docker), `resource` (la imagen y el contenedor) y `output` (`url`), pero valores como el nombre `web-g2` y el puerto 8080 están escritos fijos en el código. Las variables llegan en la Fase 5.

**5. Comparen con la Fase 1: ¿dónde quedó registrado ahora lo que hicieron?**

En la Fase 1 lo que hicimos solo quedó en el historial de la terminal y en esta bitácora. Ahora queda en `infra/main.tf`, un archivo de texto versionado en Git: cualquier persona del grupo, u otro grupo, puede leer qué servidor existe (imagen, nombre, puertos) y recrearlo idéntico con `terraform init` y `terraform apply`. Además, Terraform guarda en `terraform.tfstate` el registro de lo que realmente creó. Esto resuelve los problemas de la Fase 1: es repetible, tiene historial y el conocimiento ya no depende de una persona.

---

## Fase 3 · Idempotencia y estado

**Roles en esta fase:** Operadora: Laura · Navegante y Bitácora: Sara · Revisor del plan: Juanjo

### Evidencias

**1. Aplicar otra vez sin cambiar nada**
```
$ terraform apply
docker_image.nginx: Refreshing state... [id=sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050eanginx:1.27-alpine]
docker_container.web: Refreshing state... [id=14949ea8f955b5c103fd7b25e99f51c74bc0f0ad6375c9715c3b2f88a03e861d]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

url = "http://localhost:8080"
```

**2. Consultar el state con los comandos de Terraform**
```
$ terraform state list
docker_container.web
docker_image.nginx
```

```
$ terraform state show docker_container.web
# docker_container.web:
resource "docker_container" "web" {
    command     = [
        "nginx",
        "-g",
        "daemon off;",
    ]
    entrypoint  = [
        "/docker-entrypoint.sh",
    ]
    hostname    = "14949ea8f955"
    id          = "14949ea8f955b5c103fd7b25e99f51c74bc0f0ad6375c9715c3b2f88a03e861d"
    image       = "sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050ea"
    ipc_mode    = "private"
    log_driver  = "json-file"
    must_run    = true
    name        = "web-g2"
    network_data = [
        {
            gateway          = "172.17.0.1"
            ip_address       = "172.17.0.2"
            ip_prefix_length = 16
            mac_address      = "36:ef:4b:18:5c:81"
            network_name     = "bridge"
        },
    ]
    network_mode = "bridge"
    platform     = "linux"
    runtime      = "runc"
    shm_size     = 64
    stop_signal  = "SIGQUIT"
    working_dir  = "/"
    ...

    ports {
        external = 8080
        internal = 80
        ip       = "0.0.0.0"
        protocol = "tcp"
    }
}
```
(Se recortaron con `...` los atributos vacíos, en `false`, `0` o `null`.)

**3. Lectura de `terraform.tfstate` (solo lectura, sin editar)**
```
$ grep -E '"serial"|"lineage"' terraform.tfstate
  "serial": 4,
  "lineage": "511fc32e-a01c-f7ec-d783-417ef106caf2",
```
La lista `resources` tiene dos entradas, ambas de tipo `managed` y del provider `registry.terraform.io/kreuzwerker/docker`: `docker_image.nginx` y `docker_container.web`, cada una con una instancia. El archivo también guarda `terraform_version` (1.17.0) y el valor del output `url`.

**4. Cambio de versión de imagen:** en `main.tf` se reemplazó `nginx:1.27-alpine` por `nginx:1.28-alpine`.
```
$ terraform plan
...
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      ~ id    = "14949ea8f955b5c103fd7b25e99f51c74bc0f0ad6375c9715c3b2f88a03e861d" -> (known after apply)
      ~ image = "sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050ea" -> (known after apply) # forces replacement
        name  = "web-g2"
        ...
    }

  # docker_image.nginx must be replaced
-/+ resource "docker_image" "nginx" {
      ~ id           = "sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050eanginx:1.27-alpine" -> (known after apply)
      ~ image_id     = "sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050ea" -> (known after apply)
      ~ name         = "nginx:1.27-alpine" -> "nginx:1.28-alpine" # forces replacement
      ~ repo_digest  = "nginx@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10" -> (known after apply)
        # (1 unchanged attribute hidden)
    }

Plan: 2 to add, 0 to change, 2 to destroy.
```
(Del contenedor se dejaron solo los atributos clave; el resto de líneas pasan de su valor actual a `known after apply` o `null`.)

**Aprobación del revisor (Juanjo):** «Aprobado: 2 a crear, 0 a cambiar, 2 a destruir. Hay `-/+` y `forces replacement` en la imagen del contenedor y en el nombre de la imagen».

```
$ terraform apply
...
  Enter a value: yes

docker_container.web: Destroying... [id=14949ea8f955b5c103fd7b25e99f51c74bc0f0ad6375c9715c3b2f88a03e861d]
docker_container.web: Destruction complete after 1s
docker_image.nginx: Destroying... [id=sha256:6769dc3a703c719c1d2756bda113659be28ae16cf0da58dd5fd823d6b9a050eanginx:1.27-alpine]
docker_image.nginx: Destruction complete after 0s
docker_image.nginx: Creating...
docker_image.nginx: Creation complete after 0s [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
docker_container.web: Creating...
docker_container.web: Creation complete after 1s [id=6121722b6ee533e74568f949ecfa431c37b674638bb61f5564f163d01af3263c]

Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

url = "http://localhost:8080"
```

**5. Confirmar que todo quedó estable**
```
$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=6121722b6ee533e74568f949ecfa431c37b674638bb61f5564f163d01af3263c]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

```
$ grep -E '"serial"|"lineage"' terraform.tfstate
  "serial": 9,
  "lineage": "511fc32e-a01c-f7ec-d783-417ef106caf2",
```

### Respuestas

**1. ¿Qué respondió Terraform en el paso 1 y en qué se diferencia del segundo `docker run` de la Fase 1?**

Terraform respondió `No changes. Your infrastructure matches the configuration.` y terminó con `0 added, 0 changed, 0 destroyed`. Antes de decidir, refrescó el estado (`Refreshing state...`), comparó el código con lo que existe en Docker y, como ya coincidían, no hizo nada. En la Fase 1, el segundo `docker run` falló con `Conflict` porque el comando imperativo no revisa lo que ya existe: solo intenta crear. Esto es la idempotencia de la diapositiva: como el botón del ascensor ya pulsado, aplicar lo mismo dos veces no duplica el recurso y, si ya está correcto, no se toca.

**2. ¿Qué datos guarda el state que no escribieron en `main.tf`? ¿Para qué los necesita Terraform?**

En `main.tf` solo escribimos el nombre, la imagen y los puertos. El state además guarda el `id` real del contenedor en Docker, el `image_id` (el hash `sha256` de la imagen), el `repo_digest`, el `hostname`, la red asignada (IP `172.17.0.2`, gateway, MAC), el `command` y el `entrypoint` que trae la imagen, y valores por defecto como `restart = "no"`. También guarda metadatos propios: `serial`, `lineage` y la versión de Terraform. Terraform los necesita para relacionar cada bloque del código con el objeto real que creó (sin el `id` no sabría qué contenedor es `web-g2`) y para calcular el plan: compara lo que pedimos, lo que registró y lo que existe, como dice la diapositiva «El estado (state)».

**3. ¿Por qué el cambio de imagen reemplazó el contenedor en lugar de modificarlo? Relaciónenlo con «Infraestructura mutable vs. inmutable».**

Porque la imagen de un contenedor no se puede cambiar en sitio: un contenedor ya creado queda atado a la imagen de la que partió. El plan lo marcó con `-/+` y `# forces replacement` en el atributo `image`, y en el `apply` se ve el orden: destruir el contenedor viejo, reemplazar la imagen y crear un contenedor nuevo (con otro `id`). Es el enfoque inmutable de la diapositiva: no se entra a "curar" el servidor, se reemplaza completo, así todos los servidores con el mismo código son idénticos y reproducibles. El enfoque mutable sería entrar al contenedor y actualizar nginx a mano, que es justo lo que acumula cambios no documentados.

**4. ¿Cómo cambió `serial` después del `apply` y qué creen que representa?**

Pasó de 4 a 9, mientras que `lineage` se mantuvo igual (`511fc32e-...`). El `serial` es un contador de versiones del state: aumenta cada vez que Terraform escribe un cambio en el archivo. Subió 5 de una vez porque el reemplazo tuvo varios pasos (destruir contenedor, destruir imagen, crear imagen, crear contenedor) y Terraform va guardando el progreso. El `lineage` identifica la "familia" de este state: mientras sea el mismo, es la misma historia de infraestructura. Ambos sirven para evitar que alguien sobrescriba un state más nuevo con uno más viejo o con uno de otro proyecto.

**5. Piensen en un proyecto real con bases de datos: ¿qué riesgo habría si este archivo se subiera a Git?**

El state guarda en texto plano todos los atributos de los recursos, y en un proyecto real eso incluye contraseñas de bases de datos, cadenas de conexión, llaves de acceso, IPs internas y nombres de recursos. Si se sube a Git, cualquiera con acceso al repositorio los ve, y quedan en el historial aunque luego se borre el archivo. Además, si dos personas trabajan con copias del state desde Git, se desincronizan y una puede sobrescribir los cambios de la otra o hacer que Terraform intente recrear o borrar recursos que sí existen. Es el anti-patrón «State sin proteger» y por eso lo excluimos desde la Fase 0 con `*.tfstate` en el `.gitignore`.

---

## Fase 4 · Drift: cuando la realidad se desvía

**Roles en esta fase:** Operadora: Sara · Navegante y Bitácora: Juanjo · Revisora del plan: Laura

En esta fase rompimos a propósito la regla práctica de la clase («si usas IaC, nunca cambies la infra a mano») para ver qué detecta Terraform. Al terminar, la regla vuelve a aplicar.

### Evidencias

#### Experimento A · Apagar el servidor
```
$ docker stop web-g2
web-g2

$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=6121722b6ee533e74568f949ecfa431c37b674638bb61f5564f163d01af3263c]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      ~ exit_code = 0 -> (known after apply)
      ~ id        = "6121722b6ee533e74568f949ecfa431c37b674638bb61f5564f163d01af3263c" -> (known after apply)
      ~ must_run  = false -> true
        name      = "web-g2"
        ...
      + ports { # forces replacement
          + external = 8080 # forces replacement
          + internal = 80 # forces replacement
          + ip       = "0.0.0.0" # forces replacement
          + protocol = "tcp" # forces replacement
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```
(Se dejaron los atributos clave del contenedor; el resto pasan a `known after apply` o `null`.)

**Aprobación de la revisora (Laura):** «Aprobado: 1 a crear, 0 a cambiar, 1 a destruir».

```
$ terraform apply
...
  Enter a value: yes

docker_container.web: Destroying... [id=6121722b6ee533e74568f949ecfa431c37b674638bb61f5564f163d01af3263c]
docker_container.web: Destruction complete after 0s
docker_container.web: Creating...
docker_container.web: Creation complete after 0s [id=1f5853563b13c4657aa96560c16601197ab359a6a7d16bc28e06e6970bc2f2a7]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```
El plan detectó que el contenedor ya no corría (`must_run` pasó de `false` a `true`). Como un contenedor detenido no reporta sus puertos publicados, el bloque `ports` aparece como nuevo con `# forces replacement`, así que Terraform lo recreó en lugar de solo encenderlo (el `id` cambió de `6121722b...` a `1f585356...`).

#### Experimento B · Borrar el servidor
```
$ docker rm -f web-g2
web-g2

$ terraform plan -refresh-only
...
Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have affected this plan:

  # docker_container.web has been deleted
  - resource "docker_container" "web" {
      - id    = "1f5853563b13c4657aa96560c16601197ab359a6a7d16bc28e06e6970bc2f2a7" -> null
      - image = "sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5" -> null
      - name  = "web-g2" -> null
      ...
      - ports {
          - external = 8080 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }
    }

This is a refresh-only plan, so Terraform will not take any actions to undo these. If you were expecting these changes then you can apply this
plan to record the updated values in the Terraform state without changing any remote objects.
```

```
$ terraform plan
...
Terraform will perform the following actions:

  # docker_container.web will be created
  + resource "docker_container" "web" {
      + image = "sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5"
      + name  = "web-g2"
      ...
      + ports {
          + external = 8080
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Comparación de las dos salidas:** `plan -refresh-only` solo informa lo que cambió por fuera de Terraform («`docker_container.web has been deleted`») y aclara que no hará nada para deshacerlo; sirve para actualizar el state si el cambio fue intencional. El `plan` normal compara contra el código y propone volver al estado deseado: crear de nuevo el contenedor (`1 to add`).

**Aprobación de la revisora (Laura):** «Aprobado: 1 a crear, 0 a cambiar, 0 a destruir».

```
$ terraform apply
...
  Enter a value: yes

docker_container.web: Creating...
docker_container.web: Creation complete after 0s [id=3babfb00447938c029e9436840d204deb3f0f782ca117c9d57ffd4456a0f9227]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

#### Experimento C · Cambiar el contenido por dentro
```
$ docker exec web-g2 sh -c "echo '<h1>Cambio manual</h1>' > /usr/share/nginx/html/index.html"

$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=3babfb00447938c029e9436840d204deb3f0f782ca117c9d57ffd4456a0f9227]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
En http://localhost:8080 la página mostraba solo el título **«Cambio manual»**, pero el plan dijo que no había cambios.

**Corrección inmutable** (aprobada por Laura: «1 a crear, 0 a cambiar, 1 a destruir, reemplazo pedido por nosotros»):
```
$ terraform apply -replace=docker_container.web
...
  # docker_container.web will be replaced, as requested
-/+ resource "docker_container" "web" {
      ~ id   = "3babfb00447938c029e9436840d204deb3f0f782ca117c9d57ffd4456a0f9227" -> (known after apply)
        name = "web-g2"
        ...
    }

Plan: 1 to add, 0 to change, 1 to destroy.
...
  Enter a value: yes

docker_container.web: Destroying... [id=3babfb00447938c029e9436840d204deb3f0f782ca117c9d57ffd4456a0f9227]
docker_container.web: Destruction complete after 1s
docker_container.web: Creating...
docker_container.web: Creation complete after 0s [id=7d6227ca8573f7b3a76377e34ce25ea1c3329b2e742380723ddb95dc90dd348d]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

**Punto de control: todo estable**
```
$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
docker_container.web: Refreshing state... [id=7d6227ca8573f7b3a76377e34ce25ea1c3329b2e742380723ddb95dc90dd348d]

No changes. Your infrastructure matches the configuration.
```
La página volvió a mostrar la bienvenida de nginx.

#### Tabla de experimentos

| Experimento | ¿El plan lo detectó? | ¿Qué propuso Terraform? | ¿Cómo quedó corregido? |
|---|---|---|---|
| A · Apagar | Sí: `must_run` pasó de `false` a `true` y los puertos aparecieron como faltantes | Reemplazar el contenedor (`-/+`, `1 to add, 1 to destroy`) porque los puertos fuerzan el reemplazo | Con `terraform apply`: se destruyó el contenedor detenido y se creó uno nuevo (id `1f585356...`); la página respondió de nuevo |
| B · Borrar | Sí: `plan -refresh-only` mostró `docker_container.web has been deleted` | Crear de nuevo el contenedor (`+`, `1 to add, 0 to destroy`) | Con `terraform apply`: se creó un contenedor nuevo (id `3babfb00...`) con la misma configuración del código |
| C · Cambiar por dentro | No: el plan respondió `No changes`, aunque la página mostraba «Cambio manual» | Nada, porque el contenido de los archivos dentro del contenedor no es parte del recurso | Con `terraform apply -replace=docker_container.web`: se reemplazó el contenedor completo (id `7d6227ca...`) y volvió la página original de nginx |

### Respuestas

**1. ¿Por qué Terraform no detectó el experimento C? ¿Qué tipo de herramienta de la diapositiva «Aprovisionar ≠ configurar» se encarga de ese nivel?**

Porque Terraform solo compara los atributos del recurso que administra: para `docker_container` son cosas como la imagen, el nombre, los puertos, la red y si está corriendo, que lee de la API de Docker. El archivo `index.html` dentro del contenedor no es un atributo del recurso, así que para Terraform el contenedor seguía exactamente igual a lo que dice el código. Terraform es una herramienta de **aprovisionamiento**: se encarga de «que exista la máquina». Lo que pasa dentro (archivos, software instalado, ajustes) le corresponde a la **gestión de configuración**, con herramientas como Ansible, Chef o Puppet, que sí revisan y corrigen ese nivel.

**2. ¿Por qué `-replace` es una corrección coherente con la infraestructura inmutable?**

Porque en lugar de entrar al contenedor a deshacer el cambio a mano (el enfoque mutable: «curar» el servidor), lo descartamos y creamos uno nuevo a partir de la imagen y el código. Así no importa qué se haya modificado por dentro, ni si lo sabemos: el contenedor nuevo es idéntico a lo que el código describe y a cualquier otro creado con el mismo código. Es el enfoque inmutable de la diapositiva: para cambiar o reparar, se crea uno nuevo y se borra el viejo. Además, la corrección queda hecha con Terraform y no con un comando suelto, así que sigue la regla de no tocar la infraestructura a mano.

**3. En un equipo real, ¿cómo detectarían el drift sin esperar a que alguien ejecute `plan` por casualidad?**

- Programar un pipeline (por ejemplo, un GitHub Actions con `schedule`) que ejecute `terraform plan -detailed-exitcode` todos los días: ese comando termina con código 2 cuando hay diferencias, y el pipeline puede avisar al equipo por correo o chat.
- Usar las funciones de detección de drift de plataformas como HCP Terraform, que hacen esa revisión periódica automáticamente.
- Prevenir el drift: quitar permisos para cambiar la infraestructura por consola, de modo que solo el pipeline pueda aplicar cambios.
- Para el nivel que Terraform no ve (como el experimento C), usar gestión de configuración o contenedores con sistema de archivos de solo lectura, y monitorear que el contenido servido sea el esperado.

---

## Fase 5 · Las piezas que dan flexibilidad

**Roles en esta fase:** Operador: Juanjo · Navegante y Bitácora: Laura · Revisora del plan: Sara

### Evidencias

**1. Código separado por responsabilidad** (Terraform lee todos los `.tf` de la carpeta como uno solo):
```
infra/
├── main.tf           # terraform, provider y recursos
├── variables.tf      # entradas: grupo, puerto (con validation), imagen, mensaje
├── locals.tf         # valores calculados: nombre, html, etiquetas
├── data.tf           # red "bridge" que se lee sin crear
├── outputs.tf        # salidas: url, contenedor, red_driver
└── terraform.tfvars  # grupo = 2, mensaje = "Hola desde el grupo 2"
```

**TODO resueltos**
- **TODO 1** (`variables.tf`): variable `mensaje` de tipo `string`, con descripción y sin `default`; su valor llega desde `terraform.tfvars`.
- **TODO 2** (`locals.tf`): local `etiquetas = { curso = "arquitectura-sw-2", grupo = tostring(var.grupo) }`.
- **TODO 3, reto** (`main.tf`): bloque `dynamic "labels"` con `for_each = local.etiquetas` y `content { label = labels.key, value = labels.value }`, que genera un bloque `labels` por cada etiqueta.
- **TODO 4** (`outputs.tf`): `output "contenedor"` con `docker_container.web.name`.
- **TODO 5** (`outputs.tf`): `output "red_driver"` con `data.docker_network.bridge.driver`.

**2. Formato, validación y plan**
```
$ terraform fmt

$ terraform validate
Success! The configuration is valid.

$ terraform plan
docker_image.nginx: Refreshing state... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
data.docker_network.bridge: Reading...
data.docker_network.bridge: Read complete after 0s [id=e3d165918145111b2b995fe37566e831bc2ceff90ec61158daccf428b57ef190]
docker_container.web: Refreshing state... [id=7d6227ca8573f7b3a76377e34ce25ea1c3329b2e742380723ddb95dc90dd348d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
      ~ id   = "7d6227ca8573f7b3a76377e34ce25ea1c3329b2e742380723ddb95dc90dd348d" -> (known after apply)
        name = "web-g2"
        ...
      + labels { # forces replacement
          + label = "curso"
          + value = "arquitectura-sw-2"
        }
      + labels { # forces replacement
          + label = "grupo"
          + value = "2"
        }

      + upload { # forces replacement
          + content        = <<-EOT
                <h1>Hola desde el grupo 2</h1>
                <p>Desplegado con Terraform por el grupo 2</p>
            EOT
          + executable     = false
          + file           = "/usr/share/nginx/html/index.html"
            # (6 unchanged attributes hidden)
        }

        # (1 unchanged block hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  + contenedor = "web-g2"
  + red_driver = "bridge"
```
(Se dejaron los atributos clave del contenedor; el resto pasan a `known after apply` o `null`.)

**Explicación de la revisora (Sara) antes de aprobar:** el contenedor se reemplaza porque los bloques `labels` y `upload` son nuevos y están marcados con `# forces replacement`: Docker no permite agregar etiquetas ni cambiar el archivo inicial de un contenedor ya creado, así que Terraform lo destruye y crea uno nuevo. El nombre (`web-g2`, ahora calculado con `local.nombre`) y el puerto (8080, ahora el `default` de `var.puerto`) no cambian. «Aprobado: 1 a crear, 0 a cambiar, 1 a destruir».

**3. apply y salidas**
```
$ terraform apply
...
  Enter a value: yes

docker_container.web: Destroying... [id=7d6227ca8573f7b3a76377e34ce25ea1c3329b2e742380723ddb95dc90dd348d]
docker_container.web: Destruction complete after 1s
docker_container.web: Creating...
docker_container.web: Creation complete after 0s [id=7eea8d5d837ce8e1070602dd889b791edd14029d31ae244e56adeb836e118562]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

contenedor = "web-g2"
red_driver = "bridge"
url = "http://localhost:8080"

$ terraform output
contenedor = "web-g2"
red_driver = "bridge"
url = "http://localhost:8080"
```
En http://localhost:8080 la página muestra **«Hola desde el grupo 2»** y debajo «Desplegado con Terraform por el grupo 2».

**4. Exploración con `terraform console`**
```
$ terraform console
> local.nombre
"web-g2"
> upper(var.mensaje)
"HOLA DESDE EL GRUPO 2"
> format("web-g%02d", var.grupo)
"web-g02"
> local.etiquetas
{
  "curso" = "arquitectura-sw-2"
  "grupo" = "2"
}
> data.docker_network.bridge.driver
"bridge"
> exit
```

**5. Prueba de la validación (solo plan, sin aplicar)**
```
$ terraform plan -var="puerto=9500"
data.docker_network.bridge: Reading...
docker_image.nginx: Refreshing state... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
data.docker_network.bridge: Read complete after 0s [id=e3d165918145111b2b995fe37566e831bc2ceff90ec61158daccf428b57ef190]

Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Invalid value for variable
│
│   on variables.tf line 6:
│    6: variable "puerto" {
│     ├────────────────
│     │ var.puerto is 9500
│
│ El puerto debe estar entre 8000 y 8999.
│
│ This was checked by the validation rule at variables.tf:11,3-13.
╵
```

```
$ terraform plan -var="puerto=8085"
...
  # docker_container.web must be replaced
-/+ resource "docker_container" "web" {
        name = "web-g2"
        ...
      ~ ports {
          ~ external = 8080 -> 8085 # forces replacement
            # (3 unchanged attributes hidden)
        }

        # (3 unchanged blocks hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ url        = "http://localhost:8080" -> "http://localhost:8085"
```
Ninguno de los dos se aplicó: el servidor sigue en el puerto 8080.

### Respuestas

**1. `puerto` tiene un default, puede venir de `terraform.tfvars` y se pasó con `-var`. ¿Qué valor gana cuando hay varios?**

Gana el de mayor precedencia. De menor a mayor: el `default` de la variable, las variables de entorno `TF_VAR_puerto`, el archivo `terraform.tfvars`, los archivos `*.auto.tfvars` y, por último, `-var` o `-var-file` en la línea de comandos, que gana sobre todo lo anterior. En nuestro caso `puerto` no está en `terraform.tfvars`, así que normalmente usa el `default` 8080; pero con `-var="puerto=8085"` el plan propuso cambiar el puerto a 8085 y la `url` a `http://localhost:8085`, lo que demuestra que `-var` se impone sobre el `default`.

**2. ¿Qué hizo el bloque `validation` con el puerto 9500? ¿En qué se parece a la idea de Policy as Code?**

Rechazó el valor antes de calcular el plan y antes de tocar Docker: el plan terminó en `Planning failed` con nuestro mensaje «El puerto debe estar entre 8000 y 8999». Ni siquiera llegó a refrescar el contenedor. Se parece a Policy as Code porque es una regla escrita como código que valida la infraestructura **antes de aplicarla** y bloquea automáticamente una configuración no permitida, sin depender de que una persona se dé cuenta. La diferencia es de alcance: `validation` revisa una sola variable dentro de nuestro código, mientras que herramientas como Checkov, OPA o Sentinel aplican políticas de toda la organización sobre cualquier código, por ejemplo «sin buckets públicos».

**3. ¿Terraform creó la red `bridge`? ¿Qué le pasará cuando el grupo ejecute `destroy`?**

No. Es un `data source`: Terraform solo la lee (`data.docker_network.bridge: Reading...` / `Read complete`) y en el plan no aparece como recurso a crear; nunca hubo un `+` para ella. La red `bridge` es la red por defecto que Docker trae al instalarse. Cuando ejecutemos `destroy`, Terraform eliminará solo lo que administra (el contenedor, y la imagen sale de su registro) y la red `bridge` quedará intacta, porque Terraform no la creó y no es suya. Es la idea de la diapositiva: los data sources leen información que ya existe, sin crearla.

**4. ¿Qué ganan con `local.nombre` frente a escribir `"web-g2"` en cada lugar donde se necesita?**

Una sola fuente de verdad. El nombre se calcula una vez a partir de `var.grupo`, así que si cambia el número del grupo basta con modificar `terraform.tfvars` y todos los lugares que usan el nombre (el contenedor, el output `contenedor`) se actualizan solos. Escribiéndolo a mano en cada sitio habría que acordarse de cambiarlo en todos, y un error de digitación en uno solo crearía nombres inconsistentes. Además, el mismo código sirve para cualquier grupo sin editarlo, que es lo que buscan los locals: valores calculados para no repetirse.

---

## Fase 6 · Módulos: la receta una sola vez

**Roles en esta fase:** Operadora: Laura · Navegante y Bitácora: Sara · Revisor del plan: Juanjo

### Evidencias

**1. Estructura del módulo**
```
infra/modules/sitio_web/
├── versions.tf    # declara el origen kreuzwerker/docker
├── variables.tf   # nombre, mensaje, imagen (default nginx:1.28-alpine), puerto (con validation)
├── main.tf        # local html, docker_image.this y docker_container.this
└── outputs.tf     # url y nombre
```
El bloque `validation` del puerto se movió de la raíz al módulo.

**2. Uso del módulo desde la raíz** (`infra/main.tf`): se eliminaron `docker_image.nginx` y `docker_container.web` y se agregaron tres llamadas al mismo módulo.

| Módulo | Nombre | Puerto | Mensaje |
|---|---|---|---|
| `tienda` | `tienda-g2` | 8081 | Tienda del grupo 2 |
| `blog` | `blog-g2` | 8082 | Blog del grupo 2 |
| `docs` | `docs-g2` | 8083 | Documentación del grupo 2 |

**TODO resueltos**
- **TODO 1** (`main.tf`): módulos `blog` (puerto 8082) y `docs` (puerto 8083), con la misma estructura que `tienda`.
- **TODO 2** (`outputs.tf`): `output "urls"` con la lista `[module.tienda.url, module.blog.url, module.docs.url]`.

**3. Limpieza de la raíz:** se borraron `local.nombre` y `local.html` de `locals.tf`, las variables `puerto` y `mensaje` de `variables.tf`, la línea `mensaje` de `terraform.tfvars` y los outputs `url` y `contenedor`, que apuntaban a `docker_container.web`. En la raíz quedan las variables `grupo` e `imagen`, el local `etiquetas`, el data source `bridge` y los outputs `red_driver` y `urls`.

**4. init, formato y validación**
```
$ terraform init
Initializing the backend...

Initializing modules...
- docs in modules\sitio_web
- tienda in modules\sitio_web
- blog in modules\sitio_web

Initializing provider plugins...
- Reusing version 4.6.0 of kreuzwerker/docker from the dependency lock file
- Using previously-installed kreuzwerker/docker v4.6.0

Terraform has been successfully initialized!

$ terraform fmt -recursive
terraform.tfvars

$ terraform validate
Success! The configuration is valid.
```
(`fmt` reportó `terraform.tfvars` porque lo reacomodó al borrar la línea `mensaje`.)

**5. plan**
```
$ terraform plan
...
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # docker_container.web will be destroyed
  # (because docker_container.web is not in configuration)
  - resource "docker_container" "web" {
      - name = "web-g2" -> null
      ...
    }

  # docker_image.nginx will be destroyed
  # (because docker_image.nginx is not in configuration)
  - resource "docker_image" "nginx" {
      - name = "nginx:1.28-alpine" -> null
      ...
    }

  # module.blog.docker_container.this will be created
  + resource "docker_container" "this" {
      + name = "blog-g2"
      ...
      + ports {
          + external = 8082
          + internal = 80
        }
      + upload {
          + content = <<-EOT
                <h1>Blog del grupo 2</h1>
                <p>Sitio blog-g2, desplegado con Terraform</p>
            EOT
          + file    = "/usr/share/nginx/html/index.html"
        }
    }

  # module.blog.docker_image.this will be created
  + resource "docker_image" "this" {
      + keep_locally = true
      + name         = "nginx:1.28-alpine"
    }

  # module.docs.docker_container.this will be created
  + resource "docker_container" "this" {
      + name = "docs-g2"
      ... (puerto 8083)
    }

  # module.docs.docker_image.this will be created

  # module.tienda.docker_container.this will be created
  + resource "docker_container" "this" {
      + name = "tienda-g2"
      ... (puerto 8081)
    }

  # module.tienda.docker_image.this will be created

Plan: 6 to add, 0 to change, 2 to destroy.

Changes to Outputs:
  - contenedor = "web-g2" -> null
  - url        = "http://localhost:8080" -> null
  + urls       = [
      + "http://localhost:8081",
      + "http://localhost:8082",
      + "http://localhost:8083",
    ]
```
(Plan resumido: los atributos de cada recurso se recortaron con `...`.)

**Explicación del revisor (Juanjo) antes de aprobar:** se destruyen 2 recursos de la raíz, `docker_container.web` y `docker_image.nginx`, porque ya no están en el código (`not in configuration`). Se crean 6: una imagen y un contenedor dentro de cada uno de los tres módulos. «Aprobado: 6 a crear, 0 a cambiar, 2 a destruir».

**6. apply y verificación**
```
$ terraform apply
...
  Enter a value: yes

module.tienda.docker_image.this: Creating...
module.blog.docker_image.this: Creating...
docker_container.web: Destroying... [id=7eea8d5d837ce8e1070602dd889b791edd14029d31ae244e56adeb836e118562]
module.docs.docker_image.this: Creating...
module.blog.docker_image.this: Creation complete after 0s [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
module.tienda.docker_image.this: Creation complete after 0s [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
module.docs.docker_image.this: Creation complete after 0s [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
module.blog.docker_container.this: Creating...
module.tienda.docker_container.this: Creating...
module.docs.docker_container.this: Creating...
docker_container.web: Destruction complete after 1s
docker_image.nginx: Destroying... [id=sha256:dc73b49f5124cf2ee538dfbdfbd121f0b4ccdcb20fea30f3a81bd477c02e2bb5nginx:1.28-alpine]
docker_image.nginx: Destruction complete after 0s
module.docs.docker_container.this: Creation complete after 1s [id=b014c868e79f09944f09dcd29cff86e24b0dc6cbea458a2ba827c234211ad095]
module.tienda.docker_container.this: Creation complete after 1s [id=1a5648f8d42db1662e74c60e3a56f785ad55b384c7b663be02f3650bd8fc4224]
module.blog.docker_container.this: Creation complete after 1s [id=1ba5a1f3bfcf4de8237e93d332ade8a960a6a268bba9fc91511864202f0eba6c]

Apply complete! Resources: 6 added, 0 changed, 2 destroyed.

Outputs:

red_driver = "bridge"
urls = [
  "http://localhost:8081",
  "http://localhost:8082",
  "http://localhost:8083",
]

$ terraform output urls
[
  "http://localhost:8081",
  "http://localhost:8082",
  "http://localhost:8083",
]

$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                  NAMES
1ba5a1f3bfcf   dc73b49f5124   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8082->80/tcp   blog-g2
1a5648f8d42d   dc73b49f5124   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8081->80/tcp   tienda-g2
b014c868e79f   dc73b49f5124   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8083->80/tcp   docs-g2
```
Como el recurso de imagen tiene `keep_locally = true`, destruir `docker_image.nginx` solo lo sacó del state: la imagen `nginx:1.28-alpine` siguió en Docker y los tres módulos la reutilizaron (mismo id `dc73b49f5124`).

**7. Hallazgo: la tilde se veía mal en «Documentación»**

En http://localhost:8083 el título se veía como «DocumentaciÃ³n del grupo 2»: la página no declaraba su codificación y el navegador interpretaba la «ó» (UTF-8) con otra codificación. Lo corregimos agregando `<meta charset="utf-8">` al `local.html` **solo en `modules/sitio_web/main.tf`**:
```hcl
locals {
  html = <<-EOT
    <meta charset="utf-8">
    <h1>${var.mensaje}</h1>
    <p>Sitio ${var.nombre}, desplegado con Terraform</p>
  EOT
}
```

```
$ terraform plan
...
  # module.blog.docker_container.this must be replaced
-/+ resource "docker_container" "this" {
        name = "blog-g2"
        ...
      - upload { # forces replacement
          - content = <<-EOT
                <h1>Blog del grupo 2</h1>
                <p>Sitio blog-g2, desplegado con Terraform</p>
            EOT -> null
        }
      + upload { # forces replacement
          + content = <<-EOT
                <meta charset="utf-8">
                <h1>Blog del grupo 2</h1>
                <p>Sitio blog-g2, desplegado con Terraform</p>
            EOT
        }
    }

  # module.docs.docker_container.this must be replaced
  (mismo cambio en upload, con «Documentación del grupo 2»)

  # module.tienda.docker_container.this must be replaced
  (mismo cambio en upload, con «Tienda del grupo 2»)

Plan: 3 to add, 0 to change, 3 to destroy.
```
**Aprobación del revisor (Juanjo):** «Aprobado: 3 a crear, 0 a cambiar, 3 a destruir; solo se reemplazan los contenedores por el cambio del `upload`, las imágenes no se tocan».

```
$ terraform apply
...
module.docs.docker_container.this: Destroying... [id=b014c868e79f09944f09dcd29cff86e24b0dc6cbea458a2ba827c234211ad095]
module.tienda.docker_container.this: Destroying... [id=1a5648f8d42db1662e74c60e3a56f785ad55b384c7b663be02f3650bd8fc4224]
module.blog.docker_container.this: Destroying... [id=1ba5a1f3bfcf4de8237e93d332ade8a960a6a268bba9fc91511864202f0eba6c]
module.docs.docker_container.this: Destruction complete after 1s
module.docs.docker_container.this: Creating...
module.blog.docker_container.this: Destruction complete after 1s
module.blog.docker_container.this: Creating...
module.tienda.docker_container.this: Destruction complete after 1s
module.tienda.docker_container.this: Creating...
module.blog.docker_container.this: Creation complete after 1s [id=30384dfbb5a957eae1ac9fc3a69f8fce48cfb616c03d3a3bb167e3204e80398e]
module.docs.docker_container.this: Creation complete after 1s [id=7cbaaf8a0b754460a450d52d417e6c9590df08bfd1d3d72da257b784d2b0318f]
module.tienda.docker_container.this: Creation complete after 1s [id=6c785acff042fb2b9ede311266dae554130962efeed4c71b14bf1b92e78d00d3]

Apply complete! Resources: 3 added, 0 changed, 3 destroyed.
```
Ahora http://localhost:8083 muestra «Documentación del grupo 2» correctamente, y los puertos 8081 y 8082 muestran la tienda y el blog.

### Respuestas

**1. Anoten la línea `Plan:` del paso 8. ¿Qué se destruyó, qué se creó y por qué?**

`Plan: 6 to add, 0 to change, 2 to destroy.` Se destruyeron los dos recursos de la raíz, `docker_container.web` (el sitio `web-g2` en el puerto 8080) y `docker_image.nginx`, porque los borramos del código y Terraform lo indicó con `because ... is not in configuration`. Se crearon seis: `docker_image.this` y `docker_container.this` dentro de cada módulo (`module.tienda`, `module.blog` y `module.docs`). Terraform identifica cada recurso por su dirección; al pasar el servidor a un módulo, la dirección cambió (de `docker_container.web` a `module.tienda.docker_container.this`), así que para Terraform el viejo desapareció y los nuevos son otros recursos. Lo que no se destruyó fue la imagen en Docker: con `keep_locally = true` solo salió del state, y los tres módulos la reutilizaron.

**2. ¿Qué error obtendrían si el módulo no tuviera `versions.tf`?**

`terraform init` fallaría con `Failed to query available provider packages`, mencionando `hashicorp/docker`. Cuando un módulo usa recursos `docker_*` sin declarar el origen del provider, Terraform asume que viene del espacio de nombres oficial `hashicorp/` y busca `hashicorp/docker`, que no existe. El `versions.tf` le indica que el provider correcto es `kreuzwerker/docker`, el mismo de la raíz, y así ambos comparten la configuración del provider.

**3. Si mañana hay que agregar una etiqueta a todos los sitios, ¿cuántos archivos tocan con módulo? ¿Cuántos bloques habrían tocado copiando y pegando?**

Con módulo se toca **un solo archivo**: `modules/sitio_web/main.tf`, agregando el bloque `labels` en `docker_container.this`, y el cambio llega a los tres sitios. Lo comprobamos en esta misma fase con el `<meta charset="utf-8">`: editamos solo el módulo y el plan reemplazó los tres contenedores (`3 to add, 3 to destroy`). Copiando y pegando habría que tocar **tres bloques** `docker_container`, uno por sitio, y cada sitio nuevo sumaría otro bloque. Es lo que dice la diapositiva de módulos: sin ellos, un cambio hay que hacerlo en N lugares y cada copia se desincroniza con el tiempo.

**4. ¿Qué necesitaría otro grupo para usar su módulo sin copiar la carpeta?**

Que el módulo esté publicado en un lugar accesible y referenciarlo en su `source`. La forma más simple es subir nuestro repositorio a GitHub y que ellos usen `source = "git::https://github.com/<usuario>/iac-taller-g2.git//infra/modules/sitio_web?ref=v1.0"`, donde `//` indica la subcarpeta y `ref` fija una versión (un tag de Git) para que nuestros cambios futuros no los afecten sin aviso. También se podría publicar en un registro de módulos (el Terraform Registry o uno privado). Además, el módulo debe ser autocontenido y documentado: `versions.tf` con el provider, variables con `description` y `validation`, outputs claros y un README que explique cómo usarlo. Luego ellos ejecutan `terraform init` y Terraform lo descarga.

---

## Fase 7 · State remoto y varios ambientes

**Roles en esta fase:** Operadora: Sara · Navegante y Bitácora: Juanjo · Revisora del plan: Laura

> 🔒 **Sobre la contraseña del backend:** no usamos la contraseña de ejemplo de la guía; elegimos una propia solo para el taller. En toda esta bitácora aparece como `****`. Nunca se escribió en ningún archivo del repositorio: vive solo en la variable de entorno `PG_CONN_STR` de la terminal y en el contenedor del backend. **Grupo auditor:** para comprobar que no está en el historial, pídannos la contraseña y búsquenla con `git log -p -S "<contraseña>"`. Buscar la contraseña de ejemplo de la guía no sirve para auditarnos, porque no la usamos.

### Parte A · State remoto con bloqueo

**1. Backend levantado por fuera de Terraform** (el lugar donde vive el state debe existir antes de que Terraform lo use)
```
$ docker run -d --name tf-state-g2 -e POSTGRES_USER=terraform -e POSTGRES_PASSWORD=**** -e POSTGRES_DB=terraform_backend -p 5433:5432 postgres:17-alpine
90237a106fc28f7e5216e892810955ed3fd3f4b871ab17928c8bc28b3fc8cba7
```
Problemas que tuvimos al levantarlo:
- El primer intento falló con `docker: invalid reference format` porque pegamos en una sola línea el comando con las `\` de la guía. Lo escribimos en una línea sin barras.
- En el segundo intento el contenedor quedó con una contraseña distinta a la de `PG_CONN_STR`. Como el backend aún estaba vacío, lo borramos (`docker rm -f tf-state-g2`) y lo creamos de nuevo con la misma contraseña en los dos lados.

**2. Conexión en variable de entorno, no en el código**
```
$ export PG_CONN_STR="postgres://terraform:****@localhost:5433/terraform_backend?sslmode=disable"
```

**3. Backend vacío** dentro del bloque `terraform` de `main.tf`; Terraform completa la conexión con `PG_CONN_STR`:
```hcl
  backend "pg" {}
```

**4. Migración del state**
```
$ terraform init -migrate-state
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "pg" backend. No existing state was found in the newly
  configured "pg" backend. Do you want to copy this state to the new "pg"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "pg"! Terraform will automatically
use this backend unless the backend configuration changes.
...
Terraform has been successfully initialized!

$ terraform state list
data.docker_network.bridge
module.blog.docker_container.this
module.blog.docker_image.this
module.docs.docker_container.this
module.docs.docker_image.this
module.tienda.docker_container.this
module.tienda.docker_image.this

$ docker exec tf-state-g2 psql -U terraform -d terraform_backend -c "SELECT id, name FROM terraform_remote_state.states;"
 id |  name
----+---------
  1 | default
(1 row)
```
Terraform siguió viendo todos sus recursos, ahora leyéndolos desde PostgreSQL.

**5. Prueba de bloqueo con dos terminales**

Primer intento: en la terminal 1 corrimos `terraform apply`, pero como no había cambios terminó solo (`No changes`) sin pedir confirmación y soltó el bloqueo, así que la terminal 2 pudo planear sin problema. Para que el `apply` se quedara esperando, le dimos algo que proponer:

*Terminal 1* (sin responder la confirmación):
```
$ terraform apply -replace=module.tienda.docker_container.this
...
Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

*Terminal 2* (con su propio `export PG_CONN_STR=...`):
```
$ terraform plan
╷
│ Error: Error acquiring the state lock
│
│ Error message: Workspace is already locked: default
│ Lock Info:
│   ID:        516e0521-ba62-3883-0a11-43dd440a68fa
│   Path:
│   Operation: OperationTypePlan
│   Who:       SARA12\estra@Sara12
│   Version:   1.17.0
│   Created:   2026-11-10 02:26:46.7701989 +0000 UTC
│   Info:
│
│
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.
╵
```
Luego respondimos `no` en la terminal 1, sin reemplazar nada, y el bloqueo se liberó (el `destroy` del paso 6 pudo ejecutarse sin error).

### Parte B · Un mismo código, tres ambientes

**6. Workspace `default` limpio** (antes de cambiar los archivos)
```
$ terraform destroy
...
Plan: 0 to add, 0 to change, 6 to destroy.

Changes to Outputs:
  - red_driver = "bridge" -> null
  - urls       = [
      - "http://localhost:8081",
      - "http://localhost:8082",
      - "http://localhost:8083",
    ] -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

module.tienda.docker_container.this: Destroying... [id=6c785acff042fb2b9ede311266dae554130962efeed4c71b14bf1b92e78d00d3]
module.docs.docker_container.this: Destroying... [id=7cbaaf8a0b754460a450d52d417e6c9590df08bfd1d3d72da257b784d2b0318f]
module.blog.docker_container.this: Destroying... [id=30384dfbb5a957eae1ac9fc3a69f8fce48cfb616c03d3a3bb167e3204e80398e]
module.docs.docker_container.this: Destruction complete after 1s
module.docs.docker_image.this: Destroying... [id=sha256:dc73b49f...nginx:1.28-alpine]
module.docs.docker_image.this: Destruction complete after 0s
module.blog.docker_container.this: Destruction complete after 1s
module.blog.docker_image.this: Destroying... [id=sha256:dc73b49f...nginx:1.28-alpine]
module.blog.docker_image.this: Destruction complete after 0s
module.tienda.docker_container.this: Destruction complete after 1s
module.tienda.docker_image.this: Destroying... [id=sha256:dc73b49f...nginx:1.28-alpine]
module.tienda.docker_image.this: Destruction complete after 0s

Destroy complete! Resources: 6 destroyed.
```
**Aprobación de la revisora (Laura):** «Aprobado: 0 a crear, 0 a cambiar, 6 a destruir (3 contenedores y 3 imágenes; la red `bridge` no se toca porque es un data source)».

**7. Ambientes descritos en `locals.tf`**

| Ambiente | Puerto base | Sitios | Imagen |
|---|---|---|---|
| dev | 8100 | tienda (8101) | `nginx:1.28-alpine` |
| staging | 8200 | tienda, blog, docs (8201–8203) | `nginx:1.28-alpine` |
| prod | 8300 | tienda, blog, docs (8301–8303) | `nginx:1.27-alpine` |

**TODO resueltos**
- **TODO 1** (`locals.tf`): atributo `imagen` en cada ambiente; dev y staging prueban `nginx:1.28-alpine` y prod se queda en `nginx:1.27-alpine` hasta que staging la valide.
- **TODO 2** (`main.tf`): `imagen = local.amb.imagen` en el `module "sitio"`, que ahora usa `for_each = local.sitios` en lugar de tres bloques.
- **TODO 3** (`outputs.tf`): `output "urls"` como map `{ for k, m in module.sitio : m.nombre => m.url }`.

**8. Reinicialización.** Como la llamada al módulo cambió de nombre (`module "sitio"`), hubo que ejecutar `terraform init` otra vez:
```
$ terraform init
Initializing the backend...

Initializing modules...
- sitio in modules\sitio_web
...
Terraform has been successfully initialized!
```

**9. Un despliegue por ambiente**

*dev*
```
$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ terraform apply
...
  # module.sitio["tienda"].docker_container.this will be created
  + name = "tienda-g2-dev"   (puerto 8101, «Tienda - DEV - grupo 2»)
  # module.sitio["tienda"].docker_image.this will be created
  + name = "nginx:1.28-alpine"

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + red_driver = "bridge"
  + urls       = {
      + tienda-g2-dev = "http://localhost:8101"
    }

Do you want to perform these actions in workspace "dev"?
  Enter a value: yes
...
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```
**Laura:** «Workspace dev, 1 sitio: aprobado 2 a crear, 0 a cambiar, 0 a destruir».

*staging*
```
$ terraform workspace new staging
Created and switched to workspace "staging"!

$ terraform apply
...
  # module.sitio["blog"].docker_container.this    -> blog-g2-staging   (8202)
  # module.sitio["docs"].docker_container.this    -> docs-g2-staging   (8203)
  # module.sitio["tienda"].docker_container.this  -> tienda-g2-staging (8201)
  # (y una docker_image nginx:1.28-alpine por sitio)

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + red_driver = "bridge"
  + urls       = {
      + blog-g2-staging   = "http://localhost:8202"
      + docs-g2-staging   = "http://localhost:8203"
      + tienda-g2-staging = "http://localhost:8201"
    }

Do you want to perform these actions in workspace "staging"?
  Enter a value: yes
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```
**Laura:** «Workspace staging, 3 sitios: aprobado 6 a crear, 0 a cambiar, 0 a destruir».

*prod*
```
$ terraform workspace new prod
Created and switched to workspace "prod"!

$ terraform apply
...
  # module.sitio["blog"].docker_container.this    -> blog-g2-prod   (8302)
  # module.sitio["docs"].docker_container.this    -> docs-g2-prod   (8303)
  # module.sitio["tienda"].docker_container.this  -> tienda-g2-prod (8301)
  # module.sitio["..."].docker_image.this         -> name = "nginx:1.27-alpine" (x3)

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + red_driver = "bridge"
  + urls       = {
      + blog-g2-prod   = "http://localhost:8302"
      + docs-g2-prod   = "http://localhost:8303"
      + tienda-g2-prod = "http://localhost:8301"
    }

Do you want to perform these actions in workspace "prod"?
  Enter a value: yes

module.sitio["tienda"].docker_image.this: Creation complete after 0s [id=sha256:6769dc3a703c...nginx:1.27-alpine]
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```
**Laura:** «Workspace prod, 3 sitios con imagen 1.27: aprobado 6 a crear, 0 a cambiar, 0 a destruir».

(Los planes se resumieron: se dejaron el nombre, el puerto y la imagen de cada recurso.)

**Verificación**
```
$ terraform workspace list
  default
  dev
* prod
  staging

$ docker exec tf-state-g2 psql -U terraform -d terraform_backend -c "SELECT id, name FROM terraform_remote_state.states;"
 id |  name
----+---------
  1 | default
  4 | dev
  6 | staging
  8 | prod
(4 rows)

$ docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                    NAMES
5e7bb751eb2e   6769dc3a703c         "/docker-entrypoint.…"   20 seconds ago   Up 19 seconds   0.0.0.0:8302->80/tcp     blog-g2-prod
474c70a44555   6769dc3a703c         "/docker-entrypoint.…"   20 seconds ago   Up 19 seconds   0.0.0.0:8303->80/tcp     docs-g2-prod
662c154a47d6   6769dc3a703c         "/docker-entrypoint.…"   20 seconds ago   Up 19 seconds   0.0.0.0:8301->80/tcp     tienda-g2-prod
e29a50aa716a   dc73b49f5124         "/docker-entrypoint.…"   31 seconds ago   Up 31 seconds   0.0.0.0:8203->80/tcp     docs-g2-staging
1e5562c2d262   dc73b49f5124         "/docker-entrypoint.…"   31 seconds ago   Up 31 seconds   0.0.0.0:8202->80/tcp     blog-g2-staging
fcaf88612d98   dc73b49f5124         "/docker-entrypoint.…"   31 seconds ago   Up 31 seconds   0.0.0.0:8201->80/tcp     tienda-g2-staging
f9589feda429   dc73b49f5124         "/docker-entrypoint.…"   44 seconds ago   Up 44 seconds   0.0.0.0:8101->80/tcp     tienda-g2-dev
90237a106fc2   postgres:17-alpine   "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes   0.0.0.0:5433->5432/tcp   tf-state-g2
```
Corren los siete sitios (1 en dev, 3 en staging, 3 en prod) más el contenedor del backend. En la columna `IMAGE` se ve que prod usa la imagen `6769dc3a703c` (1.27) y dev y staging la `dc73b49f5124` (1.28).

**Comparación en el navegador.** Abrimos los tres ambientes y cada uno respondió con su propia página:

| URL | Ambiente | Página |
|---|---|---|
| http://localhost:8101 | dev | «Tienda - DEV - grupo 2» / «Sitio tienda-g2-dev, desplegado con Terraform» |
| http://localhost:8201 | staging | «Tienda - STAGING - grupo 2» / «Sitio tienda-g2-staging, desplegado con Terraform» |
| http://localhost:8301 | prod | «Tienda - PROD - grupo 2» / «Sitio tienda-g2-prod, desplegado con Terraform» |

Las tres páginas salen del mismo código y del mismo módulo; solo cambian el ambiente (`local.entorno`), el puerto base y la imagen. La consulta del paso 4 la repetimos después de desplegar (arriba): la tabla `states` pasó de una fila (`default`) a cuatro, una por workspace.

**10. El workspace `default` falla a propósito**
```
$ terraform workspace select default
Switched to workspace "default".

$ terraform plan
╷
│ Error: Invalid index
│
│   on locals.tf line 13, in locals:
│   13:   amb = local.ambientes[local.entorno]
│     ├────────────────
│     │ local.ambientes is object with 3 attributes
│     │ local.entorno is "default"
│
│ The given key does not identify an element in this collection value.
╵

$ terraform workspace select prod
Switched to workspace "prod".
```
(El mismo error salió antes con `terraform validate`, que ejecutamos por error todavía en `default`.)

### Respuestas

**1. ¿Qué respondió la terminal 2 en la prueba de bloqueo? ¿Qué problema de trabajo en equipo evita?**

Respondió `Error acquiring the state lock` con el mensaje `Workspace is already locked: default`, y mostró quién tenía el bloqueo (`SARA12\estra`), desde cuándo, con qué versión de Terraform y su ID. Evita que dos personas modifiquen la misma infraestructura al mismo tiempo: sin bloqueo, ambas podrían calcular su plan sobre el mismo state, aplicar cambios que se pisan entre sí y dejar un state que no corresponde a la realidad (uno sobrescribe lo que escribió el otro), o incluso crear recursos duplicados. Es lo que dice la diapositiva «Dónde vive el estado»: el state remoto da bloqueo para evitar cambios simultáneos, algo que el state local no puede ofrecer.

**2. ¿Dónde quedó la contraseña del backend y por qué no debe estar en `main.tf`?**

Quedó solo en dos lugares fuera del repositorio: la variable de entorno `PG_CONN_STR` de la terminal (que desaparece al cerrarla, por eso cada terminal nueva necesita definirla) y la configuración del contenedor `tf-state-g2`. En `main.tf` el bloque `backend "pg" {}` está vacío y Terraform completa la conexión desde la variable. No debe estar en `main.tf` porque ese archivo se versiona: la contraseña quedaría en el historial de Git para siempre, incluso si después se borra, y cualquiera con acceso al repositorio (o a una copia) la tendría. Es el anti-patrón «Secretos en el código» y la buena práctica «Saca los secretos del código».

**3. ¿Qué filas tiene ahora la tabla `states` y cómo se relacionan con los workspaces?**

Tiene cuatro filas: `default` (id 1), `dev` (id 4), `staging` (id 6) y `prod` (id 8), exactamente las mismas que muestra `terraform workspace list`. Cada workspace tiene su propio state, guardado en una fila aparte: por eso, al crear `staging`, Terraform no veía los recursos de `dev` y planeó crear todo desde cero. La fila `default` sigue existiendo aunque esté vacía, porque ahí migramos el state original y luego lo destruimos. Los `id` no son consecutivos, probablemente porque la secuencia de la tabla también se consume en cada escritura que hace el backend; lo importante es que hay una fila por workspace.

**4. ¿Qué error da `terraform plan` en el workspace `default` y por qué es útil que falle?**

Da `Error: Invalid index` en `amb = local.ambientes[local.entorno]`, porque `local.entorno` vale `"default"` y el map `ambientes` solo tiene `dev`, `staging` y `prod`. Es útil porque obliga a elegir explícitamente en qué ambiente se trabaja: si alguien olvida seleccionar el workspace, Terraform se detiene antes de calcular o aplicar nada, en lugar de desplegar en un ambiente sin nombre o con valores que nadie definió. Falla rápido y de forma segura, antes de tocar Docker.

**5. ¿Por qué dev tiene un solo sitio y staging replica a prod? ¿Por qué prod usa otra versión de imagen?**

Siguiendo la diapositiva «Un mismo código, varios ambientes»: **dev** es para probar sin miedo con recursos pequeños y baratos, así que basta con un sitio. **Staging** es una réplica de producción para validar antes de lanzar, por eso tiene los mismos tres sitios que prod: si algo funciona en staging, debería funcionar igual en prod. **Prod** es lo que usan los clientes reales y exige el máximo cuidado, así que se queda con la versión probada (`nginx:1.27-alpine`) mientras la nueva (`1.28-alpine`) se valida en dev y staging. Cuando staging la apruebe, basta con cambiar una línea en `locals.tf` y aplicar en el workspace `prod`.

**6. Los tres ambientes comparten código y backend. ¿Qué riesgo tiene eso frente a usar carpetas separadas por ambiente?**

- **Equivocarse de workspace:** el código no cambia entre ambientes, así que un `apply` en el workspace equivocado (creyendo estar en dev cuando se está en prod) afecta producción. Por eso el revisor dice en voz alta el workspace antes de cada `apply`.
- **Un cambio de código llega a todos a la vez:** un cambio en el módulo o en `main.tf` aplica a dev, staging y prod en cuanto se ejecute en cada uno; no hay una versión del código «solo para dev». Con carpetas separadas, cada ambiente puede fijar su propia versión del módulo y los cambios se promueven de forma explícita.
- **Mismo backend y mismas credenciales:** quien puede tocar dev también puede tocar prod, y si el backend falla o se pierde, se pierden los states de los tres ambientes. Con carpetas separadas se puede usar un backend y permisos distintos por ambiente.

La desventaja de las carpetas separadas es que hay más archivos y más riesgo de duplicación, algo que se reduce reutilizando el mismo módulo en todas.

---

## Fase 8 · Testing y calidad

**Roles en esta fase:** Operador: Juanjo · Navegante y Bitácora: Laura · Revisora: Sara

Validamos el código en los niveles de la diapositiva «Testing»: análisis estático, pruebas reales en un entorno desechable y escaneo de seguridad. Al final los encadenamos en `validar.sh`, que hace el papel de la etapa «Validar» del pipeline.

### Evidencias

**1. Análisis estático** (desde `infra/`, en el workspace `prod`)
```
$ terraform fmt -check -recursive

$ terraform validate
Success! The configuration is valid.
```
`fmt -check` no imprimió nada: ningún archivo necesitaba reformatearse. No usamos `tflint` porque no está instalado.

**2. Pruebas del módulo con `terraform test`**

Archivo `infra/modules/sitio_web/tests/sitio_web.tftest.hcl` con cuatro pruebas:

| Prueba | Tipo | Qué verifica |
|---|---|---|
| `url_coherente_con_puerto` | `plan` | El output `url` es `http://localhost:8999` cuando el puerto es 8999 |
| `rechaza_puerto_fuera_de_rango` | `plan` | Con `puerto = 9500`, la `validation` falla como se espera (`expect_failures`) |
| `despliegue_real` | `apply` real | Crea el contenedor de verdad y comprueba que se llame `prueba-g2`; al terminar lo destruye |
| `nombre_coincide_con_variable` | `plan` | **TODO 1 resuelto:** el output `nombre` coincide con `var.nombre` |

Agregamos al inicio del archivo un bloque `provider "docker"` con `host = "npipe:////.//pipe//docker_engine"`: el módulo no tiene configuración de provider propia y, en Windows, sin ella la prueba `despliegue_real` no encuentra Docker (la misma solución de la tabla de *Problemas frecuentes*).

```
$ cd modules/sitio_web
$ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding latest version of kreuzwerker/docker...
- Installing kreuzwerker/docker v4.6.0...
- Installed kreuzwerker/docker v4.6.0 (self-signed, key ID 0DCE698927DAF8EC)
...
Terraform has been successfully initialized!

$ terraform test
tests\sitio_web.tftest.hcl... in progress
  run "url_coherente_con_puerto"... pass
  run "rechaza_puerto_fuera_de_rango"... pass
  run "despliegue_real"... pass
  run "nombre_coincide_con_variable"... pass
tests\sitio_web.tftest.hcl... tearing down
tests\sitio_web.tftest.hcl... pass

Success! 4 passed, 0 failed.
```

**Lo que se vio en `docker ps` durante las pruebas.** En el primer intento, quien observaba ejecutó `docker ps --filter name=prueba` a mano dos veces y no vio nada: `despliegue_real` crea y destruye el contenedor en uno o dos segundos. Repetimos la prueba con un ciclo que revisaba cada medio segundo:

*Terminal de observación:*
```
$ for i in $(seq 1 60); do docker ps --filter name=prueba --format "{{.Names}}  {{.Ports}}  {{.Status}}"; sleep 0.5; done
prueba-g2  0.0.0.0:8999->80/tcp  Up 1 second
```
*Terminal del operador:*
```
$ terraform -chdir=modules/sitio_web test
...
Success! 4 passed, 0 failed.
```
El contenedor `prueba-g2` apareció en el puerto 8999 durante un instante y luego desapareció solo, sin que nadie lo borrara.

**3. Escaneo de seguridad con Checkov**

Archivo de práctica `seguridad/bucket.tf` (bucket S3 con los cuatro bloqueos de acceso público en `false`); nunca se aplica, solo se escanea.

Instalamos Checkov con `pip install checkov`. El comando `checkov` no quedó en el PATH (el Python de la Microsoft Store instala los ejecutables en una carpeta que no está en el PATH), así que lo ejecutamos como módulo: `python -m checkov.main`. El primer intento lo interrumpimos con Ctrl+C porque tardaba mucho en cargar; la primera ejecución demora alrededor de un minuto.

*Primer escaneo* (bucket público):
```
$ python -m checkov.main -d seguridad --compact
...
terraform scan results:

Passed checks: 4, Failed checks: 11, Skipped checks: 0

Check: CKV_AWS_93  ... PASSED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_19  ... PASSED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_20  ... PASSED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_57  ... PASSED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
        FAILED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_54: "Ensure S3 bucket has block public policy enabled"
        FAILED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_55: "Ensure S3 bucket has ignore public ACLs enabled"
        FAILED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_56: "Ensure S3 bucket has 'restrict_public_buckets' enabled"
        FAILED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
        FAILED for resource: aws_s3_bucket.evidencias
Check: CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
        FAILED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
        FAILED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
        FAILED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
        FAILED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
        FAILED for resource: aws_s3_bucket.evidencias
Check: CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
        FAILED for resource: aws_s3_bucket.evidencias
```
(Se recortaron las líneas `File:` y `Guide:` de cada control.)

*Corrección:* cambiamos los cuatro valores (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`) a `true`.

*Segundo escaneo:*
```
$ python -m checkov.main -d seguridad --compact
...
terraform scan results:

Passed checks: 9, Failed checks: 6, Skipped checks: 0

Check: CKV_AWS_93  ... PASSED
Check: CKV_AWS_53  ... PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_54  ... PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_55  ... PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_56  ... PASSED for resource: aws_s3_bucket_public_access_block.evidencias
Check: CKV_AWS_19  ... PASSED
Check: CKV2_AWS_6  ... PASSED for resource: aws_s3_bucket.evidencias
Check: CKV_AWS_20  ... PASSED
Check: CKV_AWS_57  ... PASSED
Check: CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"   FAILED
Check: CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"      FAILED
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"              FAILED
Check: CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"  FAILED
Check: CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled" FAILED
Check: CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"     FAILED
```

| | Aprobados | Fallidos |
|---|---|---|
| Primer escaneo (bucket público) | 4 | 11 |
| Segundo escaneo (bloqueos en `true`) | 9 | 6 |

**4. El mini pipeline `validar.sh`** (en la raíz del repositorio)
```bash
#!/usr/bin/env bash
# Etapa "Validar" del pipeline: si cualquier paso falla, el script se detiene (set -e)
set -e

echo "== 1/4 Formato"
terraform -chdir=infra fmt -check -recursive

echo "== 2/4 Validación"
terraform -chdir=infra validate

# TODO 2 resuelto: pruebas del módulo
echo "== 3/4 Pruebas del módulo"
terraform -chdir=infra/modules/sitio_web test

# TODO 3 resuelto: política del equipo "sin buckets públicos" (CKV_AWS_53 a CKV_AWS_56).
# En este computador checkov no está en el PATH, por eso se llama como módulo de Python.
echo "== 4/4 Política: sin buckets públicos"
python -m checkov.main -d seguridad --check CKV_AWS_53,CKV_AWS_54,CKV_AWS_55,CKV_AWS_56 --compact

echo "Validación completa: el cambio puede pasar a revisión"
```
Agregamos un `echo` antes de cada paso para ver en cuál se detiene. El paso 2 funciona porque el workspace activo es `prod`; en `default`, `validate` falla a propósito (Fase 7).

*Ejecución 1, todo correcto:*
```
$ bash validar.sh
== 1/4 Formato
== 2/4 Validación
Success! The configuration is valid.

== 3/4 Pruebas del módulo
...
Success! 4 passed, 0 failed.
== 4/4 Política: sin buckets públicos
...
Passed checks: 4, Failed checks: 0, Skipped checks: 0
...
Validación completa: el cambio puede pasar a revisión
```

*Ejecución 2, indentación desordenada a propósito en `infra/data.tf`:*
```
$ sed -i 's/^  name = "bridge"/        name = "bridge"/' infra/data.tf
$ bash validar.sh
== 1/4 Formato
data.tf
```
Se detuvo en el paso 1 y nunca llegó al mensaje final. Lo corregimos con `terraform -chdir=infra fmt -recursive`.

*Ejecución 3, bucket público otra vez (`block_public_acls = false`):*
```
$ sed -i 's/block_public_acls       = true/block_public_acls       = false/' seguridad/bucket.tf
$ bash validar.sh
== 1/4 Formato
== 2/4 Validación
Success! The configuration is valid.

== 3/4 Pruebas del módulo
...
Success! 4 passed, 0 failed.
== 4/4 Política: sin buckets públicos
...
Passed checks: 3, Failed checks: 1, Skipped checks: 0
...
Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
        FAILED for resource: aws_s3_bucket_public_access_block.evidencias
```
Pasó formato, validación y pruebas, pero se detuvo en la política y no imprimió el mensaje final. Devolvimos el valor a `true` y la ejecución volvió a terminar con «Validación completa: el cambio puede pasar a revisión».

### Respuestas

**1. ¿Qué encontró cada nivel (estático, pruebas, seguridad) que los otros no podían encontrar?**

- **Análisis estático** (`fmt`, `validate`): encontró la indentación desordenada de `data.tf` sin ejecutar nada. Revisa forma y sintaxis: que el código esté bien escrito y que las referencias existan. Las pruebas y el escaneo no se fijan en el formato.
- **Pruebas** (`terraform test`): comprobaron el comportamiento del módulo, algo que el análisis estático no puede saber: que la `url` corresponda al puerto, que la validación rechace el 9500 y, sobre todo, que el contenedor se cree de verdad en Docker con el nombre esperado. Un código puede ser válido y aun así no hacer lo que se espera.
- **Escaneo de seguridad** (Checkov): encontró que el bucket era público. Ese código era sintácticamente válido y se habría desplegado sin error, así que `validate` y las pruebas lo habrían aprobado; solo una revisión con reglas de seguridad detecta que es una mala configuración.

**2. ¿Qué vio quien observaba `docker ps` durante `despliegue_real`? ¿Por qué vale la pena un entorno desechable?**

Vio aparecer el contenedor `prueba-g2` publicado en el puerto 8999 (`Up 1 second`) y desaparecer solo al terminar la prueba. A mano no alcanzó a verlo; hubo que usar un ciclo que revisaba cada medio segundo. Vale la pena porque permite probar el despliegue real sin tocar los ambientes que importan: usa su propio nombre y puerto, no interfiere con los siete sitios de dev, staging y prod que seguían corriendo, se limpia automáticamente (no deja recursos olvidados ni costos en una nube real) y se puede repetir cuantas veces se quiera con el mismo resultado.

**3. ¿Qué controles fallaron en el bucket y cuántos quedaron después de corregir? ¿Cuáles corresponden al ejemplo «sin buckets públicos» de la clase?**

En el primer escaneo fallaron 11: `CKV_AWS_53`, `CKV_AWS_54`, `CKV_AWS_55`, `CKV_AWS_56`, `CKV2_AWS_6`, `CKV2_AWS_62`, `CKV2_AWS_61`, `CKV_AWS_18`, `CKV_AWS_144`, `CKV_AWS_21` y `CKV_AWS_145`. Después de corregir quedaron 6 fallos: notificaciones de eventos (`CKV2_AWS_62`), ciclo de vida (`CKV2_AWS_61`), registro de accesos (`CKV_AWS_18`), replicación entre regiones (`CKV_AWS_144`), versionado (`CKV_AWS_21`) y cifrado con KMS (`CKV_AWS_145`), que en una nube real también habría que atender. Al ejemplo «sin buckets públicos» corresponden `CKV_AWS_53` a `CKV_AWS_56` (bloquear ACL públicas, bloquear políticas públicas, ignorar ACL públicas y restringir buckets públicos). `CKV2_AWS_6`, que pide que el bucket tenga un bloqueo de acceso público efectivo, también pasó al corregir, porque depende de esos mismos cuatro valores.

**4. ¿Qué ventaja tiene detectar un problema en el código, antes del `apply`, frente a detectarlo en la nube?**

Es más barato, más rápido y más seguro. Si el bucket público se detecta en el código, se corrige cambiando una línea y nunca existe en la nube. Si se detecta después del `apply`, el bucket ya estuvo expuesto en internet durante un tiempo (con riesgo real de fuga de datos), probablemente generó costos, hay que hacer otro despliegue para corregirlo y puede que nadie lo note hasta que sea tarde. Como dice la diapositiva de Policy as Code, la idea es validar la infraestructura antes de aplicarla y bloquear automáticamente las configuraciones inseguras.

**5. ¿En qué paso del pipeline de la diapositiva va `validar.sh` y qué paso humano viene después?**

Va en el paso **2 · Validar**, donde el pipeline corre `fmt`, `validate`, el plan y las políticas de forma automática después de cada commit. Nuestro script hace formato, validación, pruebas y política; en un pipeline real también generaría el `plan`. Después viene el paso humano **3 · Revisar**: una persona del equipo lee el plan propuesto y lo aprueba, como hizo nuestro revisor del plan en cada fase. Solo entonces llega el paso **4 · Aplicar**, donde se ejecuta el `apply` de forma controlada.

---

## Fase 9 · Auditoría cruzada y cierre

**Roles en esta fase:** Operadora: Laura · Navegante y Bitácora: Sara · Revisor del plan: Juanjo

### Parte A · Auditoría

**1. Intercambio de repositorios.** Se realizo el cambiom con el **Grupo 5** (Susana Eguis Muñoz y Samuel Tabares). Nosotros auditamos https://github.com/suueguis/iac-taller-g5 y ellos auditaron el nuestro, https://github.com/Sarasaenz12/iac-taller-g2.

**2 y 3. Nuestra auditoría al Grupo 5.** Está completa en [`AUDITORIA.md`](AUDITORIA.md), con la evidencia de cada fila, y se la compartimos al Grupo 5. Resumen:

| Anti-patrón | Resultado |
|---|---|
| Tocar a mano | Cumple |
| State sin proteger | Cumple |
| Copiar y pegar | Cumple |
| Secretos en el código | Cumple, con una reserva (no pudimos buscar su contraseña real) |
| Aplicar sin leer el plan | Cumple |
| Un solo archivo gigante | Cumple |

Hallazgos: (1) código muerto (`local.etiquetas` y la variable raíz `imagen` sin uso) y las `labels` de la Fase 5 que se perdieron al pasar al módulo; (2) la evidencia de secretos y del bloqueo no se puede reproducir tal como está escrita, porque los comandos usan el marcador `<CLAVE>`. Recomendación: conectar las etiquetas a través del módulo, borrar la variable sin uso y agregar `tflint` a `validar.sh` para que detecte declaraciones sin uso.

**Auditoría que nos hizo el Grupo 5** (su `AUDITORIA.md`, sobre nuestro commit `43c4a00`):

| Anti-patrón | Resultado que nos dieron |
|---|---|
| Tocar a mano | Cumple |
| State sin proteger | Cumple |
| Copiar y pegar | Cumple |
| Secretos en el código | Cumple, con una reserva (no tienen nuestra contraseña real) |
| Aplicar sin leer el plan | **No cumple, en dos puntos** |
| Un solo archivo gigante | Cumple |

**Nuestra respuesta a sus hallazgos:**

- **Hallazgo 1, `apply` sin aprobación anotada.** Tienen razón en los dos puntos. En la Fase 3, el `terraform apply` sin cambios (`No changes`) no tiene anotada la aprobación del revisor. En la Fase 8, la prueba `despliegue_real` de `terraform test` crea y destruye un contenedor de verdad, y `terraform test` no muestra ninguna línea `Plan:` que el revisor pueda leer. No vamos a agregar aprobaciones a fases pasadas: la bitácora debe mostrar lo que de verdad quedó registrado. Desde esta fase anotamos el `Plan:` y la aprobación de cada `destroy` (Parte B).
- **Hallazgo 2, la nota de la contraseña.** También tienen razón: nuestra nota de la Fase 7 decía que buscar la contraseña de ejemplo de la guía «siempre dará vacío», pero la nota misma escribía ese texto, así que el comando de la guía sí devolvía el commit `838b57d`. Corregimos la nota para que ya no lo escriba. El commit `838b57d` lo conserva en el historial, y no lo reescribimos porque el repositorio ya estaba publicado y compartido con ellos. No es una fuga: nuestra contraseña real no aparece en ningún commit.
- **Detalles menores que vieron.** Coinciden con lo que les encontramos a ellos: también tenemos `local.etiquetas` y la variable raíz `imagen` sin uso, y nuestras `labels` de la Fase 5 se perdieron al pasar al módulo en la Fase 6. Además, `validar.sh` está guardado sin permiso de ejecución, no tenemos `.gitattributes` para fijar los saltos de línea a LF y el `host` de Docker deja el código atado a Windows. Encontrar en ellos el mismo error que teníamos nosotros fue lo más útil de la auditoría.

### Parte B · Cierre

**4. Destrucción de cada ambiente.** Al retomar la sesión, el computador se había reiniciado y Docker Desktop estaba cerrado, así que los contenedores del taller estaban detenidos (`Exited (255)`). El primer intento falló porque el backend también estaba detenido:
```
$ terraform workspace select dev && terraform destroy
╷
│ Error: dial tcp [::1]:5433: connectex: No connection could be made because the target machine actively refused it.
╵
```
Sin el backend, Terraform no pudo leer el state ni saber qué destruir. Encendimos el backend y repetimos:
```
$ docker start tf-state-g2
tf-state-g2
```

*dev*
```
$ terraform workspace select dev && terraform destroy
Switched to workspace "dev".
...
  # module.sitio["tienda"].docker_container.this will be destroyed
  # module.sitio["tienda"].docker_image.this will be destroyed

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources in workspace "dev"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

module.sitio["tienda"].docker_container.this: Destruction complete after 0s
module.sitio["tienda"].docker_image.this: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```
**Juanjo:** «Workspace dev: aprobado 0 a crear, 0 a cambiar, 2 a destruir (el contenedor `tienda-g2-dev` y su imagen)».

*staging*
```
$ terraform workspace select staging && terraform destroy
Switched to workspace "staging".
...
  # module.sitio["blog"], ["docs"] y ["tienda"]: docker_container.this y docker_image.this will be destroyed

Plan: 0 to add, 0 to change, 6 to destroy.

Do you really want to destroy all resources in workspace "staging"?
  Enter a value: yes
...
Destroy complete! Resources: 6 destroyed.
```
**Juanjo:** «Workspace staging: aprobado 0 a crear, 0 a cambiar, 6 a destruir (3 contenedores y 3 imágenes)».

*prod*
```
$ terraform workspace select prod && terraform destroy
Switched to workspace "prod".
...
  # module.sitio["blog"], ["docs"] y ["tienda"]: docker_container.this y docker_image.this (nginx:1.27-alpine) will be destroyed

Plan: 0 to add, 0 to change, 6 to destroy.

Do you really want to destroy all resources in workspace "prod"?
  Enter a value: yes
...
Destroy complete! Resources: 6 destroyed.

$ terraform workspace select default
Switched to workspace "default".
```
**Juanjo:** «Workspace prod: aprobado 0 a crear, 0 a cambiar, 6 a destruir (3 contenedores y 3 imágenes con nginx 1.27)».

(Los planes de destrucción se resumieron: se dejó qué recurso se destruye y la línea `Plan:`.) No importó que los sitios estuvieran detenidos: el plan los mostraba con `must_run = false` y `exit_code = 255`, y `destroy` los eliminó igual.

**5. Verificación: solo queda el backend**
```
$ docker ps -a
CONTAINER ID   IMAGE                     COMMAND                  CREATED        STATUS                      PORTS                    NAMES
90237a106fc2   postgres:17-alpine        "docker-entrypoint.s…"   3 days ago     Up 46 seconds               0.0.0.0:5433->5432/tcp   tf-state-g2
...
```
Del grupo solo queda `tf-state-g2`; ya no hay ningún `tienda-g2-*`, `blog-g2-*`, `docs-g2-*`, `web-g2` ni `clickops-g2`. (Se omitieron las líneas de contenedores de otros proyectos de este computador, que no son del taller.)

**6. Eliminación del backend** (solo después de los tres `destroy`)
```
$ docker rm -f tf-state-g2
tf-state-g2

$ docker ps -a | grep g2

$
```
`docker ps -a | grep g2` no devolvió ninguna línea: ya no queda ningún contenedor del grupo, ni siquiera el backend. **Punto de control cumplido.**

### Respuestas

**1. ¿Qué anti-patrón encontraron en el otro grupo? ¿Y cuál les señalaron a ustedes?**

Al Grupo 5 no le encontramos ningún anti-patrón incumplido: los seis cumplen, el de secretos con la reserva de que no pudimos buscar su contraseña real. Nuestros hallazgos fueron de calidad del código: dejaron declaraciones sin uso y las etiquetas de la Fase 5 se perdieron al pasar al módulo, y su evidencia de secretos y bloqueo no se puede reproducir tal como está escrita. A nosotros nos señalaron **«Aplicar sin leer el plan»** en dos puntos: el `apply` sin cambios de la Fase 3 sin aprobación anotada y la prueba `despliegue_real` de la Fase 8, que despliega de verdad sin `Plan:` ni aprobación. También que nuestra nota sobre la contraseña de ejemplo la escribía, y por eso el comando de la guía devolvía un resultado. Los dos hallazgos son correctos; la respuesta está arriba.

**2. ¿Qué habría pasado si eliminaban el contenedor del backend antes de ejecutar los `destroy`?**

Se habría perdido el state de los tres ambientes, porque vivía dentro de ese contenedor de PostgreSQL. Sin state, Terraform ya no sabe qué recursos creó: o falla al conectarse, o con un backend nuevo y vacío cree que no hay nada que destruir. Los siete sitios habrían quedado huérfanos, corriendo sin que ninguna herramienta los administre, y la única forma de quitarlos sería borrarlos a mano con `docker rm -f`, que es justo el anti-patrón «Tocar a mano». Lo vivimos en pequeño en esta fase: con el backend solo detenido, el primer `destroy` falló con `connection refused`, y Terraform no pudo hacer nada hasta que volvimos a encender `tf-state-g2`. Si lo hubiéramos borrado, no habría habido forma de encenderlo. En una nube real sería peor: recursos olvidados que siguen cobrando y que nadie sabe que existen.

**3. ¿Por qué `destroy` exige la misma disciplina de lectura que `apply`?**

Porque también cambia la infraestructura real, y no tiene vuelta atrás: el propio Terraform lo advierte con «There is no undo». Un `destroy` en el workspace equivocado borra producción en lugar de dev, y como el código es el mismo para los tres ambientes, lo único que lo distingue es leer el workspace que muestra la pregunta («in workspace "prod"») y la cuenta del plan. Por eso Juanjo confirmó, antes de cada `yes`, el workspace y que la cifra coincidiera con lo que esperábamos (2, 6 y 6). En un proyecto real, `destroy` también se lleva datos: una base de datos destruida no se recrea con otro `apply`. Un `apply` mal leído casi siempre se corrige con otro `apply`; un `destroy` mal leído, no.

---
