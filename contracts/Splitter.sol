pragma solidity ^0.4.24;

import "./OwnedPausable.sol";

/**
 * @title Splitter
 *
 * @dev The Splitter contract has the ability to split a transaction, sending
 * half to a primary and half to a secondary recipient. Only the owner of this
 * contract can preform split sends and has this ability to disable contract 
 * functionality.  See the Oaned and Pausable contracts for more details.
 */
contract Splitter is OwnedPausable {

  address public primaryRecipient;
  address public secondaryRecipient;

  event LogTransfer(address sender, address to, uint amount);
  event LogError(address sender, address to, uint amount);
  event LogSetPrimaryRecipient(address recipient);
  event LogSetSecondaryRecipient(address recipient);

  modifier addressed {
      require(owner != address(0), "Owner address must not be 0x0");
      require(primaryRecipient != address(0), "Primary receiver address must not be 0x0");
      require(secondaryRecipient != address(0), "Secondary receiver address must not be 0x0");
      _;
  }

  /**
  * @dev Splits a transfer send half to the primaryRecipient and half to the
  * secondaryRecipient.  If the wei amount is odd, the primaryRecipient gets
  * the extra 1 wei.  Additionally, only the owner can call this method, the
  * contract must not be paused and all addresses must be valid.
  */
  function splitSend() public payable addressed resumed {
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

  function setPrimaryRecipient(address recipient) public onlyOwner resumed {
      primaryRecipient = recipient;
      emit LogSetPrimaryRecipient(primaryRecipient);
  }

  function setSecondaryRecipient(address recipient) public onlyOwner resumed {
      secondaryRecipient = recipient;
      emit LogSetSecondaryRecipient(secondaryRecipient);
  }

}
