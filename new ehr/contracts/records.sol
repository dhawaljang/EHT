// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract records {
    
    // Define roles
    enum Role { Patient, HealthcareProvider }
    
    // Mapping of addresses to roles
    mapping(address => Role) public userRoles;

    // Modifier to restrict access to healthcare providers
    modifier onlyHealthcareProvider() {
        require(userRoles[msg.sender] == Role.HealthcareProvider, "Only healthcare providers can access this function");
        _;
    }

    struct Patient {
        string name;
        string[] treatments; // Array to store multiple treatments
        string[] treatmentDates; // Array to store dates of treatments
        uint age; // Age of the patient
    }

    uint public creditPool;

    address[] public patientList;
    mapping(address => Patient) public patients;

    // Events to log patient data access and modification
    event PatientAccessed(address indexed patientAddr, address indexed user, uint timestamp);
    event PatientModified(address indexed patientAddr, address indexed user, uint timestamp);

    // Events to log gas usage
    event GasUsed(string operation, uint gasUsed, uint timestamp);
    event StorageUsed(uint storageSize, uint timestamp);

    // Function to add a new patient (now payable)
    function addPatient(string memory _name, uint _age) public payable {
        uint initialGas = gasleft();
        require(msg.value > 0, "Ether payment is required to add a new patient");
        address newPatientAddr = msg.sender; // Assign the sender's address as the patient's address
        patients[newPatientAddr] = Patient({
            name: _name,
            treatments: new string[](0) , // Initialize empty treatments array
            treatmentDates: new string[](0) , // Initialize empty treatmentDates array
            age: _age
        });
        patientList.push(newPatientAddr); // Add the patient's address to the patientList
        uint gasUsed = initialGas - gasleft();
        emit GasUsed("addPatient", gasUsed, block.timestamp);
    }

    // Function to edit a patient's treatment details
    function addNewTreatment(string memory _patientName, string memory _newTreatment, string memory _newTreatmentDate) public onlyHealthcareProvider {
    uint initialGas = gasleft();
    address patientAddr = getPatientAddressByName(_patientName); // Get patient address by name
    patients[patientAddr].treatments.push(_newTreatment); // Add new treatment to the treatments array
    patients[patientAddr].treatmentDates.push(_newTreatmentDate); // Add date of new treatment to treatmentDates array
    emit PatientModified(patientAddr, msg.sender, block.timestamp);
    uint gasUsed = initialGas - gasleft();
    emit GasUsed("addNewTreatment", gasUsed, block.timestamp);
    }

    // Function to get patient details by name
    function getPatient(string memory _name) public payable returns (string memory, string[] memory, string[] memory, uint) {
        uint initialGas = gasleft();
        address patientAddr = getPatientAddressByName(_name); // Get patient address by name
        emit PatientAccessed(patientAddr, msg.sender, block.timestamp);
        Patient memory p = patients[patientAddr];
        uint gasUsed = initialGas - gasleft();
        emit GasUsed("getPatient", gasUsed, block.timestamp);
        return (p.name, p.treatments, p.treatmentDates, p.age);
    }

    // Function to get the number of patients
    function getNumberOfPatients() public view returns (uint) {
        return patientList.length;
    }

    // Function to get patient address by name
    function getPatientAddressByName(string memory _name) public view returns (address) {
        for (uint i = 0; i < patientList.length; i++) {
            address patientAddr = patientList[i];
            if (keccak256(bytes(patients[patientAddr].name)) == keccak256(bytes(_name))) {
                return patientAddr;
            }
        }
        revert("Patient not found");
    }

    // Function to assign role to an address (for contract owner only)
    function assignRole(address _user, Role _role) public {
        // Implement access control to restrict this function only to contract owner
        userRoles[_user] = _role;
    }

    // Function to get storage size of patient list
    function getStorageSize() public {
        uint size = patientList.length * 32 + // Each address takes up 32 bytes
                    patientList.length * 2 * 32 * 32; // Each patient has a struct with 2 string arrays, each string taking up 32 bytes
        emit StorageUsed(size, block.timestamp);
    }
}
