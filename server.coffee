if Meteor.isServer

	Meteor.startup ->
		coll.pasien._ensureIndex 'regis.nama_lengkap': 1

	Meteor.publish 'coll', (name, selector, options) ->
		coll[name].find selector, options

	Meteor.publish 'users', ->
		Meteor.users.find({})

	Meteor.methods
		import: (name, selector, modifier) ->
			coll[name].upsert selector, $set: modifier

		export: (jenis) ->
			if jenis is 'regis'
				arr = _.map coll.pasien.find().fetch(), (i) ->
					no_mr: i.no_mr
					nama_lengkap: i.regis.nama_lengkap
			else if jenis is 'jalan'
				find = (type, value) ->
					doc = _.find selects[type], (i) -> i.value is value
					doc.label
				arr = _.flatMap coll.pasien.find().fetch(), (i) ->
					if i.rawat then _.map i.rawat, (j) ->
						no_mr: i.no_mr
						nama_lengkap: i.regis.nama_lengkap
						idbayar: j.idbayar
						cara_bayar: find 'cara_bayar', j.cara_bayar
						klinik: find 'klinik', j.klinik
			exportcsv.exportToCSV arr, true, ';'

		billCard: (no_mr, state) ->
			selector = no_mr: parseInt no_mr
			modifier = $set: 'regis.billCard': state
			coll.pasien.update selector, modifier

		billRegis: (no_mr, idbayar, state) ->
			selector = 'rawat.idbayar': idbayar, no_mr: parseInt no_mr
			modifier = $set: 'rawat.$.billRegis': state
			coll.pasien.update selector, modifier

		bayar: (no_mr, idbayar) ->
			selector = 'rawat.idbayar': idbayar, no_mr: parseInt no_mr
			modifier = 'rawat.$.status_bayar': true
			coll.pasien.update selector, $set: modifier

		request: (no_mr, idbayar, jenis, idjenis, hasil) ->
			selector = no_mr: parseInt no_mr
			findPasien = coll.pasien.findOne selector
			for i in findPasien.rawat
				if i.idbayar is idbayar then if i[jenis] then for j in i[jenis]
					if j['id'+jenis] is idjenis then j.hasil = hasil
			modifier = rawat: findPasien.rawat
			coll.pasien.update selector, $set: modifier
			give = {}
			if jenis is 'obat' then for i in findPasien.rawat
				if i.idbayar is idbayar then if i.obat then for j in i.obat
					if j.idobat is idjenis
						findStock = coll.gudang.findOne _id: j.nama
						for k in [1..j.jumlah]
							filtered = _.filter findStock.batch, (l) -> l.diapotik > 0
							sortedIn = _.sortBy filtered, (l) -> new Date(l.masuk).getTime()
							sortedEd = _.sortBy sortedIn, (l) -> new Date(l.kadaluarsa).getTime()
							sortedEd[0].diapotik -= 1
							unless give[sortedEd[0].nobatch] then give[sortedEd[0].nobatch] = 0
							give[sortedEd[0].nobatch] += 1
						selector = _id: findStock._id
						modifier = $set: batch: findStock.batch
						coll.gudang.update selector, modifier
			if jenis is 'obat' then give

		transfer: (idbarang, idbatch, amount) ->
			selector = idbarang: idbarang, 'batch.idbatch': idbatch
			modifier = $inc: 'batch.$.digudang': -amount, 'batch.$.diapotik': amount
			coll.gudang.update selector, modifier

		rmPasien: (no_mr) ->
			coll.pasien.remove no_mr: parseInt no_mr

		rmRawat: (no_mr, idbayar) ->
			selector = no_mr: parseInt no_mr
			modifier = $pull: rawat: idbayar: idbayar
			coll.pasien.update selector, modifier

		addRole: (id, roles, group, poli) ->
			role = poli or roles
			Roles.addUsersToRoles id, role, group

		rmRole: (id) ->
			selector = _id: id
			modifier = $set: roles: {}
			Meteor.users.update selector, modifier

		newUser: (doc) ->
			find = Accounts.findUserByUsername doc.username
			if find
				Accounts.setUsername find._id, doc.username
				Accounts.setPassword find._id, doc.password
			else
				Accounts.createUser doc

		rmBarang: (idbarang) ->
			coll.gudang.remove idbarang: idbarang
		
		pindah: (no_mr) ->
			find = coll.pasien.findOne 'no_mr': parseInt no_mr
			if find.rawat[find.rawat.length-1].pindah
				selector = _id: find._id
				modifier = $push: rawat:
					idbayar: Math.random().toString(36).slice(2)
					tanggal: new Date()
					cara_bayar: find.rawat[find.rawat.length-1].cara_bayar
					klinik: find.rawat[find.rawat.length-1].pindah
					billRegis: true
					total: semua: 0
				coll.pasien.update selector, modifier

		report: (jenis, start, end) ->
			filter = (arr) -> _.filter arr, (i) ->
				new Date(start) < new Date(i.tanggal) < new Date(end)
			look = (list, val) -> _.find selects[list], (i) -> i.value is val
			if jenis is 'pendaftaran'
				headers: ['No. MR', 'Nama', 'Cara Bayar', 'Rujukan', 'Klinik', 'B/L']
				rows: _.flatMap coll.pasien.find().fetch(), (i) -> _.map filter(i.rawat), (j) ->
					[
						i.no_mr
						_.startCase i.regis.nama_lengkap
						look('cara_bayar', j.cara_bayar).label
						look('rujukan', j.rujukan).label
						look('klinik', j.klinik).label
						'L'
					]
			else if jenis is 'pembayaran'
				headers: ['Tanggal', 'No. Bill', 'No. MR', 'Nama', 'Ruangan', 'Layanan', 'Harga', 'Petugas']
				rows: _.flatMap coll.pasien.find().fetch(), (i) -> _.map filter(i.rawat), (j) ->
					[
						moment(j.tanggal).format('D MMM YYYY')
						j.nobill
						i.no_mr
						_.startCase i.regis.nama_lengkap
						look('klinik', j.klinik).label
						_.flatMap ['tindakan', 'labor', 'radio'], (k) -> _.filter j[k], (l) -> l
						'Rp ' + j.total.semua
						Meteor.users.findOne(_id: j.petugas).username
					]
			else if jenis is 'rawat_jalan'
				headers: ['Tanggal', 'No. MR', 'Nama', 'Kelamin', 'Umur', 'Cara Bayar', 'Diagnosa', 'Tindakan', 'Dokter', 'Keluar', 'Rujukan']
				rows: _.flatMap coll.pasien.find().fetch(), (i) -> _.map filter(i.rawat), (j) ->
					[
						moment(j.tanggal).format('D MMM YYYY')
						i.no_mr
						_.startCase i.regis.nama_lengkap
						look('kelamin', i.regis.kelamin).label
						moment().diff(i.regis.tgl_lahir, 'years')
						look('cara_bayar', j.cara_bayar).label
						j.diagnosa
						'-'
						Meteor.user().username
						look('keluar', j.keluar).label
						look('rujukan', j.rujukan).label
					]
