pragma solidity ^0.6.0;

//Truffle import
//import "@openzeppelin/contracts/access/Ownable.sol";

//Remix import
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract EnergyMarket is Ownable{

    // Consumer Structure.
    struct Consumer {
        uint32 id_;
        bool producer;
        uint64 energyProduced;
        uint64 energyConsumed;
        uint64 energyBidded;
             // Energy remnant
        uint64 energyLeftover;
        
    }

    // Energy Constants - Minimum transacted is 1kWh
    uint64 constant kWh = 1;
    uint64 constant MWh = 1000 * kWh;
    uint64 constant GWh = 1000 * MWh;
    uint64 constant TWh = 1000 * GWh;
    uint64 constant maxEnergy = 18446 * GWh;

    // Bid Structure.
    struct Bid {
        // Bid owner`s id
        address payable owner;
        // day for which the offer is valid
        uint32 day;
        // Price for each kWh
        uint32 kWhPrice;
        // Amount of energy being sold
        uint64 amount;
        // Timestamp for when the offer was submitted
        uint64 timestamp;
        // Bid Id
        uint bidId;
        // Bid Status
        bool status;
    }

    Bid[] public bids;

    //Events logs registered in blockchain.
    event RegisterConsumer(address indexed consumer);
    event RegisterProducer(address indexed producer);

    event CreatedBid(address indexed producer, uint32 indexed day, uint32 indexed price, uint64 amount);

    event DealMade(address indexed producer, address indexed consumer, uint32 indexed day, uint32 price, uint64 amount);



    //Map each consumer to its address.
    mapping(address => Consumer) private consumers;

    //Map each consumer to its bidIds array
    mapping(address => uint[]) private bidsIndex;
    
    
    
    //Variable associated to generation of an unique ID.
    uint32 counter = 0;

    //Generates unique ID consumer.
    function getID() internal returns(uint32) { return ++counter; } 


    //Register new energy consumer.
    function registerConsumer(address consumer) public onlyOwner {
        uint32 newid = getID();
        consumers[consumer].id_ = newid; 
        emit RegisterConsumer(consumer);

    }

    modifier onlyConsumers {
        require(consumers[msg.sender].id_ > 0);
        _;
    }

    //Register new energy producer.
    function registerProducer(address consumer) public onlyOwner {
        consumers[consumer].producer = true; 
        emit RegisterProducer(consumer);

    }

    modifier onlyProducers {
        require(consumers[msg.sender].producer);
        _;
    }

    //Register energy production.
    function registerProduction(uint64 amount) onlyProducers public {
        require(amount >= kWh);
        consumers[msg.sender].energyProduced += amount;
    }

    //Register energy consumption.
    function registerConsumption(uint64 amount) onlyConsumers public {
        require(amount >= kWh);

        if (consumers[msg.sender].energyLeftover >= amount) {
            consumers[msg.sender].energyLeftover -= amount;
        } else {
            amount -= consumers[msg.sender].energyLeftover;
            consumers[msg.sender].energyConsumed += amount;

        }
        
    }

    //Check own balance
    function energyBalance() public view returns (uint64) {
        return (consumers[msg.sender].energyProduced + consumers[msg.sender].energyLeftover - consumers[msg.sender].energyConsumed);
    }

    //Create an offer.
    function bid(uint32 bidDay, uint32 bidPrice, uint64 bidAmount, uint64 bidTimestamp) onlyProducers public {
        uint64 balance = energyBalance();
        require(balance >= consumers[msg.sender].energyBidded + bidAmount);
        require(bidAmount >= kWh);
        
        consumers[msg.sender].energyBidded += bidAmount;

        Bid memory bid = Bid({
            owner: msg.sender,
            day: bidDay,
            kWhPrice: bidPrice,
            amount: bidAmount,
            timestamp: bidTimestamp,
            bidId: bids.length,
            status: true
        });
        

        bids.push(bid);
        bidsIndex[msg.sender].push(bid.bidId);

        emit CreatedBid(msg.sender, bidDay, bidPrice, bidAmount);
    }

    //Accept offer.
    function acceptBid(uint bidId) onlyConsumers public payable {
        Bid memory bid = bids[bidId];
        require(msg.value >= bid.kWhPrice*bid.amount);
        uint amountPaid = msg.value;
        
        //Remnant energy if consumed less than the amount bought.
        uint64 leftover = consumers[msg.sender].energyConsumed - bid.amount;
        if (leftover < 0) {
            consumers[msg.sender].energyLeftover = - leftover;
            consumers[msg.sender].energyConsumed = 0;
        } else {
            consumers[msg.sender].energyConsumed -= bid.amount;
        }

        bid.status = false;
        consumers[bid.owner].energyBidded -= bid.amount;

        bid.owner.transfer(amountPaid);
        emit DealMade(bid.owner, msg.sender, bid.day, bid.kWhPrice, bid.amount);
        
    }

    //List bid ids of specific producer.
    function listBids(address producer) public view returns (uint[] memory) {
        return (bidsIndex[producer]);
    }

    //List information of specific bid.
    function getBid(uint index) public view returns (uint32, uint64, uint32, uint64, uint){
        return (bids[index].kWhPrice, bids[index].amount, bids[index].day, bids[index].timestamp, bids[index].bidId);
    }


}