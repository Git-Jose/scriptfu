;  Script inspirado en el tutorial: http://memhet.wordpress.com/2012/02/18/gimp-papelito-y-fantasia/
;  La idea del script es simular un dibujo a lápiz a partir de una selección, eligiendo el filtro final
; entre Colores-->Umbral y Colores-->Desaturar.
;Si la imagen está en escala de grises, al ejecutar el script con el filtro Desaturar, este la pasará a RGB 
;y lanzará un mensaje de aviso.
;***************************************************************************************************************
;
;*****************************Visite: http://criptalabs.tk/ ****************************************************
;
;***************************************************************************************************************
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

(define (script-fu-seleccion-lapiz  inImagen laCapa distSeleccion difuSeleccion radioDifu autoBordes umbrOsatur consSeleccion)
 	(if (= (car (gimp-selection-is-empty  inImagen)) TRUE)
	(begin
	(gimp-message "La imagen no tiene ninguna selección.\n\nEste script necesita \nun area seleccionada de la imagen para trabajar.")
	)
	
	(begin
	(gimp-context-push)
	(gimp-context-set-defaults)
	(gimp-image-undo-group-start  inImagen)
	(if (and(= umbrOsatur 1)
		(= (car(gimp-image-base-type inImagen)) GRAY ))
	  (begin
		(gimp-message "El filtro Colores->Desaturar no puede trabajar en escala de grises.\nSu imagen se convertira a RGB.\nSiempre puede deshacer esta acción o volver a convertir la imagen en escala de grises")
		(gimp-convert-rgb inImagen))
	)
	(gimp-layer-add-alpha laCapa)
	
(let* (
	(laImagen inImagen)
	(elAncho (car (gimp-image-width inImagen)))
	(laAltura (car (gimp-image-height inImagen)))
	(capaDibujo 0)
	(capaCurro 0)
	(elModo (car (gimp-image-base-type inImagen)))

);fin definición variables locales
	(if (= elModo GRAY)
	  (set! elModo GRAYA-IMAGE)
	  (set! elModo RGBA-IMAGE)
	)
	
	
	(set! capaCurro (car (gimp-layer-new laImagen elAncho laAltura elModo "Distorsión" 100 0)));capa nueva para distorsionar la selección
	(gimp-image-insert-layer laImagen capaCurro 0 0)
	(if (= distSeleccion TRUE)
	(begin
	(gimp-edit-fill capaCurro BACKGROUND-FILL)
	(gimp-selection-invert laImagen)
	(gimp-edit-clear capaCurro)
	(gimp-selection-invert laImagen)
	(gimp-selection-clear inImagen)
	(gimp-layer-scale capaCurro (/ elAncho 4) (/ laAltura 4) TRUE)
	(plug-in-spread 1 laImagen capaCurro 8 8)
	(plug-in-gauss-iir 1 laImagen capaCurro 1 TRUE TRUE )
	(gimp-layer-scale capaCurro elAncho laAltura TRUE)
	(plug-in-threshold-alpha 1 laImagen capaCurro 127)
	(plug-in-gauss-iir 1 laImagen capaCurro 1 TRUE TRUE )
	
	(gimp-image-select-item inImagen 2 capaCurro)
	(if (and (= (car (gimp-item-is-channel laCapa)) TRUE)
             (= (car (gimp-item-is-layer-mask laCapa)) FALSE))
      (gimp-image-set-active-channel theImage laCapa)
      )
)
);fin del if distorsión
	(if (= difuSeleccion TRUE)
	  (gimp-selection-feather laImagen radioDifu)
);Fin del if difuminado
	(set! capaDibujo (car (gimp-layer-copy laCapa TRUE)))
	(gimp-image-insert-layer laImagen capaDibujo 0 0)
	(gimp-item-set-name capaDibujo "Dibujo")
	(plug-in-edge autoBordes laImagen capaDibujo 2 2 0)
	(gimp-selection-invert laImagen);invertir selección
	(gimp-edit-clear capaDibujo)
	(gimp-selection-invert laImagen)
	(gimp-invert capaDibujo);colores-->invertir
 	(if (= umbrOsatur 0)
	  (gimp-threshold capaDibujo 127 255);Colores-->Umbral
	  (gimp-desaturate-full capaDibujo 0);Colores-->Desaturar ¡¡¡¡Sólo RGB!!!!!
	)
	(if (= consSeleccion 0)
	  (gimp-selection-none laImagen)
	)
	(gimp-image-remove-layer laImagen capaCurro)
	(gimp-image-undo-group-end laImagen)
	(gimp-displays-flush)
	(gimp-context-pop)
);cierra el let*
	)
);cierra el if de selección vacia
    )

	(script-fu-register "script-fu-seleccion-lapiz"                                   
	 _"Selección a lápiz"                                         
   	 _"Simula un dibujo a lápiz de las áreas seleccionadas de dos maneras distintas." 
	"Jose Antonio Carrascosa Garcia"                                
	"Copyright 2016 criptalabs.tk"                                     
	"Viernes 8 de Enero de 2016"                        
	"RGB* GRAY*"                                                         
	SF-IMAGE        "Image"                  0
	SF-DRAWABLE     "Drawable"               0
	SF-TOGGLE      _"Distorsionar selección" TRUE
	SF-TOGGLE      _"Difuminar selección"    TRUE
	SF-ADJUSTMENT  _"Radio de difuminado"    '(5 1 32767 1 10 3 0)
	SF-TOGGLE      _"Detección de bordes automática"  TRUE
	SF-OPTION      _"Umbral o Desaturar"    '("Umbral" "Desaturar")
	SF-TOGGLE      _"Conservar selección"	 TRUE
	)
	(script-fu-menu-register  "script-fu-seleccion-lapiz" "<Image>/Filters/Artistic")
