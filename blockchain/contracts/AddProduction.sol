pragma solidity >=0.4.22 <0.6.0;

contract AddProduction {
    
 uint256 storedProduction;   
 
 function set(uint256 production) public {
    storedProduction = production;
 }
 
 function get() public view returns(uint256) {
     return storedProduction;
 }

}