install.packages("tidyverse")

if (!requireNamespace("officer", quietly = TRUE)) {
  install.packages("officer")
}
library(officer)
library(tidyverse)
library (DBI)
library(RSQLite)


###############################################################################################################################################################################################################################
# Con anterioridad se creo un archivo .db en DB Browser que contiene dos tablas (municipios y prestadores). Estas tablas deben ser llamadas en R con la ayuda de las librerias DBI y RSQLite.
###############################################################################################################################################################################################################################

    # Crear una nueva base de datos SQLite sin información
    Base_Datos_Prueba <- dbConnect(RSQLite::SQLite(), dbname = "Base_Datos.sqlite")
    
    # Importar datos desde el archivo original creado en DB Browser SQLite a la nueva base de datos. Nota: cambiar la ruta de datos de ser necesario.
    dbExecute(Base_Datos_Prueba, "ATTACH 'D:/PRUEBA ADRES/Base_datos.db' AS original_db") 
   
     # Listar todas las tablas en la base de datos original
    tablas_originales <- dbGetQuery(Base_Datos_Prueba, "SELECT name FROM original_db.sqlite_master WHERE type='table'")
    
    # Crear la nueva tabla copiando datos de la tabla 'municipios' de la base de datos original
    dbExecute(Base_Datos_Prueba, "CREATE TABLE nueva_tabla_municipios AS SELECT * FROM original_db.municipios")
    
    # Crear la nueva tabla copiando datos de la tabla 'prestadores' de la base de datos original
    dbExecute(Base_Datos_Prueba, "CREATE TABLE nueva_tabla_prestadores AS SELECT * FROM original_db.prestadores")
    
    # Confirmación del proceso exitoso
    dbListTables(Base_Datos_Prueba)
    
    # Ejecutar Query SQL para obtener todos los registros de la tabla 'nueva_tabla_prestadores' en la base de datos nueva
    resultado_prestadores <- dbGetQuery(Base_Datos_Prueba, "SELECT * FROM nueva_tabla_prestadores")
    
    # Ejecutar Query SQL para obtener todos los registros de la tabla 'nueva_tabla_municipios' en la base de datos nueva
    resultado_municipios <- dbGetQuery(Base_Datos_Prueba, "SELECT * FROM nueva_tabla_municipios")

###############################################################################################################################################################################################################################
#En este punto disponemos de la información en dos tablas en R que se pueden tratar directamente con codigos del programa, no obstante seguiremos utilizando Queries para realizarlas tablas a utilizar en el analisis
###############################################################################################################################################################################################################################



###############################################################################################################################################################################################################################
# Query 1: Obtener la suma de población y superficie por departamento
###############################################################################################################################################################################################################################

    query_Departamento <- "SELECT Departamento, 
                              SUM(Poblacion) AS total_poblacion_departamento,
                              SUM(Superficie) AS total_superficie_departamento,
                              SUM(Poblacion) / SUM(Superficie) AS densidad_poblacion_km2
                       FROM nueva_tabla_municipios
                       GROUP BY Departamento"

      # Ejecutar la consulta y guardar los resultados en un data frame
      resultados_Departamento <- dbGetQuery(Base_Datos_Prueba, query_Departamento)

###############################################################################################################################################################################################################################
# Query 2: Obtener la suma de población y superficie por región
###############################################################################################################################################################################################################################

    query_Region <- "SELECT Region, 
                         SUM(Poblacion) AS total_poblacion_region,
                         SUM(Superficie) AS total_superficie_region,
                         SUM(Poblacion) / SUM(Superficie) AS densidad_poblacion_km2
                  FROM nueva_tabla_municipios
                  GROUP BY Region"

      # Ejecutar la consulta y guardar los resultados en un data frame
      resultados_Region <- dbGetQuery(Base_Datos_Prueba, query_Region)

###############################################################################################################################################################################################################################
# Queries 3: Obtener el numero de prestadoras por municipio, departamento y region
###############################################################################################################################################################################################################################

# Ejecutar la primera consulta para conocer el numero de prestadoras por municipio, departamento y region

# Consulta para contar el número de prestadoras por región
    query_prestadoras_region <- "SELECT m.Region, COUNT(*) AS Num_Prestadoras
                     FROM nueva_tabla_municipios m
                     JOIN nueva_tabla_prestadores p ON m.Municipio = p.muni_nombre
                     GROUP BY m.Region"
    resultados_prestadoras_region <- dbGetQuery(Base_Datos_Prueba, query_prestadoras_region)

# Consulta para contar el número de prestadoras por departamento
    query_prestadoras_departamento <- "SELECT depa_nombre, COUNT(*) AS cantidad_prestadores
                       FROM prestadores
                       GROUP BY depa_nombre"
    resultados_prestadoras_departamento <- dbGetQuery(Base_Datos_Prueba, query_prestadoras_departamento)

# Consulta para contar el número de prestadoras por municipio
    query_prestadoras_municipio <- "SELECT muni_nombre, COUNT(*) AS cantidad_prestadores
                       FROM prestadores
                       GROUP BY muni_nombre"
    resultados_prestadoras_municipio<- dbGetQuery(Base_Datos_Prueba, query_prestadoras_municipio)
    
    # Query para contar municipios con solo una prestadora
    query_municipios_una_prestadora <- "SELECT COUNT(*) AS municipios_con_una_prestadora
                                    FROM (
                                        SELECT muni_nombre, COUNT(*) AS cantidad_prestadores
                                        FROM prestadores
                                        GROUP BY muni_nombre
                                        HAVING COUNT(*) = 1
                                    ) AS municipios_una_prestadora"
    
    # Ejecutar la consulta y guardar el resultado en un data frame
    resultado_municipios_una_prestadora <- dbGetQuery(Base_Datos_Prueba, query_municipios_una_prestadora)
    
    
    
    

###############################################################################################################################################################################################################################
# Queries 4: Obtener el numero de prestadoras por las variables clrp_monbre, caracter, naju_nombre, numero_sede_principal nacional
###############################################################################################################################################################################################################################

# Ejecutar la primera consulta para caracter y guardar los resultados en un data frame
    query_clpr_nombre_NAC <- "SELECT  clpr_nombre, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE clpr_nombre IS NOT NULL AND clpr_nombre != ''
                          GROUP BY  clpr_nombre"
    
    resultados_clpr_nombre_NAC <- dbGetQuery(Base_Datos_Prueba, query_clpr_nombre_NAC)


# Ejecutar la segunda consulta para caracter y guardar los resultados en un data frame
    query_caracter_NAC <- "SELECT  caracter, COUNT(*) AS cantidad_prestadores
                       FROM prestadores
                       GROUP BY  caracter"
    resultados_caracter_NAC <- dbGetQuery(Base_Datos_Prueba, query_caracter_NAC)

# Ejecutar la tercera consulta para dv y guardar los resultados en un data frame
    query_dv_NAC <- "SELECT  dv, COUNT(*) AS cantidad_prestadores
                 FROM prestadores
                 GROUP BY  dv"
    resultados_dv_NAC <- dbGetQuery(Base_Datos_Prueba, query_dv_NAC)

# Ejecutar la cuarta consulta para naju_nombre y guardar los resultados en un data frame
    query_naju_nombre_NAC <- "SELECT  naju_nombre, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE naju_nombre IS NOT NULL AND naju_nombre != ''
                          GROUP BY  naju_nombre"
    resultados_naju_nombre_NAC <- dbGetQuery(Base_Datos_Prueba, query_naju_nombre_NAC)

# Ejecutar la quinta consulta para numero_sede_principal y guardar los resultados en un data frame
    query_numero_sede_NAC <- "SELECT  numero_sede_principal, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE numero_sede_principal IS NOT NULL AND numero_sede_principal != ''
                          GROUP BY  numero_sede_principal"
    resultados_numero_sede_NAC <- dbGetQuery(Base_Datos_Prueba, query_numero_sede_NAC)
    


###############################################################################################################################################################################################################################
# Queries 5: Obtener el numero de prestadoras por las variables clrp_monbre, caracter, naju_nombre, numero_sede_principal por departamento
###############################################################################################################################################################################################################################

# Ejecutar la primera consulta para caracter y guardar los resultados en un data frame
      
      query_clpr_nombre_DEP <- "SELECT depa_nombre, clpr_nombre, COUNT(*) AS cantidad_prestadores
                            FROM prestadores
                            WHERE clpr_nombre IS NOT NULL AND clpr_nombre != ''
                            GROUP BY depa_nombre, clpr_nombre"
      
      resultados_clpr_nombre_DEP <- dbGetQuery(Base_Datos_Prueba, query_clpr_nombre_DEP)
      
      
      resultados_clpr_nombre_DEP_Final <- resultados_clpr_nombre_DEP %>%
        pivot_wider(names_from = clpr_nombre, values_from = cantidad_prestadores, values_fill = 0)

    # Ordenar la tabla por cantidad de instituciones de forma descendente y tomar los primeros 5 departamentos
    top_departamentos <- resultados_clpr_nombre_DEP_Final %>%
      arrange(desc(`Instituciones Prestadoras de Servicios de Salud - IPS`)) %>%  # Ordenar de mayor a menor cantidad
      select(depa_nombre, `Instituciones Prestadoras de Servicios de Salud - IPS`) %>%  # Seleccionar solo la variable ordenada
      head(5)  # Tomar los primeros 5 departamentos

    # Mostrar el top 5 de departamentos con más instituciones prestadoras
    print(top_departamentos)
    
    tabla_flex <- flextable(top_departamentos)
    
    # Exportar la tabla a un documento de Word
    save_to <- "D:/PRUEBA ADRES/top_departamentos.docx"
    print(tabla_flex, target = save_to)
    
    top_departamentos <- resultados_clpr_nombre_DEP_Final %>%
      arrange(desc(`Profesional Independiente`)) %>%  # Ordenar de mayor a menor cantidad
      select(depa_nombre, `Profesional Independiente`) %>%  # Seleccionar solo la variable ordenada
      head(5)  # Tomar los primeros 5 departamentos
    
    # Mostrar el top 5 de departamentos con más instituciones prestadoras
    print(top_departamentos)
    
    tabla_flex <- flextable(top_departamentos)
    
    # Exportar la tabla a un documento de Word
    save_to <- "D:/PRUEBA ADRES/top_departamentos.docx"
    print(tabla_flex, target = save_to)



# Ejecutar la segunda consulta para caracter y guardar los resultados en un data frame
    
    query_caracter_DEP <- "SELECT depa_nombre, caracter, COUNT(*) AS cantidad_prestadores
                       FROM prestadores
                       GROUP BY depa_nombre, caracter"
    resultados_caracter_DEP <- dbGetQuery(Base_Datos_Prueba, query_caracter_DEP)
    
    resultados_caracter_DEP_Final <- resultados_caracter_DEP %>%
      pivot_wider(names_from = caracter, values_from = cantidad_prestadores, values_fill = 0)
    
    # Ejecutar la tercera consulta para dv y guardar los resultados en un data frame
    query_dv_DEP <- "SELECT depa_nombre, dv, COUNT(*) AS cantidad_prestadores
                 FROM prestadores
                 GROUP BY depa_nombre, dv"
    resultados_dv_DEP <- dbGetQuery(Base_Datos_Prueba, query_dv_DEP)
    
    resultados_dv_DEP_Final <- resultados_dv_DEP %>%
      pivot_wider(names_from = dv, values_from = cantidad_prestadores, values_fill = 0)

# Ejecutar la cuarta consulta para naju_nombre y guardar los resultados en un data frame
    
    query_naju_nombre_DEP <- "SELECT depa_nombre, naju_nombre, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE naju_nombre IS NOT NULL AND naju_nombre != ''
                          GROUP BY depa_nombre, naju_nombre"
    resultados_naju_nombre_DEP <- dbGetQuery(Base_Datos_Prueba, query_naju_nombre_DEP)
    
    resultados_naju_nombre_DEP_Final <- resultados_naju_nombre_DEP %>%
      pivot_wider(names_from = naju_nombre, values_from = cantidad_prestadores, values_fill = 0)
    
    top_departamentos <- resultados_naju_nombre_DEP_Final %>%
      arrange(desc(`Privada`)) %>%  # Ordenar de mayor a menor cantidad
      select(depa_nombre, `Privada`) %>%  # Seleccionar solo la variable ordenada
      head(5)  # Tomar los primeros 5 departamentos
    
    # Mostrar el top 5 de departamentos con más instituciones prestadoras
    print(top_departamentos)
    
    tabla_flex <- flextable(top_departamentos)
    
    # Exportar la tabla a un documento de Word
    save_to <- "D:/PRUEBA ADRES/top_departamentos.docx"
    print(tabla_flex, target = save_to)
    
    top_departamentos <- resultados_naju_nombre_DEP_Final %>%
      arrange(desc(`Pública`)) %>%  # Ordenar de mayor a menor cantidad
      select(depa_nombre, `Pública`) %>%  # Seleccionar solo la variable ordenada
      head(5)  # Tomar los primeros 5 departamentos
    
    # Mostrar el top 5 de departamentos con más instituciones prestadoras
    print(top_departamentos)
    
    tabla_flex <- flextable(top_departamentos)
    
    # Exportar la tabla a un documento de Word
    save_to <- "D:/PRUEBA ADRES/top_departamentos.docx"
    print(tabla_flex, target = save_to)

# Ejecutar la quinta consulta para numero_sede_principal y guardar los resultados en un data frame
   
    query_numero_sede_DEP <- "SELECT depa_nombre, numero_sede_principal, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE numero_sede_principal IS NOT NULL AND numero_sede_principal != ''
                          GROUP BY depa_nombre, numero_sede_principal"
    resultados_numero_sede_DEP <- dbGetQuery(Base_Datos_Prueba, query_numero_sede_DEP)


###############################################################################################################################################################################################################################
# Queries 5: Obtener el numero de prestadoras por las variables clrp_monbre, caracter, naju_nombre, numero_sede_principal por departamento y municipio
###############################################################################################################################################################################################################################



# Ejecutar la primera consulta para caracter y guardar los resultados en un data frame
    query_clpr_nombre <- "SELECT depa_nombre, muni_nombre, clpr_nombre, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE clpr_nombre IS NOT NULL AND clpr_nombre != ''
                          GROUP BY depa_nombre, muni_nombre, clpr_nombre"
    
    resultados_clpr_nombre <- dbGetQuery(Base_Datos_Prueba, query_clpr_nombre)
    

# Ejecutar la segunda consulta para caracter y guardar los resultados en un data frame
    query_caracter <- "SELECT depa_nombre, muni_nombre, caracter, COUNT(*) AS cantidad_prestadores
                       FROM prestadores
                       GROUP BY depa_nombre, muni_nombre, caracter"
    resultados_caracter <- dbGetQuery(Base_Datos_Prueba, query_caracter)

# Ejecutar la tercera consulta para dv y guardar los resultados en un data frame
    query_dv <- "SELECT depa_nombre, muni_nombre, dv, COUNT(*) AS cantidad_prestadores
                 FROM prestadores
                 GROUP BY depa_nombre, muni_nombre, dv"
    resultados_dv <- dbGetQuery(Base_Datos_Prueba, query_dv)

# Ejecutar la cuarta consulta para naju_nombre y guardar los resultados en un data frame
    query_naju_nombre <- "SELECT depa_nombre, muni_nombre, naju_nombre, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE naju_nombre IS NOT NULL AND naju_nombre != ''
                          GROUP BY depa_nombre, muni_nombre, naju_nombre"
    resultados_naju_nombre <- dbGetQuery(Base_Datos_Prueba, query_naju_nombre)

# Ejecutar la quinta consulta para numero_sede_principal y guardar los resultados en un data frame
    query_numero_sede <- "SELECT depa_nombre, muni_nombre, numero_sede_principal, COUNT(*) AS cantidad_prestadores
                          FROM prestadores
                          WHERE numero_sede_principal IS NOT NULL AND numero_sede_principal != ''
                          GROUP BY depa_nombre, muni_nombre, numero_sede_principal"
    resultados_numero_sede <- dbGetQuery(Base_Datos_Prueba, query_numero_sede)

###############################################################################################################################################################################################################################
# Gráficas
################################################################################################################################################################################################################################

# Crear el gráfico de población, superficie y densidad poblacional por km² - DEPARTAMENTO

    grafico <- ggplot(resultados_Departamento, aes(x = Departamento)) +
      geom_bar(aes(y = total_poblacion_departamento, fill = "Poblacion"), stat = "identity", position = "dodge") +
      geom_bar(aes(y = total_superficie_departamento, fill = "Superficie"), stat = "identity", position = "dodge") +
      geom_line(aes(y = densidad_poblacion_km2 * 1000, group = 1, color = "Densidad")) +
      scale_color_manual(values = c("Densidad" = "red")) +
      scale_fill_manual(values = c("Poblacion" = "#ADD8E6", "Superficie" = "#FFA500")) +
      labs(y = "Valor", fill = "Variable", color = "Densidad (por km²)",
           title = "Información por Departamento") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +  # Rotar etiquetas del eje x
      scale_y_continuous(labels = scales::comma, name = "Valor", sec.axis = sec_axis(~./1000, name = "Densidad (por km²)"))  # Segundo eje y para superficie
    
    # Mostrar el gráfico
    print(grafico)

# Crear el gráfico de población, superficie y densidad poblacional por km² - REGION

    grafico <- ggplot(resultados_Region, aes(x = Region)) +
      geom_bar(aes(y = total_poblacion_region, fill = "Poblacion"), stat = "identity", position = "dodge") +
      geom_bar(aes(y = total_superficie_region, fill = "Superficie"), stat = "identity", position = "dodge") +
      geom_line(aes(y = densidad_poblacion_km2 * 100000, group = 1, color = "Densidad")) +
      scale_color_manual(values = c("Densidad" = "red")) +
      scale_fill_manual(values = c("Poblacion" = "#ADD8E6", "Superficie" = "#FFA500")) +
      labs(y = "Valor", fill = "Variable", color = "Densidad (por km²)",
           title = "Información por Región") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +  # Rotar etiquetas del eje x
      scale_y_continuous(labels = scales::comma, name = "Valor", sec.axis = sec_axis(~./100000, name = "Densidad (por km²)"))  # Segundo eje y para densidad
    
    # Mostrar el gráfico
    print(grafico)



# Crear el gráfico de torta con etiquetas de datos
    
    grafico_torta <- ggplot(data = resultados_prestadoras_region, aes(x = "", y = Num_Prestadoras, fill = Region)) +
      geom_bar(width = 1, color = "white", stat = "identity") +
      geom_text(aes(label = Num_Prestadoras), position = position_stack(vjust = 0.5)) +  # Agregar etiquetas de datos
      coord_polar(theta = "y") +
      labs(fill = "Región", title = "Distribución de Prestadoras por Región") +
      theme_minimal() +
      theme(axis.text.x = element_blank(), legend.position = "right")  # Ocultar etiquetas del eje x y colocar leyenda a la derecha
    
    # Mostrar el gráfico de torta con etiquetas de datos
    print(grafico_torta)

# Crear histograma municipio
    histograma <- ggplot(resultados_prestadoras_municipio, aes(x = cantidad_prestadores)) +
      geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +  # Ajusta el ancho del bin según tus datos
      labs(x = "Cantidad de Prestadores", y = "Frecuencia", title = "Distribución de Prestadores por Municipio") +
      theme_minimal()
    
    # Mostrar el histograma
    print(histograma)

    
# Crear histograma departamento
    histograma <- ggplot(resultados_prestadoras_departamento, aes(x = cantidad_prestadores)) +
      geom_histogram(binwidth = 200, fill = "skyblue", color = "black") +  # Ajusta el ancho del bin según tus datos
      labs(x = "Cantidad de Prestadores", y = "Frecuencia", title = "Distribución de Prestadores por Departamento") +
      theme_minimal()
    
    # Mostrar el histograma
    print(histograma)


