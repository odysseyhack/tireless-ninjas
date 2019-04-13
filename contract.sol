pragma solidity >=0.4.22 <0.6.0;

contract CertificationContract {
    
    struct Application {
        uint8 eanCode;
        uint8 yearlyProduction; //MWh
        uint8 peakProduction; //MW peak
        bool certified;
    }
    
    address applicant;
    mapping(address => Application) applications;
    
    constructor() public {
        applicant = msg.sender;
        applications[applicant].certified = false;
        applications[applicant].yearlyProduction = 0;
    }
    
    event certified(uint production);
    
    function cerify(uint8 yearlyProduction) public {
        
        if (msg.sender != applicant || applications[applicant].certified || yearlyProduction <= 1) return;
        applications[applicant].certified = true;
        applications[applicant].yearlyProduction = yearlyProduction;
        emit certified(yearlyProduction);
    }
}