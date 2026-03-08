# ==============================================================================
# SCRIPT: 01_Cars93.R 
# ==============================================================================

# 1. CONFIGURACIÓN DE DIRECTORIOS
# -----------------------------------------------------------------------------
root_path <- "C:\\Users\\iavit\\OneDrive\\ESPOL\\Maestria en Estadistica Aplicada\\Clases Maestria en Estadistica Aplicada\\Modulo 9\\TEC ESTADIS AVANZ PARA MINERIA DE DATOS\\METODOS DE CLASIFICACION\\Trab Final\\desa"
out_path  <- file.path(root_path, "salidas")

# Crear carpeta de salidas si no existe
if (!dir.exists(out_path)) dir.create(out_path, recursive = TRUE)

# Definir archivos de salida
log_file   <- file.path(out_path, "resultados_analisis.txt")
plot_file  <- file.path(out_path, "importancia_variables.png")

# Iniciar captura de consola a un archivo de texto
sink(log_file, split = TRUE) 

cat("========================================================\n")
cat("INICIO DEL INFORME DE CLASIFICACIÓN - RANDOM FOREST\n")
cat("Fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("========================================================\n\n")

# 2. CARGA DE LIBRERÍAS Y DATOS
# -----------------------------------------------------------------------------
suppressMessages({
  library(MASS)
  library(randomForest)
  library(caret)
})

data(Cars93)

# Selección de variables
vars_numericas  <- c("Price", "MPG.city", "MPG.highway", "EngineSize",
                     "Horsepower", "RPM", "Rev.per.mile", "Fuel.tank.capacity",
                     "Passengers", "Length", "Wheelbase", "Width",
                     "Turn.circle", "Weight")

vars_categoricas <- c("Type", "DriveTrain", "Origin", "Cylinders",
                      "Man.trans.avail")

variable_objetivo <- "AirBags"

df <- Cars93[, c(variable_objetivo, vars_numericas, vars_categoricas)]

# 3. ANÁLISIS DESCRIPTIVO
# -----------------------------------------------------------------------------
cat("### A. EXPLORACIÓN INICIAL ###\n")
cat("Dimensiones:", nrow(df), "filas x", ncol(df), "columnas\n")
cat("Valores perdidos totales:", sum(is.na(df)), "\n\n")

cat("Distribución de la variable objetivo (AirBags):\n")
print(table(df$AirBags))
cat("\n")

# 4. PREPARACIÓN DE DATOS (TRAIN-TEST 50/50)
# -----------------------------------------------------------------------------
set.seed(123)
indices_train <- createDataPartition(df$AirBags, p = 0.5, list = FALSE)

train_data <- df[indices_train, ]
test_data  <- df[-indices_train, ]

cat("### B. SEPARACIÓN DE DATOS ###\n")
cat("Entrenamiento:", nrow(train_data), "obs\n")
cat("Prueba:", nrow(test_data), "obs\n\n")

# 5. ENTRENAMIENTO DEL MODELO
# -----------------------------------------------------------------------------
p <- ncol(train_data) - 1
mtry_default <- floor(sqrt(p))

set.seed(123)
rf_model <- randomForest(
  AirBags ~ ., 
  data = train_data, 
  ntree = 500, 
  mtry = mtry_default, 
  importance = TRUE
)

cat("### C. MODELO RANDOM FOREST ###\n")
print(rf_model)
cat("\n")

# 6. EVALUACIÓN CON EL CONJUNTO TEST
# -----------------------------------------------------------------------------
pred_test <- predict(rf_model, newdata = test_data)
cm <- confusionMatrix(pred_test, test_data$AirBags)

cat("### D. MÉTRICAS DE DESEMPEÑO (TEST) ###\n")
cat("Accuracy:", round(cm$overall["Accuracy"], 4), "\n")
cat("Kappa:", round(cm$overall["Kappa"], 4), "\n\n")

cat("Métricas por Clase:\n")
print(round(cm$byClass[, c("Sensitivity", "Specificity", "F1")], 4))
cat("\n")

# 7. IMPORTANCIA DE VARIABLES Y GRÁFICOS
# -----------------------------------------------------------------------------
imp <- importance(rf_model)
cat("### E. IMPORTANCIA DE VARIABLES (Top 10) ###\n")
top_imp <- imp[order(imp[, "MeanDecreaseAccuracy"], decreasing = TRUE), ]
print(head(round(top_imp, 3), 10))

# Guardar Gráfico en PNG
png(filename = plot_file, width = 800, height = 600)
varImpPlot(rf_model, 
           main = "Importancia de Variables - Cars93", 
           col = "darkblue", 
           pch = 19)
dev.off()

cat("\n[INFO] Gráfico guardado en:", plot_file, "\n")
cat("========================================================\n")
cat("FIN DEL PROCESO\n")

# Detener la captura de consola
sink()