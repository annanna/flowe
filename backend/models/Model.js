var mongoose = require('mongoose')
	, Schema = mongoose.Schema

var groupSchema = Schema({
	total: { type: Number, default: 0},
	creator: { type: String, ref: 'User'},
	name: String,
	created: { type: Date, default: Date.now },
	users: [{ type: String, ref: 'User' }],
	transfers: [{ type: String, ref: 'Transfer', default: [] }]
});

var userSchema = Schema({
	phone: {type: String, index: {unique: true}},
	firstname: String,
	lastname: String,
	email: String
});

var oldTransferSchema = Schema({
	groupId: String,
	name: String,
	total: Number,
	creator: {type: String, ref: 'User'},
	created: { type: Date, default: Date.now },
	notes: String,
	whoPayed: [{
		user: { type: String, ref: 'User'},
		amount: Number
	}],
	whoTookPart: [{
		user: { type: String, ref: 'User'},
		amount: Number
	}] 
});

var newTransferSchema = Schema({
	groupId: String,
	name: String,
	total: Number,
	creator: { type: String, ref: 'User' },
	created: { type: Date, default: Date.now },
	notes: String,
	users: [{
		user: { type: String, ref: 'User' },
		payed: Number,
		participated: Number
	}]
})

module.exports.Group = mongoose.model('Group', groupSchema);
module.exports.User = mongoose.model('User', userSchema);
module.exports.Transfer = mongoose.model('Transfer', oldTransferSchema);
