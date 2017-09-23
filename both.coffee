_ = lodash

Router.configure
	layoutTemplate: 'layout'
	loadingTemplate: 'loading'

Router.route '/',
	action: -> this.render 'home'

@coll = {}
@schema = {}

schema.regis =
	no_mr: type: Number
	regis: type: Object
	'regis.nama_lengkap': type: String
	'regis.tgl_lahir': type: Date
	'regis.tmpt_lahir': type: String
	'regis.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'regis.kelamin': type: Number, autoform: options: selects.kelamin, type: 'select-radio-inline'
	'regis.agama': type: Number, autoform: options: selects.agama, type: 'select-radio-inline'
	'regis.nikah': type: Number, autoform: options: selects.nikah, type: 'select-radio-inline'
	'regis.pendidikan': type: Number, autoform: options: selects.pendidikan, type: 'select-radio-inline'
	'regis.darah': type: Number, autoform: options: selects.darah, type: 'select-radio-inline'
	'regis.pekerjaan': type: Number, autoform: options: selects.pekerjaan, type: 'select-radio-inline'
	'regis.alamat': type: String
	'regis.kelurahan': type: String
	'regis.kecamatan': type: String
	'regis.kabupaten': type: String
	'regis.kontak': type: String
	'regis.ayah': type: String
	'regis.ibu': type: String
	'regis.pasangan': type: String
	'regis.petugas': type: String
	'regis.date': type: Date

schema.labor =
	idlabor: type: String, optional: true, autoform: type: 'hidden'
	labors: type: Number, autoform: options: selects.labors
	harga: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.radio =
	idradio: type: String, optional: true, autoform: type: 'hidden'
	radios: type: Number, autoform: options: selects.radios
	harga: type: Number, optional: true, autoform: type: 'hidden'
	hasil: type: String, optional: true, autoform: type: 'hidden'

schema.obat =
	idobat: type: String, optional: true, autoform: type: 'hidden'
	obats: type: Number, autoform: options: selects.obats
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
	'rawat.$.idbayar': type: String, autoform: type: 'hidden'
	'rawat.$.jenis': type: Number, autoform: options: selects.rawats
	'rawat.$.tanggal': type: Date
	'rawat.$.cara_bayar': type: Number, autoform: options: selects.cara_bayar, type: 'select-radio-inline'
	'rawat.$.klinik': type: Number, autoform: options: selects.klinik, type: 'select-radio-inline'
	'rawat.$.diagnosa': type: String
	'rawat.$.tindakan': type: Number
	'rawat.$.dokter': type: Number
	'rawat.$.status_bayar': type: Number, optional: true, autoform: type: 'hidden'
	'rawat.$.labor': type: [new SimpleSchema schema.labor]
	'rawat.$.radio': type: [new SimpleSchema schema.radio]
	'rawat.$.obat': type: [new SimpleSchema schema.obat]
	'rawat.$.total': type: Object, optional: true, autoform: type: 'hidden'
	'rawat.$.total.labor': type: Number, optional: true
	'rawat.$.total.radio': type: Number, optional: true
	'rawat.$.total.obat': type: Number, optional: true
	'rawat.$.total.semua': type: Number, optional: true

schema.jalan = Object.assign {}, schema.rawat

coll.pasien = new Meteor.Collection 'pasien'
coll.pasien.allow
	insert: -> true
	update: -> true
	remove: -> true

makeRoute = (modul) ->
	Router.route '/'+modul+'/:no_mr?',
		name: modul
		action: -> this.render 'modul'

makeRoute i.name for i in modules[0..9]