const Record = artifacts.require("Record");

contract("Record", (accounts) => {
    let recordInstance;
    const [owner, patient, healthcareProvider, anotherHealthcareProvider] = accounts;

    before(async () => {
        recordInstance = await Record.deployed();
    });

    describe("Deployment", () => {
        it("should deploy the contract correctly", async () => {
            assert(recordInstance.address !== '');
        });
    });

    describe("Role Assignment", () => {
        it("should assign healthcare provider role", async () => {
            await recordInstance.assignRole(healthcareProvider, 1, { from: owner });
            const role = await recordInstance.userRoles(healthcareProvider);
            assert.equal(role.toString(), '1', "Role should be HealthcareProvider");
        });

        it("should assign patient role", async () => {
            await recordInstance.assignRole(patient, 0, { from: owner });
            const role = await recordInstance.userRoles(patient);
            assert.equal(role.toString(), '0', "Role should be Patient");
        });
    });

    describe("Adding Patients", () => {
        it("should add a new patient", async () => {
            const name = "John Doe";
            const number = 1234567890;
            const age = 30;
            const value = web3.utils.toWei("1", "ether");

            await recordInstance.addPatient(name, number, age, { from: patient, value });

            const patientDetails = await recordInstance.getPatient(patient, { from: patient, value });
            assert.equal(patientDetails[0], name, "Patient name should match");
            assert.equal(patientDetails[1].toNumber(), number, "Patient number should match");
            assert.equal(patientDetails[4].toNumber(), age, "Patient age should match");
        });

        it("should get the number of patients", async () => {
            const numberOfPatients = await recordInstance.getNumberOfPatients();
            assert.equal(numberOfPatients.toNumber(), 1, "Number of patients should be 1");
        });
    });

    describe("Adding Treatments", () => {
        it("should add a new treatment by healthcare provider", async () => {
            const treatment = "Flu Shot";
            const treatmentDate = "2024-05-01";
            const value = web3.utils.toWei("1", "ether");

            await recordInstance.addNewTreatment(patient, treatment, treatmentDate, { from: healthcareProvider, value });

            const patientDetails = await recordInstance.getPatient(patient, { from: healthcareProvider, value });
            assert.equal(patientDetails[2][0], treatment, "Treatment should match");
            assert.equal(patientDetails[3][0], treatmentDate, "Treatment date should match");
        });

        it("should emit event on patient modification", async () => {
            const treatment = "Covid Vaccine";
            const treatmentDate = "2024-05-10";
            const value = web3.utils.toWei("1", "ether");

            const receipt = await recordInstance.addNewTreatment(patient, treatment, treatmentDate, { from: healthcareProvider, value });

            assert.equal(receipt.logs.length, 1, "Should trigger one event");
            assert.equal(receipt.logs[0].event, "PatientModified", "Event should be PatientModified");
        });
    });
});
