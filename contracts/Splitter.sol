pragma solidity ^0.4.24;

import "./OwnedPausable.sol";

contract Splitter is OwnedPausable {

  address public primaryRecipient;
  address public secondaryRecipient;

  event LogTransfer(address sender, address to, uint amount);
  event LogError(address sender, address to, uint amount);
  event LogSetPrimaryRecipient(address recipient);
  event LogSetSecondaryRecipient(address recipient);

  modifier validAddresses {
      require(owner != address(0), "Owner address must not be 0x0");
      require(primaryRecipient != address(0), "Primary receiver address must not be 0x0");
      require(secondaryRecipient != address(0), "Secondary receiver address must not be 0x0");
      _;
  }

  function splitSend() public payable validAddresses requireIsResumed {
      require(msg.value > 0, "Insufficient funds");

      uint secondaryFunds = msg.value / 2;
      uint primaryFunds = msg.value - secondaryFunds;

      send(primaryRecipient, primaryFunds);
      send(secondaryRecipient, secondaryFunds);
  }

  function send(address to, uint amount) private {
      if (to.send(amount)) {
          emit LogTransfer(owner, to, amount);
      } else {
          emit LogError(owner, to, amount);
          revert("Failed to send funds");
      }
  }

  function setPrimaryRecipient(address recipient) public onlyOwner requireIsResumed {
      primaryRecipient = recipient;
      emit LogSetPrimaryRecipient(primaryRecipient);
  }

  function setSecondaryRecipient(address recipient) public onlyOwner requireIsResumed {
      secondaryRecipient = recipient;
      emit LogSetSecondaryRecipient(secondaryRecipient);
  }

}
