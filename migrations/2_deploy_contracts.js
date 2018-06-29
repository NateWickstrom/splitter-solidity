var Ownable = artifacts.require("./Ownable.sol");
var Pausable = artifacts.require("./Pausable.sol");
var OwnedPausable = artifacts.require("./OwnedPausable.sol");
var Splitter = artifacts.require("./Splitter.sol");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.deploy(Pausable);
  deployer.deploy(OwnedPausable);
  deployer.deploy(Splitter);
};
