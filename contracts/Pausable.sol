pragma solidity ^0.4.24;

/**
 * @title Pausable
 *
 * @dev The Pausable contract has the ability to pause and resume operation by
 * deniend transations when paused.
 */
contract Pausable {

    bool isPaused;

    event LogOnPaused(address sender, bool isPaused);
    event LogOnResumed(address sender, bool isPaused);

    /**
    * @dev Throws if contract is not paused.
    */
    modifier paused {
        require(!isPaused, "Action requires resumed state"); _;
    }

    /**
    * @dev Throws if contract is paused.
    */
    modifier resumed {
        require(isPaused, "Action requires paused state"); _;
    }

    constructor() public {
        isPaused = false;
    }

    /**
    * @dev Allows the contract to be paused.
    */
    function pause() public resumed {
        isPaused = true;
        emit LogOnPaused(msg.sender, isPaused);
    }

    /**
    * @dev Allows the contract to be resumed.
    */
    function resume() public paused {
        isPaused = false;
        emit LogOnResumed(msg.sender, isPaused);
    }

    /**
    * @dev Returns the current state of the constract
    */
    function paused() public view returns (bool) {
        return isPaused;
    }

}
