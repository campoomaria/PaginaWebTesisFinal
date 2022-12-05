const { createApp } = Vue
createApp({
  components: {
    template: "#modal-template",
  },
  data() {
    return {
      iniciosesion: true,
      Afiliados:[],
      Prestaciones:[],
      Farmacias: [],
      Productos: [],
      Rubros: [],
      institucionesMedicas: [],
      page: `index`,

      //Variables para delegaciones
      mostrarmodal: false,
      datosdelegacion: `delegacion1`,
      infodelegacion: ``,
      id: ``,
      Provincia: ``,
      Direccion: ``,
      Telefono: ``,
      Cp: ``,
      Email: ``,
      EncargadoDelegacion: ``,
    };
  },
  methods: {
    showModal: function (element) {
      // limpio los links (sacando la clase on)
      const allLinks = document.querySelectorAll(".button_delegacion");
      allLinks.forEach((e) => e.classList.remove("on"));

      // seteo el nuevo lugar / pagina
      this.datosdelegacion = element;

      // lo prendo (le doy la clase on)
      document.querySelector(`#${element}`).classList.add("on");
      this.infodelegaciones();
      this.mostrarmodal = true;
    },
    infodelegaciones: function () {
      this.Provincia = ``;
      this.Direccion = ``;
      this.Telefono = ``;
      this.Cp = ``;
      this.Email = ``;
      this.EncargadoDelegacion = ``;

      if (this.datosdelegacion === "delegacion1") {
        this.Provincia = `Buenos Aires`;
        this.Direccion = `Belgrano 1090 (Zárate)`;
        this.Telefono = `03487-437660`;
        this.Cp = 2800;
        this.Email = `soesgypezarate@hotmail.com`;
        this.EncargadoDelegacion = `Copertari Emilio`;
      }
      if (this.datosdelegacion === "delegacion2") {
        this.Provincia = `Catamarca`;
        this.Direccion = `Sarmiento 1051(San Fdo. del Valle)`;
        this.Telefono = `03833-455767-15506316`;
        (this.Cp = 4700), (this.Email = `nico_saad@hotmail.com`);
        this.EncargadoDelegacionl = `sin información`;
      }
      if (this.datosdelegacion === "delegacion3") {
        this.Provincia = `Chubut`;
        this.Direccion = `Mitre 766- Esquel`;
        this.Telefono = `02945 452317`;
        this.Cp = 9200;
        this.Email = `ospeschubut@hotmail.com`;
        this.EncargadoDelegacion = `Viñales Lisandro A.`;
      }
      if (this.datosdelegacion === "delegacion4") {
        this.Provincia = `Cordoba`;
        this.Direccion = `Jujuy 391`;
        this.Telefono = `0351-4229784`;
        this.Cp = 5000;
        this.Email = `sintesype@hotmail.com`;
        this.EncargadoDelegacion = `Arevalo Leandro`;
      }
      if (this.datosdelegacion === "delegacion5") {
        this.Provincia = `Corrientes`;
        this.Direccion = `Cordoba 593 (Entre Quintana y Mayo)`;
        this.Telefono = `0379-4461695`;
        this.Cp = 3400;
        this.Email = `ospescorrientes@hotmail.com`;
        this.EncargadoDelegacionl = `Romero Victor`;
      }
      if (this.datosdelegacion === "delegacion6") {
        this.Provincia = `Entre Rios`;
        this.Direccion = `Dr. Francisco Soler 1362 (Paraná)`;
        this.Telefono = `03434248294`;
        this.Cp = 3100;
        this.Email = `ospesentrerios@gigared.com`;
        this.EncargadoDelegacion = `Biderbos Omar`;
      }
      if (this.datosdelegacion === "delegacion7") {
        this.Provincia = `Formosa`;
        this.Direccion = `Calle "Provincia" de Territorios Nac.1076 PB`;
        this.Telefono = `03704-436817`;
        this.Cp = 3600;
        this.Email = `formosaospes@hotmail.com`;
        this.EncargadoDelegacion = `Ceballos Orlando`;
      }
      if (this.datosdelegacion === "delegacion8") {
        this.Provincia = `Jujuy`;
        this.Direccion = `Belgrano 1476 (San Salvador)`;
        this.Telefono = `0388-4225444`;
        this.Cp = 4600;
        this.Email = `piazza.claudia@hotmail.com`;
        this.EncargadoDelegacion = `Santillán Gaspar`;
      }
      if (this.datosdelegacion === "delegacion9") {
        this.Provincia = `La Pampa`;
        this.Direccion = `1° de Mayo 174 (Santa Rosa)`;
        this.Telefono = `02954426187`;
        this.Cp = 6300;
        this.Email = `laury979@hotmail.com`;
        this.EncargadoDelegacion = `Fiorani Juan Pedro`;
      }
      if (this.datosdelegacion === "delegacion10") {
        this.Provincia = `La Rioja`;
        this.Direccion = ` Benjamin de la Vega 238 Barrio Centro`;
        this.Telefono = `0380-4436019`;
        this.Cp = 5300;
        this.Email = `nico_saad@hotmail.com`;
        this.EncargadoDelegacion = `Saad Francisco`;
      }
      if (this.datosdelegacion === "delegacion11") {
        this.Provincia = `Mendoza`;
        this.Direccion = `Rioja 831`;
        this.Telefono = `0261-4235326`;
        this.Cp = 5500;
        this.Email = `soesma09@hotmail.com`;
        this.EncargadoDelegacion = `Orozco Osvaldo`;
      }
      if (this.datosdelegacion === "delegacion12") {
        this.Provincia = `Misiones`;
        this.Direccion = `Av.Lavalle 2390 (Posadas)`;
        this.Telefono = `0376-4438021 / 0376 4429014`;
        this.Cp = 3300;
        this.Email = `gerosan69@gmail.com`;
        this.EncargadoDelegacion = `Sanabria Geronimo Ramón`;
      }
      if (this.datosdelegacion === "delegacion13") {
        this.Provincia = `Rio Negro`;
        this.Direccion = `Otto Goedecke 210 y Mitre`;
        this.Telefono = `02944-431834 -15297009`;
        this.Cp = 8400;
        this.Email = `ospesrionegro@hotmail.com`;
        this.EncargadoDelegacion = `Almeida Alberto`;
      }
      if (this.datosdelegacion === "delegacion14") {
        this.Provincia = `Salta`;
        this.Direccion = `Cadena de Hessling 212 B°Don Emilio`;
        this.Telefono = `0387-4232948`;
        this.Cp = 4400;
        this.Email = `soesgype_salta@hotmail.com`;
        this.EncargadoDelegacion = `Zenteno Francisco`;
      }
      if (this.datosdelegacion === "delegacion15") {
        this.Provincia = `San Juan`;
        this.Direccion = `Santiago Paredes 741 Barrio Natania XX (Rivadavia)`;
        this.Telefono = `0264-156202612`;
        this.Cp = 5400;
        this.Email = `-`;
        this.EncargadoDelegacion = `Gonzalez Carlos Faustino`;
      }
      if (this.datosdelegacion === "delegacion16") {
        this.Provincia = `San Luis`;
        this.Direccion = `Juan W. Gaez 195`;
        this.Telefono = `02652-444045`;
        this.Cp = 5700;
        this.Email = `soesgypesanluis@hotmail.com`;
        this.EncargadoDelegacion = `Henry Oscar`;
      }
      if (this.datosdelegacion === "delegacion17") {
        this.Provincia = `Santiago del Estero`;
        this.Direccion = `Av. Moreno Sur 585`;
        this.Telefono = `0385-4220226`;
        this.Cp = 4200;
        this.Email = `soesgyesgoestero@hotmail.com`;
        this.EncargadoDelegacion = `Juarez Ricardo Ernesto`;
      }
      if (this.datosdelegacion === "delegacion18") {
        this.Provincia = `Tierra del Fuego`;
        this.Direccion = `Laserre 878`;
        this.Telefono = `0294-154297009`;
        this.Cp = 9420;
        this.Email = `-`;
        this.EncargadoDelegacion = `Almeida Alberto`;
      }
      if (this.datosdelegacion === "delegacion19") {
        this.Provincia = `Tucumán`;
        this.Direccion = `Crisostomo Alvarez 1278`;
        this.Telefono = `0381-4245175`;
        this.Cp = 4000;
        this.Email = `adrianaospes@hotmail.com`;
        this.EncargadoDelegacion = `Sanchez Francisco`;
      }
    },
  },
}).mount("#app");
