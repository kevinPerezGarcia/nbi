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
***	PART 0: Configuración inicial
*******************************************************************************/
	
*** 0.1 Configuración de rutas
	cd "D:\stata\proyectos\nbi"
	global raw_enaho "E:\inei\enaho\raw_enaho"

********************************************************************************
***	PART 1: Cálculo del nbi 1
********************************************************************************	

*** 1.1 Cargando base de datos
	use "${raw_enaho}/enaho01-2017-100.dta", clear
	
*** Restricción de observaciones
	keep if ( result == 1 | result == 2 )
	
*** 1.2 Pre-variables
	codebook p101 // Tipo de vivienda
	fre p101
	
	codebook p102 // Material predominante de las paredes
	fre p102
	
	codebook p103 // Material predominante de los pisos
	fre p103
	
*** 1.3 Calculando nbi 1
	generate nbi_1 = p101 == 6 | /// vivienda improvisada
					 p102 == 8 | /// triplay, calamina, estera
					(p103 == 6 & /// tierra
					(p102 == 5 | p102 == 6 | p102 == 7 | p102 == 9)) /// quincha | piedra con barro | madera | otro

*** 1.4 Etiquetado
	label variable nbi_1 "Hogares con vivienda inadecuada"
	label define nbi_1 1 "Vivienda inadecuada" 0 "Vivienda adecuada"
	label values nbi_1 nbi_1
					
*** 1.5 Ordenando observaciones
	sort conglome vivienda
	
*** 1.6 Colapsando a nivel de conglome y vivienda
	collapse (max) nbi_1, by(conglome vivienda)
	
*** 1.7 Guardando base de datos
	save "nbi_1.dta", replace
	
********************************************************************************
***	PART 2: Cálculo del nbi 2
********************************************************************************	

*** 2.1 Total de habitaciones por vivienda y número de hogares por vivienda

	*** Cargando base de datos
		use "${raw_enaho}/enaho01-2020-100.dta", clear

	*** Pre-variables
		codebook p104 // Cantidad de habitaciones
		fre p104
		
		codebook hogar // Número secuencial del hogar
		
	*** Calculando total de habitaciones por vivienda
		generate total_habitaciones = p104 if ( p104 != 0 & p104 != . )
		
	*** Calculando número de hogares por vivienda	
		generate numero_hogares = real(substr(hogar,2,1))
				
	*** Ordenando observaciones
		sort conglome vivienda
	
	*** Colapsando a nivel de conglome y vivienda
		collapse (sum) total_habitaciones (max) numero_hogares if (total_habitaciones != .), by(conglome vivienda)
		
	*** 1.6 Guardando base de datos
		save "total_habitaciones_vivienda.dta", replace
		
*** 2.2 Total de miembros por vivienda

	*** Cargando base de datos
		use "${raw_enaho}/enaho01-2017-200.dta", clear
		
	*** Pre-variables
		codebook p204 // Miembro del hogar : 1 sí, 0 no
		fre p204
		
		fre p203 // Relación de parentesco con el jefe del hogar
	
	*** Calculando miembros del hogar
		generate miembro_hogar = (p204 == 1) if p203 != 8 & p203 != 9
		
	*** Ordenando observaciones
		sort conglome vivienda
		
	*** Colapsando a nivel de conglome y vivienda
		collapse (sum) miembro_hogar, by(conglome vivienda)
		
	*** Renombrando variable
		rename miembro_hogar total_miembros_vivienda
		
	*** Salvando base de datos
		save "total_miembros_vivienda.dta", replace
		
*** 2.3 Uniendo base de datos
	use "total_habitaciones_vivienda.dta", clear
	merge 1:1 conglome vivienda using "total_miembros_vivienda.dta"
	drop if _m == 2
	drop _m
		
*** Omisión de habitaciones de la viviendas
	replace total_habitaciones = numero_hogares if ( total_habitaciones == 0 | total_habitaciones == . )
		
*** Calculando nbi 2
	generate nbi_2 = (total_miembros_vivienda / total_habitaciones) > 3.4 if ( total_miembros_vivienda != . & total_habitaciones != 0 )

*** Etiquetado
	label variable nbi_2 "Hogares con viviendas hacinadas"
	label define nbi_2 1 "Vivienda hacinada" 0 "Vivienda no hacinada"
	label values nbi_2 nbi_2		
		
*** 5.3 Ordenando observaciones
	sort conglome vivienda
	
*** 5.4 Manteniendo variables
	keep conglome vivienda nbi_2
	
*** 5.5 Guardando base de datos
	save "nbi_2.dta", replace
		
********************************************************************************
***	PART 3: Cálculo del nbi 3: Hogares con vivienda sin servicios higiénicos
********************************************************************************	

*** Cargando base de datos
	use "${raw_enaho}/enaho01-2020-100.dta", clear

*** Pre-variables
	fre p111 // servicio higiénico conectado a ...
	
*** Calculando nbi 3
	generate nbi_3 = (p111 == 6 | p111 == 8) if (result == 1 | result == 2)

*** Etiquetado
	label variable nbi_3 "Hogares con vivienda sin servicios higiénicos"
	label define nbi_3 1 "Vivienda sin servicios higiénicos" 0 "Vivienda con servicios higiénicos"
	label values nbi_3 nbi_3	
	
*** Ordenando observaciones
	sort conglome vivienda hogar
	
*** Colapsando a nivel de conglome, vivienda y hogar
	collapse (max) nbi_3, by(conglome vivienda hogar)
	
*** Guardando base de datos
	save "nbi_3.dta", replace

********************************************************************************
***	PART 4: Cálculo del nbi 4: Hogares con niños que no asisten a la escuela
********************************************************************************

*** Cargando base de datos
	use "${raw_enaho}/enaho01a-2020-300.dta", clear

*** 7.1 Pre-variables
	fre p208a	// edad en años cumplidos
	fre p203	// relación de parentesco con el jefe del hogar
	fre mes		// mes de ejecución de la encuesta
	fre p306	// este año está matriculado en algún centro o programa de educación
	fre p307	// actualmente, asiste a algún centro o programa de educación
	
*** 7.2 Calculando nbi 4
	generate nbi_4 = p208a >= 6  & ///
					 p208a <= 12 & ///
					 (p203 == 1 | p203 == 3 | p203 == 5 | p203 == 7) & ///
					 p303 == 2 ///
					 if real(mes) >= 1 & real(mes) <= 3
					 
	replace nbi_4 = p208a >= 6  & ///
					p208a <= 12 & ///
					(p203 == 1 | p203 == 3 | p203 == 5 | p203 == 7) & ///
					(p306 == 2 | (p306 == 1 & p307 == 2))

*** Etiquetado
	label variable nbi_4 "Hogares con niños que no asisten a la escuela"
	label define nbi_4 1 "Hogares con niños que no asisten a la escuela" 0 "Hogares con niños que asisten a la escuela"
	label values nbi_4 nbi_4	
					
*** 7.3 Ordenando observaciones
	sort conglome vivienda hogar
	
*** 7.4 Colapsando a nivel de conglome y vivienda
	collapse (max) nbi_4, by(conglome vivienda hogar)
	
*** 7.5 Guardando base de datos
	save "nbi_4.dta", replace

********************************************************************************
***	PART 5: Cálculo del nbi 5: Hogares con alta dependencia económica
********************************************************************************

*** 5.1 Educación del jefe del hogar

	*** Cargando base de datos
		use "${raw_enaho}/enaho01a-2017-300.dta", clear

	*** Restricción de observaciones
		fre p203 // relación de parentesco con el jefe del hogar
		keep if p203 == 1

	*** 8.1 Pre-variables

	*** Calculando educación del jefe del hogar	
		generate edujef =  ((p301a == 1 | p301a == 2) |								 ///
							(p301a == 3 & (p301b == 0 | p301b == 1 | p301b == 2))  | ///
							(p301a == 3 & (p301c == 1 | p301c == 2 | p301c == 3))) & ///
							p203 == 1

	*** Manteniendo variables
		keep conglome vivienda hogar edujef
		
	*** Ordenando observaciones
		sort conglome vivienda hogar
		
	*** Salvando base de datos
		save "edujefe.dta", replace
	
*** Población económicamente activa
	use "enaho01a-2017-500.dta", clear
	generate ocu = real(p500i) > 0 & ocu500 == 1 & p204 == 1 & p203 != 8 & p203 != 9
	sort conglome vivienda hogar
	collapse (sum) ocu, by(conglome vivienda hogar)
	save "ocu.dta", replace
	
*** Uniendo base de datos
	use "enaho01-2017-100.dta", clear
	
	sort conglome vivienda hogar
	merge conglome vivienda hogar using "ocu.dta"
	drop _m
	
	sort conglome vivienda hogar
	merge conglome vivienda hogar using "edujefe.dta"
	drop _m
	
	sort conglome vivienda hogar
	merge conglome vivienda hogar using "mieperho.dta"
	drop _m
	
*** Calculando dependencia
	generate dep = mieperho if ocu == 0
	replace dep = (mieperho - ocu) / ocu if ocu > 0 & ocu != .
	
*** 8.2 Calculando nbi 5
	generate nbi_5 = edujef == 1 & dep > 3
	
*** Etiquetado
	label variable nbi_5 "Hogares con alta dependencia económica"
	label define nbi_5 1 "Hogares con alta dependencia económica" 0 "Hogares sin alta dependencia económica"
	label values nbi_5 nbi_5

*** 8.3 Ordenando observaciones
	sort conglome vivienda hogar
	
*** 8.4 Manteniendo variables
	keep conglome vivienda hogar nbi_5 mieperho

*** 8.5 Guardando base de datos
	save "nbi_5.dta", replace

********************************************************************************
***	PART 6: Uniendo base de datos
********************************************************************************

*** 6.1 Uniendo base de datos
	use "${raw_enaho}/enaho01-2017-100.dta", clear
	
	sort conglome vivienda
	merge conglome vivienda			using "nbi_1.dta"
	drop _m
	
	sort conglome vivienda
	merge conglome vivienda			using "nbi_2.dta"
	drop _m
	
	sort conglome vivienda hogar
	merge conglome vivienda hogar	using "nbi_3.dta"
	drop _m
	
	sort conglome vivienda hogar
	merge conglome vivienda hogar	using "nbi_4.dta"
	drop _m
	
	sort conglome vivienda hogar
	merge conglome vivienda hogar	using "nbi_5.dta"
	drop _m
	
*** 6.2 Restricciones de observaciones
	recode nbi_1 nbi1 (0 = .) (1 = .) if result >= 3
	recode nbi_2 nbi2 (0 = .) (1 = .) if result >= 3
	recode nbi_5 nbi5 (0 = .) (1 = .) if result >= 3
	
********************************************************************************
***	PART 7: Salvando base de datos
********************************************************************************	
	save "enaho01-2017-100m.dta", replace