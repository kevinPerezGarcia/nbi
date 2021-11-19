/*******************************************************************************
* Fecha:		2021-10-23
* Instituto:	Educate Peru Consultores
* Projecto:		Características de la vivienda y del hogar
* Título:		Construyendo variables
* Autor:		Kevin Pérez García
* email:		econ.perez.garcia.k@gmail.com
********************************************************************************

*** Objetivo: 
	Construir variables
	
***	Requerimientos:
	inputs: 	"${data_construccion}/sumaria-m100.dta"
	outputs: 	"${data_tablas}/sumaria-m100-construida.dta"
	
*** Outline:
	1. Variable ID y Duplicados
		1.1 Cargar datos
		1.2 Duplicates and ID variable 
		1.3 Export duplicates

*** Observaciones:

	Aunque los indicadores nbi1, nbi2, nbi3, nbi4 y nbi5 ya vienen calculadas en
	el módulo 100, en este do-file mostraremos cómo se hace dicho procedimiento.

********************************************************************************
***	PART 1: Cálculo de los nbis
*******************************************************************************/
	
*** 0. Configuración de rutas
	cd "D:\stata\proyectos\nbi"
	global raw_enaho "E:\inei\enaho\raw_enaho"
	
*** 1. Cargar base de datos
	use "${raw_enaho}/enaho01-2020-100.dta", clear
	
*** 2. nbis
	lookfor "nbi"
	fre nbi* // necesidad básica insatisfecha: 1, 2, 3, 4, 5
	label var nbi1 "Poblacion en viviendas con caracterisiticas fisicas inadecuadas"
	label var nbi2 "Poblacion en viviendas con hacinamiento"
	label var nbi3 "Poblacion en viviendas sin desague de ningun tipo"
	label var nbi4 "Poblacion en hogares con ninos (6 a 12) que no asisten a la escuela"
	label var nbi5 "Población en hogares con alta dependencia económica"
	
*** 3. Cálculo de nbi 1

	*** 3.1 Pre-variables
		codebook p101 // Tipo de vivienda
		fre p101
		
		codebook p102 // Material predominante de las paredes
		fre p102
		
		codebook p103 // Material predominante de los pisos
		fre p103
		
	*** 3.2 Calculando nbi 1
		generate nbi_1 = p101 == 6 | /// vivienda improvisada
						 p102 == 8 | /// triplay, calamina, estera
					    (p103 == 6 & /// tierra
					    (p102 == 5 | p102 == 6 | p102 == 7 | p102 == 9)) /// quincha | piedra con barro | madera | otro

	*** 3.3 Ordenando observaciones
		sort conglome vivienda
		
	*** 3.4 Colapsando a nivel de conglome y vivienda
		collapse (max) nbi_1, by(conglome vivienda)
		
	*** 3.5 Guardando base de datos
		save "nbi_1.dta", replace

*** 3. Cálculo de nbi 2

	*** 3.1 Pre-variables
		codebook p101 // Tipo de vivienda
		fre p101
		
		codebook p102 // Material predominante de las paredes
		fre p102
		
		codebook p103 // Material predominante de los pisos
		fre p103
		
	*** 3.2 Calculando nbi 2
		generate nbi_1 = p101 == 6 | /// vivienda improvisada
						 p102 == 8 | /// triplay, calamina, estera
					    (p103 == 6 & /// tierra
					    (p102 == 5 | p102 == 6 | p102 == 7 | p102 == 9)) /// quincha | piedra con barro | madera | otro

	*** 3.3 Ordenando observaciones
		sort conglome vivienda
		
	*** 3.4 Colapsando a nivel de conglome y vivienda
		collapse (max) nbi_1, by(conglome vivienda)
		
	*** 3.5 Guardando base de datos
		save "nbi_1.dta", replace

*** 3. Cálculo de nbi 3

	*** 3.1 Pre-variables
		codebook p101 // Tipo de vivienda
		fre p101
		
		codebook p102 // Material predominante de las paredes
		fre p102
		
		codebook p103 // Material predominante de los pisos
		fre p103
		
	*** 3.2 Calculando nbi 2
		generate nbi_1 = p101 == 6 | /// vivienda improvisada
						 p102 == 8 | /// triplay, calamina, estera
					    (p103 == 6 & /// tierra
					    (p102 == 5 | p102 == 6 | p102 == 7 | p102 == 9)) /// quincha | piedra con barro | madera | otro

	*** 3.3 Ordenando observaciones
		sort conglome vivienda
		
	*** 3.4 Colapsando a nivel de conglome y vivienda
		collapse (max) nbi_1, by(conglome vivienda)
		
	*** 3.5 Guardando base de datos
		save "nbi_1.dta", replace

*** 3. Cálculo de nbi 4

	*** 3.1 Pre-variables
		codebook p101 // Tipo de vivienda
		fre p101
		
		codebook p102 // Material predominante de las paredes
		fre p102
		
		codebook p103 // Material predominante de los pisos
		fre p103
		
	*** 3.2 Calculando nbi 2
		generate nbi_1 = p101 == 6 | /// vivienda improvisada
						 p102 == 8 | /// triplay, calamina, estera
					    (p103 == 6 & /// tierra
					    (p102 == 5 | p102 == 6 | p102 == 7 | p102 == 9)) /// quincha | piedra con barro | madera | otro

	*** 3.3 Ordenando observaciones
		sort conglome vivienda
		
	*** 3.4 Colapsando a nivel de conglome y vivienda
		collapse (max) nbi_1, by(conglome vivienda)
		
	*** 3.5 Guardando base de datos
		save "nbi_1.dta", replace

*** 3. Cálculo de nbi 5

	*** 3.1 Pre-variables
		codebook p101 // Tipo de vivienda
		fre p101
		
		codebook p102 // Material predominante de las paredes
		fre p102
		
		codebook p103 // Material predominante de los pisos
		fre p103
		
	*** 3.2 Calculando nbi 2
		generate nbi_1 = p101 == 6 | /// vivienda improvisada
						 p102 == 8 | /// triplay, calamina, estera
					    (p103 == 6 & /// tierra
					    (p102 == 5 | p102 == 6 | p102 == 7 | p102 == 9)) /// quincha | piedra con barro | madera | otro

	*** 3.3 Ordenando observaciones
		sort conglome vivienda
		
	*** 3.4 Colapsando a nivel de conglome y vivienda
		collapse (max) nbi_1, by(conglome vivienda)
		
	*** 3.5 Guardando base de datos
		save "nbi_1.dta", replace
