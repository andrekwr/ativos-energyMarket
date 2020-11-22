pragma solidity ^0.4.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyMarket is Ownable {

    struct Consumer {
        uint32 id_;
        bool producer;
    }

    //Variable associated to generation of an unique ID.
    uint32 counter = 0;

    //Generates unique ID consumer.
    function getID() returns(uint32) { return ++counter; } 

    //Map each consumer to its address.
    mapping(address => Consumer) private consumers;


    //TODO: checar se herança onlyOwner faz sentido.
    //Register new energy consumer.
    function registerConsumer(address consumer) onlyOwner {
        newid = getID()
        consumers[consumer].id_ = newid; 
    }

    //Register new energy producer.
    function registerProducer(address consumer) onlyOwner {
        consumers[consumer].producer = true; 
    }


}