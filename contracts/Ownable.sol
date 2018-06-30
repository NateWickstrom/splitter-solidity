
pragma solidity ^0.4.24;

/**
 * @title Ownable
 *
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    event LogOnNewOwner(address newOwner);

    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner returns(bool success) {
        require(newOwner != address(0));
        owner = newOwner;
        emit LogOnNewOwner(owner);
        return true;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
