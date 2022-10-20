createApp({
    data() {
      return {
        iniciosesion: false,
        Farmacias:[],
        Productos:[],
        Rubros:[],
        institucionesMedicas:[],
        
        //supongo que aqui cargaremos lo que viene del back
      //Aqui van las variables u objetos que necesitemos
      }
    },
    methods:{
      //Aqui van los metodos que necesitemos utilizar
      alerta: function () {
        if (this.email != ' ' && this.nombrecontact != ' ' && this.tel != 0) {
            Swal.fire(
                '¡Tu consulta fue enviada con exito!',
                `Pronto nos estaremos comunicando ${this.nombrecontact}!`,
                'success'
            )
            this.email = ''
            this.nombrecontact = ''
            this.tel = ''
        }
    },
    }
  }).mount('#app')


  datosfarmacia:{}