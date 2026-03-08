# ==============================================================================
# SCRIPT: 00_conn_r_git.R 
# ==============================================================================

# --- [1] Dependencias ---
deps <- c("usethis", "gitcreds", "processx", "desc")
new_deps <- deps[!(deps %in% installed.packages()[, "Package"])]
if (length(new_deps)) install.packages(new_deps)
invisible(lapply(deps, library, character.only = TRUE))

# --- [2] Variables de Identidad ---
nombre_repo <- "Cars93-RandomForest-Classification" 
email_user  <- "ejemplo.com"
nombre_user <- "iviterirambay"

# --- [3] Ruta base del proyecto ---
ruta_proyecto <- "C:/Users/iavit/OneDrive/ESPOL/Maestria en Estadistica Aplicada/Clases Maestria en Estadistica Aplicada/Modulo 9/TEC ESTADIS AVANZ PARA MINERIA DE DATOS/METODOS DE CLASIFICACION/Trab Final/desa"

setwd(ruta_proyecto)
message("Directorio de trabajo: ", getwd())

# --- [4] SOLUCIÓN: Eliminar .git anidados en subcarpetas ---
# Esto es lo que causa que "r" aparezca como submódulo en GitHub
subcarpetas <- c("informe", "r", "salidas")

for (carpeta in subcarpetas) {
  git_anidado <- file.path(carpeta, ".git")
  if (dir.exists(git_anidado)) {
    unlink(git_anidado, recursive = TRUE, force = TRUE)
    message("  .git anidado eliminado dentro de: ", carpeta)
  } else {
    message("  Sin .git anidado en: ", carpeta, " (OK)")
  }
}

# --- [5] Limpieza Profunda del repo principal ---
if (file.exists(".git/index.lock")) {
  file.remove(".git/index.lock")
  message("Bloqueo index.lock eliminado.")
}
if (dir.exists(".git")) {
  unlink(".git", recursive = TRUE, force = TRUE)
  message("Historial antiguo del repo principal eliminado.")
}

# --- [6] Reinicialización Automatizada ---
system("git init")
system(paste0('git config user.name "',  nombre_user, '"'))
system(paste0('git config user.email "', email_user,  '"'))

# Optimizaciones para archivos grandes
system("git config http.postBuffer 524288000")
system("git config core.compression 0")

# --- [7] Configuración de Archivos y Higiene ---
if (!file.exists("DESCRIPTION")) {
  usethis::use_description(
    fields = list(Package = nombre_repo, Title = "Setup Project"),
    check_name = FALSE
  )
}

# .gitignore: excluir archivos pesados y temporales
usethis::use_git_ignore(c(
  ".Rhistory",
  ".RData",
  ".Rproj.user",
  ".DS_Store",
  "*.log",
  "data/*.txt",
  ".env"
))

# --- [8] Verificar que no haya submódulos registrados ---
if (file.exists(".gitmodules")) {
  file.remove(".gitmodules")
  message(".gitmodules eliminado para evitar submódulos.")
}

# --- [9] Agregar TODO el contenido al staging area ---
message("Agregando archivos al staging area...")
system("git add .")

# Desregistrar cualquier submódulo que Git haya detectado automáticamente
for (carpeta in subcarpetas) {
  system(paste0("git rm --cached ", carpeta, " --ignore-unmatch"))
  system(paste0("git add ", carpeta, "/"))
}

# Asegurar que archivos .txt pesados no entren
system("git rm --cached data/*.txt --ignore-unmatch")

# --- [10] Commit y Push ---
message("Creando commit...")
system('git commit -m "fix: convert submodules to regular folders - add r scripts correctly"')
system("git branch -M main")

message("Sincronizando con GitHub...")
remote_url <- paste0("https://github.com/", nombre_user, "/", nombre_repo, ".git")
try(system(paste0("git remote add origin ", remote_url)), silent = TRUE)

# Push forzado para reemplazar el historial en la nube
system("git push -f -u origin main")

# ==============================================================================
# FINAL DEL SCRIPT
# ==============================================================================
