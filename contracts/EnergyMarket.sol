pragma solidity ^0.4.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyMarket is Ownable{

    struct Consumer {
        uint32 id_;
        bool producer;
        uint64 energyProduced;
        uint64 energyConsumed;
        uint64 energyBidded;
    }

    // Energy Constants - Minimum transacted is 1kWh
    uint64 constant kWh = 1;
    uint64 constant MWh = 1000 * kWh;
    uint64 constant GWh = 1000 * MWh;
    uint64 constant TWh = 1000 * GWh;
    uint64 constant maxEnergy = 18446 * GWh;

    // Bid Structure
    struct Bid {
        // Bid owner`s id
        address owner;
        // day for which the offer is valid
        uint32 day;
        // Price for each kWh
        uint32 kWhPrice;
        // Amount of energy being sold
        uint64 amount;
        // Timestamp for when the offer was submitted
        uint64 timestamp;
        // Bid Id
        uint32 bidId;
        // Energy remnant
        uint64 Leftover;
    }

    Bid[] public bids;
    // map (address, day) to index into bids
    // mapping(address => mapping(uint32 => uint)) public bidsByDay;

    // Ask Structure
    struct Ask {
        // Ask owner`s id
        address owner;
        // day for which the offer is valid
        uint32 day;
        // Price for each kWh
        uint32 kWhPrice;
        // Amount of energy being bought
        uint64 amount;
        // Timestamp for when the offer was submitted
        uint64 timestamp;
    }

    Ask[] public asks;

    event RegisterConsumer(address indexed producer);
    event RegisterProducer(address indexed consumer);

    event CreatedBid(address indexed producer, uint32 indexed day, uint32 indexed price, uint64 amount);
    event CreatedAsk(address indexed consumer, uint32 indexed day, uint32 indexed price, uint64 amount);

    
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
        emit RegisterConsuemr(consumer);

    }

    //Importar de dentro da função?
    modifier onlyConsumers {
            require(consumers[msg.sender]);
            _;
    }

    //Register new energy producer.
    function registerProducer(address consumer) onlyOwner {

        consumers[consumer].producer = true; 
        emit RegisterProducer(consumer);

    }

    //Importar de dentro da função?
    modifier onlyProducers {
        require(consumers[msg.sender].producer);
        _;
    }

    function registerProduction(uint64 amount) onlyProducers external {
        require(amount >= kWh);
        consumers[msg.sender].energyProduced += amount;
    }

    function registerConsumption(uint64 amount) onlyConsumers external {
        require(amount >= kWh);
        consumers[msg.sender].energyConsumed += amount;
    }

    function energyBalance() public view {
        return consumers[msg.sender].energyProduced - consumers[msg.sender].energyConsumed;
    }

    function bid(uint32 bidDay, uint32 bidPrice, uint64 bidAmount, uint64 bidTimestamp) onlyProducers external public {
        uint64 balance = energyBalance();
        require(balance >= consumers[msg.sender].energyBided + amount);
        require(askAmount >= kWh);
        
        consumers[msg.sender].energyBided += amount;

        Bid bid = Bid({
            owner: msg.sender,
            day: bidDay,
            kWhPrice: bidPrice,
            amount: bidAmount,
            timestamp: bidTimestamp,
            bidId: bids.length 
        })

        bids.push(bid);

        emit CreatedBid(msg.sender, bidDay, bidPrice, bidAmount);
    }

    function ask(uint32 askDay, uint32 askPrice, uint64 askAmount, uint64 askTimestamp) onlyConsumers external public {
        require(askAmount >= kWh);

        Ask ask = ask({
            owner: msg.sender,
            day: askDay,
            kWhPrice: askPrice,
            amount: askAmount,
            timestamp: askTimestamp 
        })
        asks.push(ask);

        emit CreatedAsk(msg.sender, askDay, askPrice, askAmount);
    }


    function listBids() view returns(bids) {
        return bids;
    }

    //Deixar apenas acceptbid e criar a ask no momento da venda.
    function acceptBid(uint32 bidId) onlyConsumers public {
        bid = bids[bidId];

        // Retira do consumido a quantidade que o consumer comprou. Se o consumo ficar
        // abaixo de zero, vira sobra de energia.
        uint64 leftover = consumers[msg.sender].energyConsumed - bid.amount;
        if (leftover < 0) {
            consumers[msg.sender].energyLeftover = - leftover;
            consumers[msg.sender].energyConsumed = 0;
        } else {
            consumers[msg.sender].energyConsumed -= bid.amount;
        }

        consumers[msg.sender].energyConsumed -= bid.amount;
        delete bids[bidId]

        // Delete do meio
        // Pega o ultimo, coloca nesse lugar
        // Atualiza o id do ultimo
        
        
    }
    
    function acceptAsk() {
        
    }

    function transact()

    function moneyBalance()

}