var Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function(accounts) {

  it("deposit should split amount equally between two accounts", function() {
    var meta;

    var account_one = accounts[0];
    var account_two = accounts[1];
    var account_three = accounts[2];

    var account_one_starting_balance;
    var account_two_starting_balance;
    var account_one_ending_balance;
    var account_two_ending_balance;

    var amount = 10;

    return Splitter.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(account_one);
    }).then(function(outCoinBalance) {
      account_one_starting_balance = outCoinBalance.toNumber();
      return meta.getBalance.call(account_two);
    }).then(function(outCoinBalance) {
      account_two_starting_balance = outCoinBalance.toNumber();
      return meta.deposit(account_one, account_two,
                { from:account_three, value: amount, gas: 10000000,  gasPrice: 1 });
    }).then(function() {
      return meta.getBalance.call(account_one);
    }).then(function(outCoinBalance) {
      account_one_ending_balance = outCoinBalance.toNumber();
      return meta.getBalance.call(account_two);
    }).then(function(outCoinBalance) {
      account_two_ending_balance = outCoinBalance.toNumber();
    }).then(function() {
      assert.equal(account_one_starting_balance + 5, account_one_ending_balance,
        "account one did not receiver half of the funds");
      assert.equal(account_two_starting_balance + 5, account_two_ending_balance,
        "account two did not receiver half of the funds");
    });
  });

  it("withdraw should set balance to zero", function() {
    var meta;

    var account_one = accounts[0];
    var account_two = accounts[1];
    var account_three = accounts[2];

    var account_one_starting_balance;
    var account_one_ending_balance;

    var amount = 10;

    return Splitter.deployed().then(function(instance) {
      meta = instance;
      return meta.deposit(account_one, account_two,
                { from:account_three, value: amount, gas: 10000000,  gasPrice: 1 });
    }).then(function() {
      return meta.getBalance.call(account_one);
    }).then(function(outCoinBalance) {
      account_one_starting_balance = outCoinBalance.toNumber();
      return meta.withdraw(
                { from:account_one, value: 0, gas: 10000000,  gasPrice: 1 });
    }).then(function() {
      return meta.getBalance.call(account_one);
    }).then(function(outCoinBalance) {
      account_one_ending_balance = outCoinBalance.toNumber();
    }).then(function() {
      assert(account_one_starting_balance > 0,
        "funds were not deposited into account");
      assert.equal(0, account_one_ending_balance,
        "account balance after withdraw was not 0");
    });
  });

});
