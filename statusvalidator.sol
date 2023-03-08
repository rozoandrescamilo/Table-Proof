// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract StatusValidator {

    // Define una estructura de datos llamada Step para almacenar información sobre un paso en el flujo de proceso
    struct Step {
        Status status; // El estado actual del paso
        string metadata; // Metadatos adicionales sobre el paso
    }

    // Un enumerable llamado Status que define los diferentes estados posibles de un paso en el flujo de proceso
    enum Status {
        TO_BE_CONFIRMED, 
        APPROVED, 
        BOOKING_REQUEST 
    }
    
    enum PurchaseOrderTypeB {
        TO_BE_CONFIRMED, 
        APPROVED_P1, 
        TO_BE_CONFIRMED_P2, 
        APPROVED_P2, 
        APPROVED, 
        BOOKING_REQUEST 
    }

    enum PurchaseOrderTypeC {
        TO_BE_CONFIRMED, 
        APPROVED_P1, 
        TO_BE_CONFIRMED_P2, 
        APPROVED_P2, 
        TO_BE_CONFIRMED_P3, 
        APPROVED_P3, 
        APPROVED, 
        BOOKING_REQUEST 
    }  

    // Un evento llamado RegisteredStep que se activa cuando una PO se registra en el flujo 
    event RegisteredStep(
        uint256 POID, // ID del producto
        uint256 poType,
        Status status, // Estado del paso
        string metadata, // Metadatos adicionales
        address author // Dirección del autor
    );

    // El mapping guarda el ID de la PO y un array asociado con cada Step de la misma.
    mapping(uint256 => Step[]) public POvalidator;

    // Una función para registrar una PO que contendrá steps.
    function registerPO(uint256 POID, uint256 poType) public returns (bool success) {
        // Comprueba que la PO no haya sido registrado previamente.
        require(POvalidator[POID].length == 0, "This product already exists");
        require(poType == 1 || poType == 2 || poType == 3, "Invalid PO type");
        // Agrega un paso inicial al producto con el estado "TO_BE_CONFIRMED".
        POvalidator[POID].push(Step(Status.TO_BE_CONFIRMED, ""));        
        return success;
    }

    // Una función para registrar un nuevo paso en el flujodel proceso.
    function registerStep(uint256 POID, string calldata metadata, uint256 poType) public returns (bool success){
        // Comprueba que la PO haya sido registrado previamente.
        require(POvalidator[POID].length > 0, "This Purchase Order doesn't exist");
        // Obtiene la matriz de pasos actual para el producto.
        Step[] memory stepsArray = POvalidator[POID];
        // Calcula el estado siguiente para el paso actual.
        uint256 currentStatus = uint256(stepsArray[stepsArray.length - 1].status) + 1;
        // Dado el caso de que el status sea mayor a COMPLETED envía error
        if (currentStatus > uint256(Status.BOOKING_REQUEST)) {
            revert("The Purchase Order has no more steps");
        }
        // Se asigna el estado actual + 1 y se añade al mapping de PO
        Step memory step = Step(Status(currentStatus), metadata);
        POvalidator[POID].push(step);
        // Se lanza evento donde se registra nuevo step a unu PO
        emit RegisteredStep(POID, poType, Status(currentStatus), metadata, msg.sender);
        success = true;
    }

}
