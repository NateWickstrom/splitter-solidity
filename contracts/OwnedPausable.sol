pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./Pausable.sol";

/**
 * @title OwnedPlausible
 *
 * @dev The OwnedPlausible contract combines features of both the Ownable and Plausible
 */
contract OwnedPausable is Ownable, Pausable {

    /**
    * @dev Allows the contract to be paused only by the owner.
    */
    function pause() public onlyOwner returns(bool success)  {
       return super.pause();
    }

    /**
    * @dev Allows the contract to be resumed only by the owner.
    */
    function resume() public onlyOwner returns(bool success)  {
        return super.resume();
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner,
    * but only when the contract is resumed.
    *
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public requireIsResumed returns(bool success) {
        return super.transferOwnership(newOwner);
    }

}
