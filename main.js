createApp({
  components: {
    template: "#modal-template",
  },
  data() {
    return {
      iniciosesion: false,
      Farmacias: [],
      Productos: [],
      Rubros: [],
      institucionesMedicas: [],
      page: `index`,

    };
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
      }
    },
}).mount("#app");

