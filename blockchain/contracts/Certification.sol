pragma solidity >=0.4.22 <0.6.0;

contract CertificationContract {
    
    struct Application {
        uint8 eanCode;
        uint8 productionAmount; //MWh
        uint8 peakProduction; //MW peak
        bool certified;
    }
    
    address applicant;
    mapping(address => Application) applications;
    
    constructor() public {
        applicant = msg.sender;
        applications[applicant].certified = false;
        applications[applicant].productionAmount = 0;
    }
    
    event certified(uint production);
    
    function cerify(uint8 productionInput) public {
        applications[applicant].productionAmount += productionInput;
        if (msg.sender != applicant || applications[applicant].certified || applications[applicant].productionAmount <= 1000) return;
        applications[applicant].certified = true;
        emit certified(applications[applicant].productionAmount);
    }
}