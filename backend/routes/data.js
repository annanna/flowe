var express = require('express');
var router = express.Router();

var mongoose = require('mongoose');
var Model = require('../models/Model.js');

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




// GET user details by id
router.get('/:uid', function(req, res, next) {
    console.log("get user details by id");
    Model.User.findById(req.params.uid, function(err, user) {
        if (err) return next(err);
        console.log(user);
        res.json(user);
    });
});
// DELETE user by id
router.delete('/:uid', function(req, res, next) {
    Model.User.findOneAndRemove({"_id":req.params.uid}, function(err, status) {
        if (err) return next(err);
        console.log(status);
        res.json(status);
    });
});
// POST users
router.post('/users', function(req, res, next) {
    Model.User.create(req.body, function(err, post) {
        if (err) return next(err);
        console.log(post);
        res.json(post);
    });
});



// GET groups of an user
router.get('/:uid/groups', function(req, res, next) {
    Model.Group
        .find({ 'users': req.params.uid })
        .select('name users')
        .sort({created: 'desc'})
        .populate('users')
        .exec(function(err, groups) {
            if (err) return next(err);
            console.log(groups);
            res.json(groups);
        });
});
// POST group created by uid
router.post('/:uid/groups/', function(req, res, next) {
    var data = req.body;
    console.log(req.body.name);
    console.log(req.body.users);
    data.creator = req.params.uid;

    var users = data.users;
    var count = users.length;
    var complete = 0;

    data.users = [];
    for (i in users) {
        var user = new Model.User(users[i]);
        Model.User.findOneAndUpdate(
        	{ "phone": user.phone }, //query
            users[i], // update
            { new: true, upsert: true }, // create if does not exist
            function(err, post) { // callback
                if (err) {
                    console.log("Error upserting user " + i);
                    console.log(err);
                } else {
                    data.users.push(post._id);
                    complete++;
                    if (complete === count) {
                        data.users.push(data.creator);
                        Model.Group.create(data, function(err, post) {
					        if (err) return next(err);
                            Model.Group
                                .findById(post["_id"])
                                .populate('users')
                                .exec(function(err, group) {
                                    if (err) return next(err);
                                    console.log(group);
                                    return res.json(group);
                                })
					    });
                    }
                }
            });
    }
});
// GET group by groupId and userId
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
                console.log("Das war find group by id");
                res.json(group);
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

// POST expense
router.post('/:uid/groups/:groupId/expenses', function(req, res, next) {
    console.log("post expense");
    console.log(req.body);
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
            function(err, group) {
                if (err) return next(err);
                var personalTotal = getTotalAccountForUser(req.params.uid, group.expenses);
                console.log(personalTotal);
                console.log(expense);
                res.json(expense);
            });
    });
});

// GET expenses by group
router.get('/:uid/groups/:groupId/expenses', function(req, res, next) {
    console.log("get expenses");
    Model.Expense
        .find({
            'groupId': req.params.groupId
        })
        .sort({'created': 'desc'})
        .populate('whoPayed.user whoTookPart.user')
        .exec( function(err, expenses) {
            if (err) return next(err);
            console.log(expenses);
            res.json(expenses);
        });
});

router.get('/:uid/groups/:groupId/accounts', function(req, res, next) {
    console.log("get accounts");
    //format [{user: User, action: String, amount: Double, partner: User}] 
    Model.Group
        .findById(req.params.groupId)
        .select('expenses users')
        .populate('expenses users')
        .lean() // to return JS instead of mongoose document
        .exec(function(err, group) {
            if (err) return next(err);
            var accounts = calculatePersonalTotal(group, req.params.uid);
            console.log(accounts);
            res.json(accounts);
        });
});

function calculatePersonalTotal(group, currentUser) {
    var allAccounts = calculateAccount(group);
    var userAccounts = [];

    for (var i in allAccounts) {
        var uid = allAccounts[i].user["_id"];
        if (currentUser == uid) {
            userAccounts.push(allAccounts[i]);
        }
    }
    return userAccounts;
}

function calculateAccount(group) {
    var pays = [];
    var gets = [];

    var accounts = [];

    for (var i in group.users) {
        var user = group.users[i];
        var uid = user["_id"];
        var amount = getTotalAccountForUser(uid, group.expenses);
        var pushObject = {
                "user": user,
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

        if (getAmount == payAmount) {
            console.log("same");
            printStatus(pays[0].user, payAmount, gets[0].user);

            accounts.push({
                "user": pays[0].user,
                "action": "pay",
                "amount": payAmount,
                "partner": gets[0].user
            });
            accounts.push({
                "user": gets[0].user,
                "action": "get",
                "amount": payAmount,
                "partner": pays[0].user
            });

            getAmount = 0.0;
            payAmount = 0.0;
        } else if (getAmount > payAmount) {
            console.log("higher");
            printStatus(pays[0].user, payAmount, gets[0].user);
            accounts.push({
                "user": pays[0].user,
                "action": "pay",
                "amount": payAmount,
                "partner": gets[0].user
            });
            accounts.push({
                "user": gets[0].user,
                "action": "get",
                "amount": payAmount,
                "partner": pays[0].user
            });


            getAmount -= payAmount;
            payAmount = 0.0;
        } else if (getAmount < payAmount) {
            console.log("lower");
            printStatus(pays[0].user, getAmount, gets[0].user);

            accounts.push({
                "user": pays[0].user,
                "action": "pay",
                "amount": getAmount,
                "partner": gets[0].user
            });
            accounts.push({
                "user": gets[0].user,
                "action": "get",
                "amount": getAmount,
                "partner": pays[0].user
            });

            payAmount -= getAmount;
            getAmount = 0.0;
        }

        // put new amounts back to list and sort to compare the highest value
        gets[0].amount = getAmount;
        pays[0].amount = payAmount;
        
        sortByKey(gets, "amount");
        sortByKey(pays, "amount");

        if (gets[0].amount == 0.0 && pays[0].amount == 0.0) {
            moneyLeftToPay = false;
        } else if (gets[0].amount < 0.01 || pays[0].amount < 0.01) {
            console.log("GETS: " + gets[0].amount);
            console.log("PAYS: " + pays[0].amount);
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
    console.log(first.firstname + " pays " + amount + "€ to " + second.firstname);
}
function sortByKey(array, key) {
    return array.sort(function(a, b) {
        var x = a[key]; var y = b[key];
        return ((x > y) ? -1 : ((x < y) ? 1 : 0));
    });
}

module.exports = router;