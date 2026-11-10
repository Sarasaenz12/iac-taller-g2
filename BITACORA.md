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
