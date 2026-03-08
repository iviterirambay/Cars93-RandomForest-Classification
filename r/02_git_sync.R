# ==============================================================================
# 02_git_sync.R
# ==============================================================================

sync_github <- function(
    path_base   = getwd(),
    nombre_user = NULL,
    nombre_repo = NULL,
    rama        = "main",
    mensaje     = paste0("update: Adición de la explicación del proyecto con archivo README.md", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
) {
  old_wd <- getwd(); on.exit(setwd(old_wd))
  setwd(path_base)
  
  if (!is.null(nombre_user) && !is.null(nombre_repo))
    system(paste0("git remote set-url origin https://github.com/", nombre_user, "/", nombre_repo, ".git"))
  
  system("git add .")
  system(paste0('git commit -m ', shQuote(mensaje)))
  system(paste0("git pull origin ", rama, " --rebase"))
  system(paste0("git push origin ", rama))
}


sync_github(
path_base   = "C:\\Users\\iavit\\OneDrive\\ESPOL\\Maestria en Estadistica Aplicada\\Clases Maestria en Estadistica Aplicada\\Modulo 9\\TEC ESTADIS AVANZ PARA MINERIA DE DATOS\\METODOS DE CLASIFICACION\\Trab Final\\desa",
nombre_user = "iviterirambay",
nombre_repo = "Cars93-RandomForest-Classification"
)