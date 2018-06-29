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
    modifier requireIsPaused {
        require(!isPaused, "Action requires resumed state");
        _;
    }

    /**
    * @dev Throws if contract is paused.
    */
    modifier requireIsResumed {
        require(isPaused, "Action requires paused state");
        _;
    }

    constructor() public {
        isPaused = false;
    }

    /**
    * @dev Allows the contract to be paused.
    */
    function pause() public requireIsResumed returns(bool success)  {
        isPaused = true;
        emit LogOnPaused(msg.sender, isPaused);
        return true;
    }

    /**
    * @dev Allows the contract to be resumed.
    */
    function resume() public requireIsPaused returns(bool success)  {
        isPaused = false;
        emit LogOnResumed(msg.sender, isPaused);
        return true;
    }

    function paused() public view returns (bool) {
        return isPaused;
    }

}
