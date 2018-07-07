pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Pausable.sol';

/**
 * @title Splitter
 *
 * @dev The Splitter contract has the ability to split transactions, sending
 * half to a primary and half to a secondary recipient. Incase of an odd value,
 * the primary recipient gets an extra 1 wei.
 */
contract Splitter is Pausable {

    using SafeMath for uint256;

    mapping(address => uint) public balances;

    event LogDeposit(address indexed from, address indexed primary, address indexed secondary, uint funds);
    event LogWithdraw(address indexed to, uint funds);

    /**
    * @dev  The sent funds will be split 50/50 between recipients and availible
    * for withdraw via the receive bellow. Incase of an odd value, the primary
    * recipient gets an extra 1 wei.
    *
    * @param primary recipient to transfer funds to.
    * @param secondary recipient to transfer funds to.
    */
    function deposit(address primary, address secondary) whenNotPaused public payable {
        require(msg.value > 0, "Insufficient funds");
        require(primary != address(0), "Primary recipient address must not be 0x0");
        require(secondary != address(0), "Secondary recipient address must not be 0x0");
        require(isEven(msg.value), "Cannot split odd values fairly");

        uint half = msg.value.div(2);
        balances[secondary] = balances[secondary].add(half);
        balances[primary] = balances[primary].add(half);

        emit LogDeposit(msg.sender, primary, secondary, msg.value);
    }

    /**
     * @dev Recipients may withdraw their funds using this funtion.
     */
    function withdraw() whenNotPaused public {
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

    function isEven(uint number) private pure returns(bool) {
        return (number % 2 == 0);
    }

    /** Fallback not needed */
    function() public {
        revert();
    }

}
