var express = require('express');
var router = express.Router();

var mongoose = require('mongoose');
var Model = require('../models/Model.js');

// POST users
router.post('/users', function(req, res, next) {
    Model.User.create(req.body, function(err, post) {
        if (err) return next(err);
        res.json(post);
    });
});



// user by id
router.get('/:uid', function(req, res, next) {
    Model.User.findById(req.params.uid, function(err, user) {
        if (err) return next(err);
        res.json(user);
    });
});
router.put('/:uid', function(req, res, next) {
    Model.User.findByIdAndUpdate(req.params.uid, function(err, user) {
        if (err) return next(err);
        res.json(user);
    });
});
router.delete('/:uid', function(req, res, next) {
    Model.User.findByIdAndRemove(req.params.uid, function(err, status) {
        if (err) return next(err);
        res.json(status);
    });
});


// groups by user
router.get('/:uid/groups', function(req, res, next) {
    Model.Group
        .find({ 'users': req.params.uid })
        .select('name users')
        .sort({created: 'desc'})
        .populate('users')
        .exec(function(err, groups) {
            if (err) return next(err);
            res.json(groups);
        });
});
router.post('/:uid/groups/', function(req, res, next) {
    var data = req.body;
    data.creator = req.params.uid;

    var users = data.users;
    var count = users.length;
    var complete = 0;

    data.users = [];
    for (i in users) {
        var user = new Model.User(users[i]);
        Model.User.findOneAndUpdate(
        	{ "phone": user.phone },
            users[i],
            { new: true, upsert: true },
            function(err, post) {
                if (err) {
                    console.log("Error upserting user " + i);
                    console.log(err);
                } else {
                    data.users.push(post._id);
                    complete++;
                    if (complete === count) {
                        data.users.push(data.creator);
                        Model.Group.create(data, function(err, rawGroup) {
					        if (err) return next(err);
                            Model.Group
                                .populate(rawGroup, 
                                    {path: 'users'}, 
                                    function(err, group) {
                                        if (err) return next(err);
                                        console.log(group);
                                        return res.json(group);
                                    });
					    });
                    }
                }
            });
    }
});


// group by groupId and userId
router.get('/:uid/groups/:groupId', function(req, res, next) {
    Model.Group
            .findById(req.params.groupId)
            .select('name creator expenses users')
            .populate( {
                path: 'expenses users',
                select: 'name total whoPayed whoTookPart firstname lastname phone',
                options: { sort: { 'created': 'desc'}}
            })
            .lean() // to return JS instead of mongoose document
            .exec(function(err, group) {
                if (err) return next(err);
                group.personalTotal = getTotalAccountForUser(req.params.uid, group.expenses);
                res.json(group);
            });
});
router.put('/:uid/groups/:groupId', function(req, res, next) {
    Model.Group.findByIdAndUpdate(req.params.groupId, 
            function(err, group) {
                if (err) return next(err);
                group.personalTotal = getTotalAccountForUser(req.params.uid, group.expenses);
                res.json(group);
            });
});
router.delete('/:uid/groups/:groupId', function(req, res, next) {
    Model.Group.findByIdAndRemove(req.params.groupId,
            function(err, status) {
                if (err) return next(err);
                res.json(status);
            });
});


// expenses by groupId and userId
router.get('/:uid/groups/:groupId/expenses', function(req, res, next) {
    Model.Expense
        .find({
            'groupId': req.params.groupId
        })
        .sort({'created': 'desc'})
        .populate('whoPayed.user whoTookPart.user')
        .exec( function(err, expenses) {
            if (err) return next(err);
            res.json(expenses);
        });
});
router.post('/:uid/groups/:groupId/expenses', function(req, res, next) {
    var data = req.body;
    data.groupId = req.params.groupId;
    var total = 0.0
    for (var i in data.whoPayed) {
        var amount = data.whoPayed[i].amount;
        total += amount;
    }
    data.total = total;

    Model.Expense.create(data, function(err, expense) {
        if (err) return next(err);
        var returnData = {
            "expense": expense
        };

        Model.Group.findByIdAndUpdate(
            req.params.groupId, 
            {   
                $inc: {"total": expense.total},
                $push: {"expenses": expense._id} 
            }, 
            { safe: true, upsert: true, new: true },
            function(err, rawGroup) {
                if (err) return next(err);
                Model.Group.populate(rawGroup, {path: "expenses"}, function (err, group) {
                    if (err) return next(err);
                        updateAccounts(group);
                        res.json(expense);
                });
            });
    });
});


// expense by id
router.put('/:uid/groups/:groupId/expenses/:expenseId', function(req, res, next) {
    Model.Expense
        .findByIdAndUpdate(req.params.expenseId, function(err, expense) {
            if (err) return next(err);
            res.json(expense);
        });
});
router.delete('/:uid/groups/:groupId/expenses/:expenseId', function(req, res, next) {
    Model.Expense
        .findByIdAndRemove(req.params.expenseId, function(err, status) {
            if (err) return next(err);
            res.json(status);
        });
});


// accounts by groupId and userId
router.get('/:uid/groups/:groupId/accounts', function(req, res, next) {
    Model.Account
        .find({ 'groupId': req.params.groupId})
        .exec( function(err, accounts) {
            if (err) return next(err);
            res.json(accounts);
        });
});


// accounts by user
router.get('/:uid/accounts', function(req, res, next) {
    Model.Account
        .find().or([
                { 'creditor': req.params.uid },
                { 'debtor': req.params.uid }
        ])
        .sort({'updated': 'desc'})
        .exec( function(err, accounts) {
            if (err) return next(err);
            res.json(accounts);
        });
});

// account by id
router.put('/:uid/accounts/:accountId', function(req, res, next) {
    Model.Account
        .findByIdAndUpdate(req.params.accountId, function(err, account) {
            if (err) return next(err);
            res.json(account);
        });
});
router.delete('/:uid/accounts/:accountId', function(req, res, next) {
    Model.Account
        .findByIdAndRemove(req.params.accountId, function(err, status) {
            if (err) return next(err);
            res.json(status);
        });
});


// messages for or from user
router.get('/:uid/messages', function(req, res, next) {
    Model.Message
        .find({
            'receiver': req.params.uid
        })
        .sort({'created': 'desc'})
        .exec( function(err, messages) {
            if (err) return next(err);
            res.json(messages);
        });
});
router.post('/:uid/messages', function(req, res, next) {
    var data = req.body;
    data.sender = req.params.uid;
    Model.Message
        .create(data, function(err, message) {
            if (err) return next(err);
            res.json(message);
        });
});

// message by id
router.delete('/:uid/messages/:messageId', function(req, res, next) {
    Model.Message
        .findByIdAndRemove(req.params.messageId, function(err, status) {
            if (err) return next(err);
            res.json(status);
        });
});



function updateAccounts(group) {
    var accounts = calculateAccount(group);

    Model.Account
        .find({
            'groupId': group["_id"]
        })
        .remove( function(err, status) {
            if (err) return next(err);
            Model.Account.create(accounts, function(err, accounts) {
                console.log("updated accounts successfully ");
            });
        });
}

function calculateAccount(group) {
    var pays = [];
    var gets = [];

    var accounts = [];

    for (var i=0; i<group.users.length; i++) {
        var uid = group.users[i];
        var amount = getTotalAccountForUser(uid, group.expenses);
        var pushObject = {
                "user": uid,
                "amount": amount
        };
        if (amount > 0) {
            gets.push(pushObject);
        } else if (amount < 0) {
            pushObject["amount"] *= -1;
            pays.push(pushObject);
        }
    }
    sortByKey(gets, "amount");
    sortByKey(pays, "amount");


    var cnt = pays.length;
    if (gets.length < cnt) {
        cnt = gets.length;
    }

    var moneyLeftToPay = true;


    if (cnt < 1) {
        moneyLeftToPay = false;
    }
 
    while(moneyLeftToPay) {
        var getAmount = gets[0].amount;
        var payAmount = pays[0].amount;
        var accountAmount = 0;
        if (getAmount == payAmount) {
            //console.log("same");
            printStatus(pays[0].user, payAmount, gets[0].user);

            accountAmount = payAmount;
            getAmount = 0.0;
            payAmount = 0.0;
        } else if (getAmount > payAmount) {
            //console.log("higher");
            printStatus(pays[0].user, payAmount, gets[0].user);

            accountAmount = payAmount;
            getAmount -= payAmount;
            payAmount = 0.0;
        } else if (getAmount < payAmount) {
            //console.log("lower");
            printStatus(pays[0].user, getAmount, gets[0].user);

            accountAmount = getAmount;
            payAmount -= getAmount;
            getAmount = 0.0;
        }

        accounts.push({
            "groupId": group["_id"],
            "debtor": pays[0].user,
            "creditor": gets[0].user,
            "amount": accountAmount
        });

        // put new amounts back to list and sort to compare the highest value
        gets[0].amount = getAmount;
        pays[0].amount = payAmount;
        
        sortByKey(gets, "amount");
        sortByKey(pays, "amount");

        if (gets[0].amount == 0.0 && pays[0].amount == 0.0) {
            moneyLeftToPay = false;
        } else if (gets[0].amount < 0.01 || pays[0].amount < 0.01) {
            //console.log("GETS: " + gets[0].amount);
            //console.log("PAYS: " + pays[0].amount);
            moneyLeftToPay = false;
        }
    }
    return accounts;
}

function getTotalAccountForUser(user, expenses) {
    var userHasToPay = 0.0
    var userHasPayed = 0.0
    for (var i in expenses) {
        var expense = expenses[i];
        for (var j in expense.whoPayed) {
            var payer = expense.whoPayed[j].user;
            if (user == payer) {
                userHasPayed += expense.whoPayed[j].amount;
            }
        }
        for (var k in expense.whoTookPart) {
            var payer = expense.whoTookPart[k].user;
            if (user == payer) {
                userHasToPay -= expense.whoTookPart[k].amount;
            }
        }
    }
    var total = userHasPayed + userHasToPay;
    total = Math.round(total * 100) / 100;
    console.log(user + "'s total: " + total);

    return total;
}

function printStatus(first, amount, second) {
    console.log(first + " pays " + amount + "€ to " + second);
}
function sortByKey(array, key) {
    return array.sort(function(a, b) {
        var x = a[key]; var y = b[key];
        return ((x > y) ? -1 : ((x < y) ? 1 : 0));
    });
}




// DEBUGGING & TESTING

// GET users
router.get('/users', function(req, res, next) {
    var phone = req.query.phone;
    var uid = req.query.uid;
    if (phone) {
        console.log(phone);
        Model.User.findOne({'phone': phone},'_id', function(err, uid) {
            if (err) return next(err);
            console.log(uid);
            res.json(uid);
        });
    } else if (uid) {
        Model.User
            .findById(uid)
            .exec(function(err, user) {
                if (err) return next(err);
                console.log(user);
                res.json(user);
            });
    } else {
        Model.User.find(function(err, users) {
            if (err) return next(err);
            console.log(users);
            res.json(users);
        });
    }
});
// GET groups
router.get('/groups', function(req, res, next) {
    var groupId = req.query.groupId;
    if (groupId) {
        Model.Group
            .findById(groupId)
            .exec(function(err, group) {
                if (err) return next(err);
                console.log(group);
                console.log("Das war find group by id");
                res.json(group);
            });
    } else {
        Model.Group.find(function(err, groups) {
            console.log(groups);
            res.json(groups);
        });
    }
});
// GET expenses
router.get('/expenses', function(req, res, next) {
    var expenseId = req.query.expenseId
    if (expenseId) {
        console.log("find expense by id");

        Model.Expense
            .findById(expenseId)
            .exec(function(err, expense) {
                if (err) return next(err);
                console.log(expense);
                console.log("Das war find expense by id");

                res.json(expense);
            });
    } else {
        Model.Expense.find(function(err, expenses) {
            if (err) return next(err);
            console.log(expenses);
            res.json(expenses);
        });
    }
});

// DELETE all users
router.delete('/users', function(req, res, next) {
    Model.User.remove({}, function(err, status) {
        if (err) return next(err);
        console.log(status);
        res.json(status);
    });
});
//DELETE all groups
router.delete('/groups', function(req, res, next) {
    Model.Group.remove({}, function(err, status) {
        if (err) return next(err);
        res.json(status);
    });
});
// DELETE all expenses
router.delete('/expenses', function(req, res, next) {
    Model.Expense.remove({}, function(err, status) {
        if (err) return next(err);
        res.json(status);
    });
});

// DELETE all groups a user has created
router.delete('/:uid/groups/', function(req, res, next) {
    Model.Group.find({
        'creator': req.params.uid
    }).remove(function(err, status) {
        if (err) return next(err);
        console.log(status);
        res.json(status);
    });
});



module.exports = router;