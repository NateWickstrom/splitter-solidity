pragma solidity ^0.4.24;

import "./Ownable.sol";

/**
 * @title Splitter
 *
 * @dev The Splitter contract has the ability to split a transaction, sending
 * half to a primary and half to a secondary recipient. Only the owner of this
 * contract can preform split send. See the Owned contract for more details.
 */
contract Splitter is Ownable {

    address primaryRecipient;
    address secondaryRecipient;

    uint primaryFunds;
    uint secondaryFunds;

    event LogFundsReceived(address from, uint primaryFunds, uint secondaryFunds, uint totalFunds);
    event LogTransfer(address to, uint funds);
    event LogError(address to, uint amount);

    modifier onlyRecipient {
        require(msg.sender == primaryRecipient || msg.sender == secondaryRecipient,
                    "Only the owner can do this");
        _;
    }

    constructor(address primary, address secondary) public {
        require(primary != address(0), "Primary recipient address must not be 0x0");
        require(secondary != address(0), "Secondary recipient address must not be 0x0");

        primaryRecipient = primary;
        secondaryRecipient = secondary;
    }

    /**
    * @dev Only the owner can call this method to add fund to the contract.
    * The funds will be split 50/50 between recipients and availible for withdraw
    * via the receive bellow.
    */
    function send() public payable onlyOwner {
        require(msg.value > 0, "Insufficient funds");

        secondaryFunds = msg.value / 2;
        primaryFunds = msg.value - secondaryFunds;

        emit LogFundsReceived(msg.sender, primaryFunds, secondaryFunds, msg.value);
    }

    /**
     * @dev When funds have been added by owner, either recipients may withdraw
     * their lot using this funtion.
     *
     * @param to The address to transfer funds to.
     */
    function receive(address to) public onlyRecipient {
        if (primaryRecipient == to && primaryFunds > 0) {
            send(to, primaryFunds);
        } else if (secondaryRecipient == to && secondaryFunds > 0) {
            send(to, secondaryFunds);
        }
    }

    function send(address to, uint amount) private {
      if (to.send(amount)) {
          emit LogTransfer(to, amount);
      } else {
          emit LogError(to, amount);
          revert("Failed to send funds");
      }
    }

    function getPrimary() public view returns (address) {
        return primaryRecipient;
    }

    function getSecondary() public view returns (address) {
        return secondaryRecipient;
    }
}
