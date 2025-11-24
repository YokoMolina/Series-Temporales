library(readxl)
library(tidyverse)
library(tsibble)
library(fabletools)
library(forecast)
library(fpp3)
library(tseries)
library(MuMIn)
library(TSA)

############BASE DE DATOS##########################
#Lectura de var weekly sales
#ruta_completa <- "C:\\Users\\geoco\\OneDrive - Escuela Politécnica Nacional\\YOKO!!\\POLI\\2023-B\\Series Temp\\Proyecto\\ProyectoSeriesTiempo"
#ruta_completa <- file.path(getwd(), "train.csv")

#data <- read.csv(ruta_completa, sep = ";")

data <- read.csv("train.csv",sep = ";") 
#ELEGIMOS STORE 13, Dept 1
data13 <- data %>% filter(data$Store==13 & data$Dept==4) %>% mutate(Date=as.Date(Date,"%d/%m/%Y"))
#Lectura otras variables
dataf <- read.csv('features.csv',sep = ";")
dataf13 <- dataf %>% filter(dataf$Store==13)%>% mutate(Date=as.Date(Date,"%d/%m/%Y"))%>% filter(Date<=as.Date("2012-10-26"))
#view(dataf13)
#view(data13)
########SERIE WEEKLY SALES#########################
yt <- data13 %>% select(Date , Weekly_Sales)%>% as_tsibble(index=Date)
autoplot(yt,.vars = Weekly_Sales)

# PRUEBAS ACF Y PACF

acf(yt)
pacf(yt)

#PROBAR ESTACIONARIEDAD
yt %>% features(Weekly_Sales,unitroot_kpss)
#no es estacionaria, valor p menor 0.01
yt %>% features(Weekly_Sales,unitroot_ndiffs)
#se necesita una diferenciacion


# 1) Ajustemos un modelo AR(p) a la serie de tiempo "ventas semanales"

#View(data13)


modelo_1 <- yt %>%
  model(ARIMA(Weekly_Sales ~ pdq(2,0,0))) 


report(modelo_1)
gg_tsresiduals(modelo_1)

#Residuos vs predichos
plot(residuals(modelo_1)$.resid,fitted(modelo_1)$.fitted) 
#no existe suficiente evidencia para afirmar que los residuos son aleatorios




# 2) Ajustemos un modelo ARMA(p,q) a la serie de tiempo "ventas semanales"

modelo_2 <- yt %>%
  model(ARIMA(Weekly_Sales ~ pdq(3,0,2))) 


report(modelo_2)
gg_tsresiduals(modelo_2)

#Residuos vs predichos
plot(residuals(modelo_2)$.resid,fitted(modelo_2)$.fitted) #los residuos son aleatorios


# 3) Ajustemos un modelo ARIMA(p,d,q) a la serie de tiempo "ventas semanales"


modelo_3 <- yt %>%
  model(ARIMA(Weekly_Sales ~ pdq(1,1,5))) 


report(modelo_3)
gg_tsresiduals(modelo_3)

#Residuos vs predichos
plot(residuals(modelo_3)$.resid,fitted(modelo_3)$.fitted) #los residuos son aleatorios


#_____________________________________-
#ajuste automatico (mejor)
modelo_4 <- yt %>%
  model(ARIMA(Weekly_Sales)) 

report(modelo_4)
gg_tsresiduals(modelo_4)

#Residuos vs predichos
plot(residuals(modelo_4)$.resid,fitted(modelo_4)$.fitted) 

#la aleatoriedad de los residuos se va haciendo más evidente mientras el modelo va mejorando



#__________________________________________
# RESULTADOS


# Hagamos la comparacion de los 3 modelos

comparar_mode <- yt %>% model(ar2=ARIMA(Weekly_Sales ~ pdq(2,0,0)),
                              arma=ARIMA(Weekly_Sales ~ pdq(3,0,2)),
                              arima = ARIMA(Weekly_Sales ~ pdq(0,1,5))) 

report(comparar_mode)



## analicemos las gráficas de los 4 modelos

#modelo 1
yt %>% ggplot(aes(x=Date))+geom_line(aes(y=Weekly_Sales, colour = "red"))+geom_line(aes(y=fitted(modelo_1)$.fitted, colour = "blue"))

#modelo 2
yt %>% ggplot(aes(x=Date))+geom_line(aes(y=Weekly_Sales, colour = "red"))+geom_line(aes(y=fitted(modelo_2)$.fitted, colour = "blue"))

#modelo 3
yt %>% ggplot(aes(x=Date))+geom_line(aes(y=Weekly_Sales, colour = "red"))+geom_line(aes(y=fitted(modelo_3)$.fitted, colour = "blue"))

#modelo 4
yt %>% ggplot(aes(x=Date))+geom_line(aes(y=Weekly_Sales, colour = "red"))+geom_line(aes(y=fitted(modelo_4)$.fitted, colour = "blue"))

# ANALICEMOS LOS VALORES DE AIC BIC AICc
#______________________________-
# modelo 1
#del metodo reporT se obtiene:
#AIC=2680.44
#BIC=2692.3
#AICc=2680.73

# modelo 2
#AIC=2676.3
#BIC=2697.04
#AICc=2677.13

# modelo 3
#AIC=2644.88
#BIC=2665.57
#AICc=2645.72

# modelo 4
#AIC=2642.96
#BIC=2660.69
#AICc=2643.58

#grafiquemos todas la series

#Grafico serie predicha y real
yt %>% ggplot(aes(x=Date))+geom_line(aes(y=Weekly_Sales,colour='#F324ED'))+geom_line(aes(y=fitted(modelo_4)$.fitted,colour="blue"))+geom_line(aes(y=fitted(modelo_3)$.fitted,colour="green"))+scale_colour_hue(labels = c("Datos", "ARIMA(0,1,5)","ARIMA(3,1,2)"))+guides(color = guide_legend(title = "Modelo"))






######SERIE TEMPERATURE#########################
x1t <- dataf13 %>% select(Date,Temperature) %>% as_tsibble(index = Date)
#Graficas
autoplot(x1t,.vars = Temperature)
acf(x1t)
pacf(x1t)

x1t %>% features(Temperature,unitroot_kpss)



################Tendencia constante
fit1 <- lm(x1t$Temperature~1)
plot(x1t,type="l")
abline(fit1)
#Residuos
r1 <- fit1$residuals
#1. Independencia errores
acf(r1) #existen dependencia positiva
runs(r1) #el valor p es muy bajo por tanto no son independientes
#2. Errores centrados y var constante
plot(r1,type='o') #vemos que los errores estan centrados con varianza constante
#3. #Residuos vs predichos
plot(rstudent(fit1),fitted(fit1)) #vemos que los residuos no son aleatorios
#4. Normalidad de residuos
hist(r1) #la grafica no indica normalidad
qqnorm(r1,pch=1,frame=FALSE)
qqline(r1,col='steelblue',lwd=2) ##qqplot indica que no hay normalidad
ks.test(r1,"pnorm") #Como valor p es muy pequeño vemos que no sigue una distribución normal

#Concluimos que este modelo no es aceptable, ya que no se cumple indepencia, aleatoriedad y normalidad de los residuos



##########Regresion Lineal
fit2 <- lm(x1t$Temperature~x1t$Date)
summary(fit2)
plot(x1t,type='l')
abline(fit2)
#Residuos
r2 <- fit2$residuals
#1. Independencia errores
acf(r2) #existen dependencia positiva
runs(r2) #el valor p es muy bajo por tanto no son independientes
#2. Errores centrados y var constante
plot(r2,type='o') #vemos que los errores estan centrados con varianza constante
#3. #Residuos vs predichos
plot(rstudent(fit2),fitted(fit2)) #vemos que los residuos son aleatorios
#4. Normalidad de residuos
hist(r2) #la grafica no indica normalidad
qqnorm(r2,pch=1,frame=FALSE)
qqline(r2,col='steelblue',lwd=2) ##qqplot indica que no hay normalidad
ks.test(r2,"pnorm") #Como valor p es muy pequeño vemos que no sigue una distribución normal

#Concluimos que este modelo no es aceptable, pues no se cumple independencia ni normalidad de los residuos


################ AR(1) automaticamente
fit3 <- x1t %>% model(ARIMA(Temperature))
report(fit3)
gg_tsresiduals(fit3)
#este gráfico ya me indica (3 cosas): independencia, normalidad, centrados y var constante de los residuos
#Residuos vs predichos
plot(residuals(fit3)$.resid,fitted(fit3)$.fitted) #los residuos son aleatorios

#concluyo que el modelo es aceptable


################RESULTADOS
#comparar AIC Y BIC
AIC(fit1)
BIC(fit1)
AICc(fit1)

AIC(fit2)
BIC(fit2)
AICc(fit2)

report(fit3)

#Vemos que el modelo aceptable tiene los menores AIC, BIC, AICc por tanto es el mejor modelo


#Grafico serie predicha y real
x1t %>% ggplot(aes(x=Date))+geom_line(aes(y=Temperature,colour='red'))+geom_line(aes(y=fitted(fit3)$.fitted,colour="blue"))+geom_line(aes(y=fitted(fit1),colour="green"))+geom_line(aes(y=fitted(fit2),colour="yellow"))+scale_colour_hue(labels = c("Datos", "Constante","AR(1)","Regresión Lineal"))+guides(color = guide_legend(title = "Modelo"))
                                                                                                                                                                                                      