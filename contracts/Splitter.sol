pragma solidity ^0.4.24;

/**
 * @title Splitter
 *
 * @dev The Splitter contract has the ability to split transactions, sending
 * half to a primary and half to a secondary recipient. Incase of an odd value,
 * the primary recipient gets an extra 1 wei.
 */
contract Splitter {

    mapping(address => uint) public balances;

    event LogTransferIn(address from, address to, uint funds);
    event LogTransferOut(address to, uint funds);

    /**
    * @dev  The send funds will be split 50/50 between recipients and availible
    * for withdraw via the receive bellow. Incase of an odd value, the primary
    * recipient gets an extra 1 wei.
    *
    * @param primary recipient to transfer funds to.
    * @param secondary recipient to transfer funds to.
    */
    function send(address primary, address secondary) public payable {
        require(msg.value > 0, "Insufficient funds");
        require(primary != address(0), "Primary recipient address must not be 0x0");
        require(secondary != address(0), "Secondary recipient address must not be 0x0");

        uint secondaryFunds = msg.value / 2;
        uint primaryFunds = msg.value - secondaryFunds;

        balances[primary] += primaryFunds;
        balances[secondary] += secondaryFunds;

        emit LogTransferIn(msg.sender, primary, primaryFunds);
        emit LogTransferIn(msg.sender, secondary, secondaryFunds);
    }

    /**
     * @dev Recipients may withdraw their funds using this funtion.
     *
     * @param to whom to transfer funds to.
     */
    function receive(address to) public {
        require(msg.sender == to , "Only the owner can do this");
        require(balances[to] > 0, "Insufficient funds");

        uint funds = balances[to];
        balances[to] = 0;
        if (to.send(funds)) {
            emit LogTransferOut(to, funds);
        } else {
            revert("Failed to transfer funds");
        }
    }

    /** Fallback not needed */
    function() public {
        revert();
    }

}
