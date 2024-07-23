var Records = artifacts.require("./records.sol");

module.exports = function(deployer) {
  deployer.deploy(Records);
};