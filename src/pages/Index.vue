<template>
  <q-page class="constrain q-pa-lg">

    <!-- Editor de codigo -->
    <div class="row justify-content-center q-mt-md">
      <div class="col-12">
        <q-card class="my-card">
          <q-btn-group push spread class="text-white bg-blue-10">
            <q-btn push label="Compilar" icon="play_arrow" @click="Compilar" />
          </q-btn-group>

          <q-separator />

          <q-tab-panels v-model="tab" animated>
            <q-tab-panel name="editor">
              <codemirror v-model="code" :options="cmOptions" @input="codigoEditado" />
            </q-tab-panel>
          </q-tab-panels>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script>
//JS-Beautify
var beautify_js = require('js-beautify').js_beautify
// CodeMirror
import { codemirror } from "vue-codemirror";
// import base style
import "codemirror/lib/codemirror.css";
// import theme style
import "codemirror/theme/paraiso-light.css";
// import language js
import "codemirror/mode/javascript/javascript.js";
// Analizador
import AnalizadorTraduccion from "../gramatica/gramatica_traduccion";
//Traduccion
import { Traduccion } from "../traduccion/traduccion";
import { Variable } from "../traduccion/variable";
import { Ejecucion } from "../ejecucion/ejecucion";
import { Errores } from "../arbol/errores";
import { Error as InstanciaError } from "../arbol/error";
import { Entornos } from "../ejecucion/entornos";
import { EntornoAux } from '../ejecucion/entorno_aux';

export default {
  components: {
    codemirror,
  },
  data() {
    return {
      code: "",
      cmOptions: {
        tabSize: 4,
        matchBrackets: true,
        styleActiveLine: true,
        mode: "text/javascript",
        theme: "paraiso-light",
        lineNumbers: true,
        line: false,
      },
      output: "salida de ejemplo",
      tab: "editor",
      dot: "",
      salida: [],
      errores: [],
      columns: [
        { name: "tipo", label: "Tipo", field: "tipo", align: "left" },
        { name: "linea", label: "Linea", field: "linea", align: "left" },
        {
          name: "descripcion",
          label: "Descripcion",
          field: "descripcion",
          align: "left",
        },
      ],
      entornos: [],
    };
  },
  methods: {
    notificar(variant, message) {
      this.$q.notify({
        message: message,
        color: variant,
        multiLine: true,
        
        actions: [
          {
            label: "Aceptar",
            color: "black",
            handler: () => {
              /* ... */
            },
          },
        ],
      });
    },
    Compilar() {
      if (this.code.trim() == "") {
        this.notificar("warning", `Coloque algo de codigo por favor`);
        return;
      }
      this.inicializarValores();
      try {
        const raiz = AnalizadorTraduccion.parse(this.code);
        //Validacion de raiz
        if (raiz == null) {
          this.notificar(
            "negative",
            "No fue posible obtener la raíz de la ejecución"
          );
          return;
        }
        let ejecucion = new Ejecucion(raiz);
        this.dot = ejecucion.getDot();
        //Valido si puedo ejecutar (no deben existir funciones anidadas)
        if(!ejecucion.puedoEjecutar(raiz)){
          this.notificar("primary", "No se puede realizar una ejecución con funciones anidadas");
          return;
        }
        ejecucion.ejecutar();
        // ejecucion.imprimirErrores();
        this.salida = ejecucion.getSalida();
        this.notificar("info", "Compilado Con Humildad");
      } catch (error) {
        this.validarError(error);
      }
      this.errores = Errores.getInstance().lista;
      this.entornos = Entornos.getInstance().lista;
    },
    inicializarValores() {
      Errores.getInstance().clear();
      Entornos.getInstance().clear();
      this.errores = [];
      this.entornos = [];
      this.salida = [];
      this.dot = '';
    },
    validarError(error) {
      const json = JSON.stringify(error);
      this.notificar(
        "negative",
        `Error: Falta de humildad`
      );
      const objeto = JSON.parse(json);

      if (
        objeto != null &&
        objeto instanceof Object &&
        objeto.hasOwnProperty("hash")
      ) {
        Errores.getInstance().push(
          new InstanciaError({
            tipo: "sintactico",
            linea: objeto.hash.loc.first_line,
            descripcion: `No se esperaba el token: "${objeto.hash.token}" en la columna ${objeto.hash.loc.last_column}, se esperaba uno de los siguientes: ${objeto.hash.expected}`,
          })
        );
      }
    },
    codigoEditado(codigo){
      this.inicializarValores();
    }
  },
};
</script>

<style lang="css">
.CodeMirror {
  height: 600px;
}
</style>

