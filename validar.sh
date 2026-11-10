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
