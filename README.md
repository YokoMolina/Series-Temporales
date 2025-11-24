# Series Temporales

Este repositorio contiene un proyecto de análisis y modelamiento de **series temporales**, aplicando técnicas estadísticas y econométricas para explorar patrones, estimar modelos y hacer predicciones.

## Objetivos

- Realizar análisis descriptivo de series de tiempo: tendencia, estacionalidad, ciclos e irregularidad.  
- Ajustar modelos estocásticos clásicos (AR, MA, ARMA, ARIMA) para modelar la dinámica temporal.  
- Evaluar la validez de los supuestos del modelo (estacionariedad, autocorrelación, heterocedasticidad).  
- Realizar pronósticos a futuro basados en los modelos estimados.  
- Comparar distintos modelos y seleccionar el más adecuado para las series analizadas.

## Modelos utilizados

En el proyecto se han utilizado varios modelos de series temporales, entre ellos:

- **Modelos autorregresivos (AR)**.  
- **Modelos de media móvil (MA)**.  
- **Modelos combinados ARMA**.  
- **Modelos integrados ARIMA** (para series no estacionarias).  
- **Modelos estacionales (SARIMA)**, si las series presentan patrones periódicos.  
- (Opcional) Modelos adicionales para validar o mejorar el pronóstico (por ejemplo, suavizado exponencial, modelos de descomposición).

## Flujo de trabajo

1. **Carga y preprocesamiento de datos**  
   - Lectura de la serie temporal.  
   - Transformaciones necesarias (diferenciación, logaritmos, descomposición).  
2. **Análisis exploratorio**  
   - Gráficos de la serie: línea de tiempo, autocorrelación (ACF), autocorrelación parcial (PACF).  
   - Descomposición de la serie en componentes de tendencia, estacionalidad y residual.  
3. **Estimación del modelo**  
   - Selección del orden de los modelos AR, MA, ARIMA mediante criterios (AIC, BIC).  
   - Ajuste de los modelos.  
4. **Diagnóstico del modelo**  
   - Verificación de la estacionariedad.  
   - Pruebas sobre los residuos: autocorrelación, normalidad, heterocedasticidad.  
5. **Pronóstico**  
   - Generación de pronósticos para varios periodos futuros.  
   - Evaluación de la precisión de los pronósticos con métricas como RMSE, MAE, etc.  
6. **Interpretación de resultados**  
   - Interpretación de los parámetros estimados.  
   - Conclusiones sobre qué modelo funciona mejor, y posibles implicaciones prácticas.

## Cómo usar

1. Clona el repositorio:  
   ```bash
   git clone https://github.com/YokoMolina/Series-Temporales.git
