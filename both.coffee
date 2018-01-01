@_ = lodash

Router.configure
	layoutTemplate: 'layout'
	loadingTemplate: 'loading'

Router.route '/',
	action: -> this.render 'home'

@coll = {}
@schema = {}

randomId = -> Math.random().toString(36).slice(2)

schema.regis =
	no_mr: type: Number
	regis: type: Object
	'regis.nama_lengkap': type: String
	'regis.tgl_lahir': type: Date, autoform: type: 'pickadate', pickadateOptions: selectYears: 150, selectMonths: true
	'regis.tmpt_lahir': type: String, optional: true
	'regis.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'regis.kelamin': type: Number, autoform: options: selects.kelamin, type: 'select-radio-inline'
	'regis.agama': type: Number, autoform: options: selects.agama, type: 'select-radio-inline'
	'regis.nikah': type: Number, autoform: options: selects.nikah, type: 'select-radio-inline'
	'regis.pendidikan': type: Number, optional: true, autoform: options: selects.pendidikan, type: 'select-radio-inline'
	'regis.darah': type: Number, optional: true, autoform: options: selects.darah, type: 'select-radio-inline'
	'regis.pekerjaan': type: Number, optional: true, autoform: options: selects.pekerjaan, type: 'select-radio-inline'
	'regis.kabupaten': type: String, optional: true, autoform: options: selects.kabupaten
	'regis.kecamatan': type: String, optional: true, autoform: options: selects.kecamatan, type: 'universe-select'
	'regis.kelurahan': type: String, optional: true
	'regis.alamat': type: String
	'regis.kontak': type: String, optional: true
	'regis.ayah': type: String, optional: true
	'regis.ibu': type: String, optional: true
	'regis.pasangan': type: String, optional: true
	'regis.petugas':
		type: String
		autoform: type: 'hidden'
		autoValue: -> if Meteor.isClient then Meteor.userId()
	'regis.date':
		type: Date
		autoform: type: 'hidden'
		autoValue: -> new Date
	'regis.billCard': type: Boolean, optional: true, autoform: type: 'hidden'

schema.tindakan =
	idtindakan: type: String, optional: true, autoform: type: 'hidden'
	nama: type: String, autoform: options: selects.tindakan
	dokter: type: String, autoform: options: selects.dokter
	harga: type: Number, optional: true, autoform: type: 'hidden'

schema.labor =
	idlabor: type: String, optional: true, autoform: type: 'hidden'
	nama: type: String, autoform: options: selects.labor
	harga: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.radio =
	idradio: type: String, optional: true, autoform: type: 'hidden'
	nama: type: String, autoform: options: selects.radio
	harga: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.obat =
	idobat: type: String, optional: true, autoform: type: 'hidden'
	nama: type: String, autoform: options: selects.obat
	puyer: type: String, optional: true
	aturan: type: Object
	'aturan.kali': type: Number
	'aturan.dosis': type: Number
	'aturan.bentuk': type: Number, autoform: options: selects.bentuk
	jumlah: type: Number
	harga: type: Number, optional: true, autoform: type: 'hidden'
	subtotal: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.rawat =
	no_mr: type: Number
	rawat: type: Array
	'rawat.$': type: Object
	'rawat.$.tanggal': type: Date, autoform: type: 'hidden'
	'rawat.$.idbayar': type: String, optional: true, autoform: type: 'hidden'
	'rawat.$.jenis': type: String, optional: true, autoform: type: 'hidden'
	'rawat.$.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'rawat.$.klinik': type: Number, autoform: options: selects.klinik, type: 'select-radio-inline'
	'rawat.$.billRegis': type: Boolean, optional: true, autoform: type: 'hidden'
	'rawat.$.status_bayar': type: Boolean, optional: true, autoform: type: 'hidden'
	'rawat.$.rujukan': type: Number, optional: true, autoform: options: selects.rujukan, type: 'select-radio-inline'
	'rawat.$.anamesa': type: String, optional: true
	'rawat.$.diagnosa': type: String, optional: true
	'rawat.$.tindakan': type: [new SimpleSchema schema.tindakan], optional: true
	'rawat.$.labor': type: [new SimpleSchema schema.labor], optional: true
	'rawat.$.radio': type: [new SimpleSchema schema.radio], optional: true
	'rawat.$.obat': type: [new SimpleSchema schema.obat], optional: true
	'rawat.$.total': type: Object, optional: true, autoform: type: 'hidden'
	'rawat.$.total.tindakan': type: Number, optional: true
	'rawat.$.total.labor': type: Number, optional: true
	'rawat.$.total.radio': type: Number, optional: true
	'rawat.$.total.obat': type: Number, optional: true
	'rawat.$.total.semua': type: Number, optional: true
	'rawat.$.spm': type: Number, optional: true, autoform: type: 'hidden'
	'rawat.$.pindah': type: Number, optional: true, autoform: options: selects.klinik
	'rawat.$.keluar': type: Number, optional: true, autoform: options: selects.keluar
	'rawat.$.petugas': type: String, autoform: type: 'hidden'

schema.jalan = Object.assign {}, schema.rawat
schema.inap = Object.assign {}, schema.rawat
schema.igd = Object.assign {}, schema.rawat

schema.gudang =
	idbarang:
		type: String
		autoform: type: 'hidden'
		autoValue: -> randomId()
	jenis: type: Number, autoform: options: selects.barang
	nama: type: String
	batch: type: Array
	'batch.$': type: Object
	'batch.$.idbatch':
		type: String
		autoform: type: 'hidden'
		autoValue: -> randomId()
	'batch.$.nobatch': type: String
	'batch.$.masuk': type: Date, autoform: type: 'pickadate'
	'batch.$.kadaluarsa': type: Date, autoform: type: 'pickadate'
	'batch.$.digudang': type: Number
	'batch.$.diapotik': type: Number
	'batch.$.beli': type: Number, decimal: true
	'batch.$.jual': type: Number, decimal: true
	'batch.$.suplier': type: String
	'batch.$.anggaran': type: String
	'batch.$.pengadaan': type: Number

schema.farmasi = Object.assign {}, schema.gudang
schema.logistik = Object.assign {}, schema.gudang

schema.dokter =
	nama: type: String
	tipe: type: Number, autoform: options: selects.tipe_dokter
	poli: type: Number, autoform: options: selects.klinik

schema.tarif =
	jenis: type: String
	nama: type: String
	harga: type: Number
	grup: type: String, optional: true

_.map ['pasien', 'gudang', 'dokter', 'tarif'], (i) ->
	coll[i] = new Meteor.Collection i
	coll[i].allow
		insert: -> true
		update: -> true
		remove: -> true

makePasien = (modul) ->
	Router.route '/'+modul+'/:no_mr?',
		name: modul
		action: -> this.render 'pasien'
		waitOn: ->
			_.map ['dokter', 'tarif', 'gudang'], (i) ->
				Meteor.subscribe 'coll', i, {}, {}

makePasien i.name for i in modules[0..9]

makeGudang = (modul) ->
	Router.route '/'+modul+'/:idbarang?',
		name: modul
		action: -> this.render 'gudang'

makeGudang i.name for i in modules[10..11]

makeOther = (name) ->
	Router.route '/' + name,
		action: -> this.render name

makeOther i for i in ['panduan']

Router.route '/manajemen',
	action: -> this.render 'manajemen'
	waitOn: -> [
		Meteor.subscribe 'users'
		Meteor.subscribe 'coll', 'dokter', {}, {}
		Meteor.subscribe 'coll', 'tarif', {}, {}
	]

Router.route '/login', ->
	action: -> this.render 'login'
