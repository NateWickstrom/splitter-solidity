// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import splitter_artifacts from '../../build/contracts/Splitter.json'

// Splitter is our usable abstraction, which we'll use through the code below.
var Splitter = contract(splitter_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;

window.App = {
  start: function() {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    Splitter.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

      self.refreshBalance();
    });
  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },

  refreshBalance: function() {
    var self = this;

    var meta;
    Splitter.deployed().then(function(instance) {
      meta = instance;
      return web3.fromWei(web3.eth.getBalance(account));
    }).then(function(value) {
      var balance_element = document.getElementById("balance");
      balance_element.innerHTML = value.valueOf();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting balance; see log.");
    });
  },

  getBalance: function() {
    var self = this;

    var splitAccount = document.getElementById("splitAccount").value;

    var meta;
    Splitter.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(splitAccount);
    }).then(function(value) {
      self.setStatus("Got balance: " + value.toNumber());
      var splitter_element = document.getElementById("splitBalance");
      splitter_element.innerHTML = value.valueOf();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting splitter contract balance; see log.");
    });
  },

  deposit: function() {
    var self = this;

    var amount = parseInt(document.getElementById("amount").value);
    var receiver1 = document.getElementById("receiver1").value;
    var receiver2 = document.getElementById("receiver2").value;

    this.setStatus("Initiating transaction... (please wait)");

    var meta;
    Splitter.deployed().then(function(instance) {
      meta = instance;
      return meta.deposit(receiver1, receiver2,
        {from: account, value: amount, gas: 10000000,  gasPrice: 1});
    }).then(function() {
      self.setStatus("Transaction complete!");
      self.refreshBalance();
      self.getBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending coin; see log.");
    });
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:7545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));
  }

  App.start();
});
