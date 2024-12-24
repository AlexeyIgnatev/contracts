import {buildModule} from "@nomicfoundation/hardhat-ignition/modules";


const EsomModule = buildModule("EsomModule", (m) => {
    const eSom = m.contract("ESom");
    return {eSom};
});

export default EsomModule;
