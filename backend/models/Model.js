var mongoose = require('mongoose')
	, Schema = mongoose.Schema

var groupSchema = Schema({
	total: { type: Number, default: 0},
	creator: { type: String, ref: 'User'},
	name: String,
	created: { type: Date, default: Date.now },
	users: [{ type: String, ref: 'User' }],
	expenses: [{ type: String, ref: 'Expense', default: [] }]
});

var userSchema = Schema({
	phone: {type: String, index: {unique: true}},
	firstname: String,
	lastname: String,
	email: String
});

var expenseSchema = Schema({
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

var accountSchema = Schema({
	groupId: String,
	debtor: { type: String, ref: 'User' },
	creditor: { type: String, ref: 'User' },
	amount: Number,
	status: { type: Number, default: 0 },
	updated: { type: Date, default: Date.now }
});

var messageSchema = Schema({
	sender: { type: String, ref: 'User' },
	receiver: { type: String, ref: 'User' },
	created: { type: Date, default: Date.now },
	message: String
});

module.exports.Group = mongoose.model('Group', groupSchema);
module.exports.User = mongoose.model('User', userSchema);
module.exports.Expense = mongoose.model('Expense', expenseSchema);
module.exports.Account = mongoose.model('Account', accountSchema);
module.exports.Message = mongoose.model('Message', messageSchema);