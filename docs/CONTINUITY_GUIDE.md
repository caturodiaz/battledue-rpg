# Battle Due: guía de continuidad con ChatGPT

Este documento permite retomar el desarrollo en una conversación nueva sin depender de que ChatGPT recuerde conversaciones anteriores.

## 1. Fuente de verdad

El estado real del proyecto está en los archivos actuales del repositorio.

Antes de sugerir cambios:
1. Revisar este documento y `README.md`.
2. Revisar `docs/DEVELOPMENT.md`.
3. Consultar los scripts, escenas y datos relacionados con la tarea.
4. Comprobar el estado de Git y no asumir que el código coincide con una conversación anterior.

Si falta información, pedir el archivo o la salida de terminal necesaria. No inventar funciones, nodos, rutas, controles ni resultados de pruebas.

## 2. Entorno y ubicación

- Proyecto: Battle Due.
- Motor: Godot 4.7.2.
- Sistema de trabajo: Ubuntu.
- Carpeta local habitual: `~/Escritorio/battledue_rpg`.
- Repositorio: https://github.com/caturodiaz/battledue-rpg
- Rama principal: `main`.
- Personaje trabajado: Negotu.
- Escenas principales identificadas: `scenes/main.tscn` y `scenes/fighter.tscn`.
- Scripts principales identificados: `scripts/main.gd` y `scripts/fighter.gd`.

## 3. Estado conocido al preparar esta guía

- Se publicó la versión inicial del proyecto.
- El commit inicial conocido es `f93b63b` (`Initial Battle Due project`).
- La secuencia de salto tiene fases diferenciadas: despegue, ascenso, ápice, caída y aterrizaje.
- El usuario probó la secuencia y confirmó que se veía bien y se sentía fluida.
- La lógica de salto y aterrizaje está implementada en `scripts/fighter.gd`, junto con cambios relacionados en `scenes/fighter.tscn`.
- Las imágenes auxiliares de inspección y los backups locales están excluidos mediante `.gitignore`.

Este estado es una referencia histórica, no una garantía de que los archivos actuales sigan exactamente iguales. Comprobar Git antes de intervenir.

## 4. Forma de trabajar

- Explicar en español.
- Dar instrucciones claras, secuenciales y fáciles de seguir.
- Cuando convenga, proporcionar bloques de terminal listos para copiar y pegar.
- Preferir cambios pequeños, comprobables y reversibles.
- Indicar qué hace cada bloque y qué resultado se espera.
- No afirmar que se ejecutó o probó algo si el usuario no lo confirmó o no hay evidencia.
- No reemplazar archivos enteros si basta un cambio localizado.
- Antes de modificar una mecánica existente, revisar cómo funciona actualmente.
- Preservar las funcionalidades que ya funcionan, especialmente las animaciones y transiciones del personaje.
- Si una solución implica una decisión de diseño, explicar brevemente las alternativas y recomendar una.
- No dar por hecho que el usuario quiere editar imágenes manualmente con GIMP u otra herramienta.
- No hacer `git push`, publicar archivos ni cambiar el repositorio remoto sin autorización explícita para esa acción.

## 5. Diagnóstico inicial en cada conversación

Pedir al usuario que ejecute este bloque y comparta la salida:

```bash
cd ~/Escritorio/battledue_rpg

echo "=== ESTADO DE GIT ==="
git --no-pager status --short --branch

echo
echo "=== ÚLTIMO COMMIT ==="
git --no-pager log -1 --oneline

echo
echo "=== REMOTO ==="
git remote -v
```

Si la carpeta no existe, pedir la ubicación correcta en lugar de asumir otra ruta.

Antes de cambios importantes, comprobar si hay modificaciones locales sin guardar. No descartarlas ni sobrescribirlas.

## 6. Flujo recomendado para cada tarea

1. Definir el comportamiento que se quiere conseguir.
2. Inspeccionar los archivos relacionados.
3. Identificar la causa del problema o el cambio mínimo necesario.
4. Aplicar una modificación acotada.
5. Revisar diferencias con `git diff`.
6. Ejecutar el proyecto en Godot y probar el comportamiento cuando sea posible.
7. Corregir los errores observados.
8. Resumir qué cambió, qué se probó y qué queda pendiente.
9. Proponer un commit solo cuando el usuario esté conforme.

No mezclar varias mecánicas grandes en un único cambio si pueden probarse por separado.

## 7. Comandos de Git útiles

Consultar cambios:

```bash
git status --short --branch
git diff
git diff --stat
```

Preparar y revisar los archivos de un commit:

```bash
git add -A
git diff --cached --check
git diff --cached --stat
git diff --cached --name-only
```

Crear un commit local, solo después de revisar los cambios:

```bash
git commit -m "Describe el cambio realizado"
```

Publicar cambios requiere autorización y una revisión previa:

```bash
git push
```

No usar `git reset --hard`, `git clean -fd` ni otros comandos destructivos sin explicar sus consecuencias y confirmar que no se perderán cambios necesarios.

## 8. Qué debe incluir el cierre de cada sesión

Al terminar una tarea, preparar un resumen que pueda copiarse en la siguiente conversación:

- Objetivo de la tarea.
- Archivos modificados.
- Cambios realizados.
- Pruebas ejecutadas y sus resultados.
- Problemas pendientes.
- Último commit y estado de Git.
- Próximo paso recomendado.

Actualizar esta guía si cambia de forma importante la estructura, el estado técnico o el flujo de trabajo del proyecto.

## 9. Mensaje para iniciar una conversación nueva

Copiar el siguiente texto en una conversación nueva:

---

Quiero continuar el desarrollo de mi videojuego Battle Due en Godot 4.7.2.

Repositorio: https://github.com/caturodiaz/battledue-rpg

Trabajo local habitual en Ubuntu:
`~/Escritorio/battledue_rpg`

Primero necesito que revises el estado actual del proyecto y la documentación, especialmente:
- `README.md`
- `docs/DEVELOPMENT.md`
- `docs/CONTINUITY_GUIDE.md`

Después, inspeccioná los archivos relacionados con la tarea que te indique. No asumas que recordás el estado exacto de otra conversación: usá los archivos actuales como fuente de verdad.

Quiero instrucciones en español, paso a paso y, cuando sea útil, bloques de terminal listos para copiar y pegar. Hacé cambios pequeños y comprobables, preservá las funcionalidades existentes y no afirmes que probaste algo si no se ejecutó realmente.

No publiques cambios en GitHub ni ejecutes operaciones destructivas sin mi autorización.

**Mi objetivo para esta sesión es:**
[ESCRIBIR AQUÍ LA TAREA]

**Contexto adicional o error actual:**
[PEGAR AQUÍ LOS MENSAJES DE ERROR, CAPTURAS O RESULTADOS RELEVANTES]

---
