
;***************************************************************************************************************
; La licencia:
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;***************************************************************************************************************

(define (script-fu-Texto-dorado inTexto inFuente inFuenteTam inColorFondo inDegradado sombra inColorSombra)
(let*
    (
	   ; definir las variables locales
	   ; crear la imagen nueva:
	(elAnchodeImagen  10)
	(laAlturadeImagen 10)
	(laImagen (car
			(gimp-image-new
			 elAnchodeImagen
			 laAlturadeImagen
			 RGB
			)
		    )
	 )
	(elTexto)   ;una declaración para el texto.
	(elBufer)
	(gimp-image-undo-disable laImagen)
;Crear una capa nueva en la imagen:
	(capaTexto
		(car
			(gimp-layer-new
			laImagen
			elAnchodeImagen
			laAlturadeImagen
			RGBA-IMAGE
			"Texto"
			100
			NORMAL
			)
		)
	  )
	(capaFondo
		(car
			(gimp-layer-new
			laImagen
			elAnchodeImagen
			laAlturadeImagen
			RGBA-IMAGE
			"Capa 2"
			100
			NORMAL
			)
		)
	  )
	(capaSombra
		(car
			(gimp-layer-new
			laImagen
			elAnchodeImagen
			laAlturadeImagen
			RGBA-IMAGE
			"Sombra"
			100
			NORMAL
			)
		)
	  )
	) ; fin de las variables locales
(gimp-image-insert-layer laImagen capaTexto 0 0)


(gimp-context-push)
(gimp-context-set-background '(255 255 255) )
(gimp-context-set-foreground '(255 255 255) )
(gimp-drawable-fill capaTexto TRANSPARENT-FILL)
	(set! elTexto
		(car
			(gimp-text-fontname
			laImagen capaTexto
			0 0
			inTexto
			0
			TRUE
			inFuenteTam PIXELS
			inFuente)
		)
	)

	(set! elAnchodeImagen (car (gimp-drawable-width elTexto) ) )
	(set! laAlturadeImagen (car (gimp-drawable-height elTexto) ) )
	(set! elBufer(* laAlturadeImagen(/ 50 100) ) )
	(set! laAlturadeImagen(+ laAlturadeImagen elBufer elBufer) )
	(set! elAnchodeImagen(+ elAnchodeImagen elBufer elBufer) )
	(gimp-image-resize laImagen elAnchodeImagen laAlturadeImagen 0 0)
	(gimp-layer-set-offsets elTexto elBufer elBufer)
	(gimp-layer-resize capaTexto elAnchodeImagen laAlturadeImagen 0 0)

	(set! capaFondo (car (gimp-layer-copy capaTexto TRUE)))
	(gimp-image-insert-layer laImagen capaFondo 0 2)
	(gimp-item-set-name capaFondo "Fondo")
	(gimp-context-set-background inColorFondo)
	(gimp-drawable-fill capaFondo BACKGROUND-FILL)

	
;Anclar el texto
	(gimp-floating-sel-anchor elTexto)

;Aplicando los filtros
	(plug-in-gauss 1 laImagen capaTexto 2 2 0);Desenfoque gaussiano



;Siguiendo con los filtros
	;(plug-in-ripple 1 laImagen capaTexto 70 5 ORIENTATION-HORIZONTAL 0 1 TRUE FALSE);Ondular
	;(plug-in-ripple 1 laImagen capaTexto 70 5 ORIENTATION-HORIZONTAL 0 1 TRUE FALSE)
	(plug-in-emboss 1 laImagen capaTexto 30 45 20 0);Repujado
	(gimp-image-select-item laImagen 2 capaTexto);Alfa a selección
	(plug-in-solid-noise 1 laImagen capaTexto 1 0 0 1 2.8 2.8);Ruido sólido
	(gimp-context-set-gradient inDegradado);Degradado 
	(plug-in-gradmap 1 laImagen capaTexto);Mapa de degradado
	(gimp-selection-none laImagen);Deseleccionar todo

	;Preparando la sombra
	(if (= sombra FALSE)
		(begin
		(gimp-image-insert-layer laImagen capaSombra 0 1)
		(gimp-image-remove-layer laImagen capaSombra))
		(begin
		(set! capaSombra (car (gimp-layer-copy capaTexto TRUE)));copia la capa del texto en la capa sombra
		(gimp-image-insert-layer laImagen capaSombra 0 1);insertar la capa de la sombra
		(gimp-item-set-name capaSombra "Sombra");renombrar la capa sombra
		;(plug-in-ripple 1 laImagen capaSombra 70 5 ORIENTATION-HORIZONTAL 0 1 TRUE FALSE);Ondular
		(gimp-image-select-item laImagen 2 capaSombra);alfa a selección en la capa sombra
		(gimp-context-set-background inColorSombra);establece como color de fondo el color seleccionado para la sombra
		(gimp-edit-fill capaSombra BACKGROUND-FILL);rellena la seleccion con el color de fondo en la capa sombra
		(plug-in-gauss 1 laImagen capaSombra 10 10 0);difuminado gaussiano a la sombra
		(gimp-layer-set-offsets capaSombra 4 4);desviación de la sombra
		(gimp-layer-resize-to-image-size capaSombra);la capa sombra a tamaño de imagen
		(gimp-layer-set-opacity capaSombra 80)));Sombra lista
		;(gimp-levels capaTexto 0 38 225 1 0 255)
;niveles
		(gimp-levels capaTexto 0 38 225 1 0 255)
		

(gimp-selection-none laImagen);Deseleccionar todo	
(gimp-image-undo-enable laImagen)
(gimp-display-new laImagen)
;(gimp-displays-flush)
(gimp-image-clean-all laImagen)
(gimp-context-pop)
))
	(script-fu-register "script-fu-Texto-dorado"                                   ;nombre de la función 1REQUERIDO
	_"Texto dorado"                                          ;etiqueta del menú 2REQUERIDO
   	_"Crea un texto dorado." ;descripción 3REQUERIDO
	"Jose Antonio Carrascosa Garcia"                                                     ;autor 4REQUERIDO
	"Copyright 2015 Ábaco"                                      ;copyright 5REQUERIDO
	"Viernes 18 de Diciembre de 2015"                         ;Fecha de creación 6REQUERIDO
	""                                                         ;Tipo de imagen con el que trabaja. 7REQUERIDO
	SF-STRING        _"Texto"       "  Texto\ndorado"
	SF-FONT          _"Tipo de fuente"       "Georgia Bold Italic"
	SF-ADJUSTMENT    _"Tamaño del texto"  '(120 1 1000 1 10 0 1)
	SF-COLOR         _"Color de fondo"      '(0 0 0)   
	SF-GRADIENT      _"Seleccione un degradado" "Golden"
	SF-TOGGLE        _"Sombra"        FALSE
	SF-COLOR         _"Color de la sombra"   '(255 255 255)
	)
	(script-fu-menu-register  "script-fu-Texto-dorado" "<Image>/File/Create/Abaco")
