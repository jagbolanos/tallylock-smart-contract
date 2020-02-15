const TallyLock = artifacts.require("TallyLock");

module.exports = function(deployer) {
  deployer.deploy(TallyLock);
};
