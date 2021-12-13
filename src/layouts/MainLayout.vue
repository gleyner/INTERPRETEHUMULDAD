
<template>   
  <q-layout view="lHh Lpr lFf">
    <q-bar class="bg-black text-white">
      <q-icon name="laptop_chromebook" />
      <div class="text-weight-bold">
        INTÉRPRETE HUMILDE
      </div>      
      <q-space />
                 
    </q-bar>
    <h5 class="text-subtitle2 text-center">
      Gabriel Candelario - Gleyner Ospino
    </h5>
    <p class="text-center">Este lenguaje acepta: Asignación, declaración de variables, condicionales, Ciclo for, while, do while y funciones.</p>
    
    <div class="q-pa-md" style="max-width: 100%">
      
      <q-list bordered class="rounded-borders">
      
      <q-expansion-item expand-separator icon="code" label="Código de ejemplo" >

      <q-card>
        <q-card-section> 
          <p>
              <b>//DECLARACION VARIABLE:</b> <br>
              dv n $= 0; <br>
              <b>//DECLARACION DE CONSTANTE:</b> <br>
              dc m $= 10; <br>

              <br>

              <b>//CONDICIONALES IF ELSE:</b> <br>
              sentenciaIf( n < 10 ) { <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log("Es menor"); <br>
              }contrarioIf{ <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log("Es mayor"); <br>
              }
                
              <br> <br>

              <b>//CICLOS:</b> <br>
              sentenciaWhile( n < m ) { <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sentenciaIf(n == 2){ <br>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log("n="+n); <br>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;} <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log(n); <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;n++; <br>
              }
              
              <br> <br>

              sentenciaFor(&nbsp;dc i $= 5 ;i > 1; i--) { <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log(i); <br>
              }
              
              <br> <br>

              do{ <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;n++; <br>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;console.log(n); <br>
              }sentenciaWhile(n < 3);

              <br> <br>
              <b>//FUNCIONES: </b> <br>
              declararF miFuncion(){ <br>
  	            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  dv b $= 0; <br>
	              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  return b; <br>
              }
          </p>
        </q-card-section>
      </q-card>
      </q-expansion-item>
      </q-list>
    </div>
    
    <q-page-container class="bg-grey-1">
      <router-view />
    </q-page-container>

    
  </q-layout>
</template>

<script>

export default {
  data () {
    return {

    }
  }
}
</script>
