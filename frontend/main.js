const { createApp } = Vue;
createApp({
  components: {
    template: "#modal-template",
  },
  data() {
    return {
      iniciosesion: true,

      busquedaFarmacia: "",
      Farmacias: [
        {
          idFarmacia: 1,
          farmacia: "Del Pueblo",
          cuil: "256786543",
          domicilio: "Av.Colon 500",
          provincia: "Tucumán",
          localidad: "San Miguel de Tucumán",
          telefono: "4355465",
          correoElectronico: "delpueblo@hotmail.com",
          estado: "A",
        },
        {
          idFarmacia: 2,
          farmacia: "Del Pueblo alem",
          cuil: "252345673",
          domicilio: "Av.Alem 100",
          provincia: "Tucumán",
          localidad: "San Miguel de Tucumán",
          telefono: "4351466",
          correoElectronico: "delpueblo@gmail.com",
          estado: "A",
        },
        {
          idFarmacia: 3,
          farmacia: "Rotonda",
          cuil: "214562345",
          domicilio: "Lamadrid 3300",
          provincia: "Tucumán",
          localidad: "Lules",
          telefono: "4123433",
          correoElectronico: "rotondalamadrid@hotmail.com",
          estado: "A",
        },
      ], //donde guardaremos todas las farmacias que viene del back
      FarmaciasFiltradas: [], //Farmacias filtradas de acuerdo a la busqueda

      busquedaAfiliado: "",
      Afiliados: [
        {
          idUsuario: 1,
          nombres: "Maria",
          apellidos: "Campoo",
          dni: "35678987",
          sexo: "F",
          fechaNacimiento: "15/05/1991",
          usuario: "mariac",
          password: "mariac1234",
          domicilio: "Las rosas 123",
          fechaAlta: "22/12/2022",
          provincia: "Tucumán",
          departamento: "Capital",
          localidad: "San Miguel de Tucumán",
          telefono: "155678987",
          email: "mariacampoo@gmail.com",
          estado: "A",
          tipoAfiliado: "T",
          fechaBaja: null,
          empleador: "Refinor",
          maxPrestacionesMes: 3,
        },
        {
          idUsuario: 2,
          nombres: "Carolina",
          apellidos: "Palomo",
          dni: "32123456",
          sexo: "F",
          fechaNacimiento: "25/04/1989",
          usuario: "carop",
          password: "carop1234",
          domicilio: "Libano 31",
          fechaAlta: "22/12/2022",
          provincia: "Tucumán",
          departamento: "Capital",
          localidad: "San Miguel de Tucumán",
          telefono: "154323456",
          email: "palomoc@hotmail.com",
          estado: "A",
          tipoAfiliado: "T",
          fechaBaja: null,
          empleador: "Nose",
          maxPrestacionesMes: 3,
        },
        {
          idUsuario: 3,
          nombres: "Juan",
          apellidos: "Paz",
          dni: "11234567",
          sexo: "M",
          fechaNacimiento: "08/02/1958",
          usuario: "juanpaz",
          password: "juanp1234",
          domicilio: "Lavalle 2331",
          fechaAlta: "22/12/2022",
          provincia: "Tucumán",
          departamento: "Capital",
          localidad: "San Miguel de Tucumán",
          telefono: "154323456",
          email: "pazj123@hotmail.com",
          estado: "A",
          tipoAfiliado: "H",
          fechaBaja: null,
          empleador: "Nose",
          maxPrestacionesMes: 3,
        },
      ],
      AfiliadosFiltrados: [],

      busquedainstitucionmed: "",
      institucionesmedicas: [],
      institucionesMedicasFiltradas: [],

      Rubros: [],

      busquedaProducto: "",
      Productos: [],
      ProductosFiltrados: [],

      busquedaOrden: "",
      Ordenes: [],
      OrdenesFiltradas: [],

      busquedaPrestacion: "",
      Prestaciones: [],
      PrestacionesMedicasFiltradas: [],

      busquedaLiquidacion: "",
      Liquidaciones: [],
      LiquidacionesFiltradas: [],


      PrestacionesaAutorizarFiltradas:[],

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
  created() {
    this.FarmaciasFiltradas = this.Farmacias;
    this.AfiliadosFiltrados = this.Afiliados;
    this.institucionesMedicasFiltradas = this.institucionesMedicas;
    this.ProductosFiltrados = this.Productos;
    this.OrdenesFiltradas = this.Ordenes;
    this.PrestacionesMedicasFiltradas = this.Prestaciones;
    this.LiquidacionesFiltradas = this.Liquidaciones;
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
    filtrarFarmacias: function () {
      this.FarmaciasFiltradas = this.Farmacias.filter((farm) =>
        farm.farmacia
          .toLowerCase()
          .includes(this.busquedaFarmacia.toLowerCase())
      );
    },
    filtrarAfiliados: function () {
      this.AfiliadosFiltrados = this.Afiliados.filter(
        (afil) =>
          afil.nombres
            .toLowerCase()
            .includes(this.busquedaAfiliado.toLowerCase()) ||
          afil.apellidos
            .toLowerCase()
            .includes(this.busquedaAfiliado.toLowerCase()) ||
          afil.dni.includes(this.busquedaAfiliado)
      );
    },
    filtrarinstitucionmed: function () {
      this.institucionesMedicasFiltradas = this.institucionesmedicas.filter(
        (inst) =>
          inst.institucionMedica
            .toLowerCase()
            .includes(this.busquedainstitucionmed.toLowerCase()) ||
          inst.cuil.includes(this.busquedainstitucionmed)
      );
    },
    filtrarProductos: function () {
      this.ProductosFiltrados = this.Productos.filter(
        (prod) =>
          prod.producto
            .toLowerCase()
            .includes(this.busquedaProducto.toLowerCase()) ||
          prod.fechaVencimiento.includes(this.busquedaProducto)
      );
    },
    filtrarOrdenes: function () {
      this.OrdenesFiltradas = this.Ordenes.filter(
        (orden) =>
          orden.idOrden.includes(this.busquedaOrden.toLowerCase()) ||
          orden.fechaVencimiento.includes(this.busquedaOrden) ||
          orden.fechaEmision.includes(this.busquedaOrden) ||
          orden.fechaAtencion.includes(this.busquedaOrden)
      );
    },
    filtrarPrestaciones: function () {
      this.PrestacionesMedicasFiltradas = this.Prestaciones.filter(
        (prest) =>
          prest.idPrestacion.includes(this.busquedaPrestacion) ||
          prest.fechaVencimiento.includes(this.busquedaPrestacion) ||
          prest.fechaAlta.includes(this.busquedaPrestacion) ||
          prest.fechaBaja.includes(this.busquedaPrestacion) ||
          prest.prestacion
            .toLowerCase()
            .includes(this.busquedaPrestacion.toLowerCase())
      );
    },
    filtrarLiquidaciones: function () {
      this.LiquidacionesFiltradas = this.Liquidaciones.filter(
        (Liquida) =>
          Liquida.idLiquidacion.includes(this.busquedaLiquidacion) ||
          Liquida.fechaLibramiento.includes(this.busquedaLiquidacion)
      );
    },
    filtrarPrestacionesaAutorizar: function () {
      this.PrestacionesaAutorizarFiltradas = this.Prestaciones.filter(
        (autorizar) => autorizar.estado = 'P' //estado sea pendiente de la prestacion
      );
    }

  },
}).mount("#app");
