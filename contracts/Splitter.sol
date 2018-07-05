pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title Splitter
 *
 * @dev The Splitter contract has the ability to split transactions, sending
 * half to a primary and half to a secondary recipient. Incase of an odd value,
 * the primary recipient gets an extra 1 wei.
 */
contract Splitter {

    using SafeMath for uint256;

    mapping(address => uint) public balances;

    event LogDeposit(address indexed from, address indexed to, uint funds);
    event LogWithdraw(address indexed to, uint funds);

    /**
    * @dev  The sent funds will be split 50/50 between recipients and availible
    * for withdraw via the receive bellow. Incase of an odd value, the primary
    * recipient gets an extra 1 wei.
    *
    * @param primary recipient to transfer funds to.
    * @param secondary recipient to transfer funds to.
    */
    function deposit(address primary, address secondary) public payable {
        require(msg.value > 0, "Insufficient funds");
        require(primary != address(0), "Primary recipient address must not be 0x0");
        require(secondary != address(0), "Secondary recipient address must not be 0x0");

        uint secondaryFunds = msg.value.div(2);
        uint primaryFunds = msg.value.sub(secondaryFunds);

        balances[primary] = balances[primary].add(primaryFunds);
        balances[secondary] = balances[secondary].add(secondaryFunds);

        emit LogDeposit(msg.sender, primary, primaryFunds);
        emit LogDeposit(msg.sender, secondary, secondaryFunds);
    }

    /**
     * @dev Recipients may withdraw their funds using this funtion.
     */
    function withdraw() public {
        address payee = msg.sender;
        uint balance = balances[payee];

        require(balance > 0, "Insufficient funds");

        balances[payee] = 0;
        emit LogWithdraw(payee, balance);

        require(payee.send(balance), "Failed to transfer funds");
    }

    function getBalance(address addr) public view returns(uint) {
        return balances[addr];
    }

    /** Fallback not needed */
    function() public {
        revert();
    }

}
