// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney {

    //-----------------------STATEMENTS-----------------------------

    //Instance for calling functions from another contract
    ERC20Basic private token;
    //Set the owner
    address payable public owner;
    //Constructor
    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    } 
    //Save our custumer's data
    struct customer{
        uint purchased_tokens;
        string [] attractions_enjoyed;
    }
    //Mapping to save customer's data
    mapping (address => customer) public Customers;

    //----------------------TOKENS--------------------

    //Function to set the token's prices
    function PriceTokens (uint _numTokens) internal pure returns (uint)  {
        //We determinate that 1 token it's 0.5 ether
        return _numTokens* (0.5 ether);
    }
    //Function to buy Tokens in Disney and enjoy the attractions
    function BuyTokens (uint Buy_x_tokens) public payable{
        //We determinate the cost of customer's number of tokens wants to buy
        uint cost = PriceTokens(Buy_x_tokens);
        //We have to assure customer have enough money
        require (msg.value >= cost, "You don't have enough money");
        //Diference between what he pay and the real cost
        uint returnValue = msg.value - cost;
        //Disney return to customer
        msg.sender.transfer(returnValue);
        //Available tokens
        uint Balance = balanceOf();
        require (Buy_x_tokens <= Balance, "You have to buy less tokens amount");
        //When we check it, then we transfer tokens from disney contract to costumer address
        token.transfer(msg.sender,Buy_x_tokens );
        //Add tokens bought by the customer
        Customers[msg.sender].purchased_tokens += Buy_x_tokens;
    }

    //Balance Disneys token
    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }  
    
    //Visualize my Tokens
    function MyTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }
    //Function to increse number of tokens, only by Disney
    function increaseTotalSupply (uint _increasetoken) public Only_owner(msg.sender) {
        token.increaseTotalSuply(_increasetoken);
    } 

    //Modifier to control functions executed only by Disney
    modifier Only_owner(address _address) {
        require(_address == owner, "You don't have permissions to execute this function");
        _;
    }
    //------------------------DISNEY--------------------------------

    //Events
    event enjoy_attraction(string, uint, address);
    event new_attraction(string, uint);
    event remove_attraction(string);

    //Structure 
    struct attraction {
        string attraction_name;
        uint attraction_price;
        bool attraction_state;
    }
    //Mapping to relate attraction name's with attraction structure
    mapping (string => attraction) public mappingattraction;

    //Save attractions
    string [] attractions;

    //Mapping to relate customer to Disney history
    mapping (address => string []) atractionhistory;

    //Star Wars -> 2 Tokens
    //Toy Story -> 5 tokens
    //Lion King -> 8 tokens

    //Function to create new attractions (only by Disney)
    function Newattraction(string memory _attractionname, uint _attractionprice) public Only_owner(msg.sender) {
        //Create new attraction
        mappingattraction[_attractionname] = attraction(_attractionname,_attractionprice, true);
        //Save attractions
        attractions.push(_attractionname);
        //Emit new attraction event
        emit new_attraction(_attractionname, _attractionprice);
    }

    //Funtion to remove an attraction
    function Removeattraction (string memory _attractionname) public Only_owner(msg.sender) { 
        //Change attraction's state
        mappingattraction[_attractionname].attraction_state = false;
        emit remove_attraction (_attractionname);
        }

    //Visualize Disney attractions
    function visualize_attractions () public view returns (string[] memory) {
        return attractions;
    }

    //Function to enjoy attraction
    function Enjoyattraction (string memory attraction_name) public {
        //We need to know price attraction (in tokens)
        uint tokens_attraction = mappingattraction[attraction_name].attraction_price;
        //Verify attraction state (to validate if its abailable)
        require (mappingattraction[attraction_name].attraction_state == true, 
        "Attraction isn't abailable at this moment");
        //Verify custumer's number's tokens
        require (tokens_attraction <= MyTokens(), "You don't have enought tokens");
        //In our ERC20.sol we create an adicional function to transfer from customer to 
        //Disney address, not by SC address
        token.transfer_disney(msg.sender, address(this),tokens_attraction);
        //Save custumer's history
        atractionhistory[msg.sender].push(attraction_name);
        //Emit event to enjoy attraction
        emit enjoy_attraction (attraction_name,tokens_attraction, msg.sender );
    }

    //Visualize attractions ejoyed history by a customer
    function History() public view returns (string [] memory) {
        return atractionhistory[msg.sender];
    }

    //Customer can return tokens
    function tokenreturns (uint _numTokens) public payable {
        //Number of tokens to return is positive
        require (_numTokens > 0, "You need to return a positive number of token");
        //Number of tokens to return is equal or less than the custumer has
        require (_numTokens <= MyTokens(), "You don't have as many tokens as you require to return");
        //The customer returns the number of tokens
        token.transfer_disney(msg.sender, address(this),_numTokens );
        //Disney returns ethers
        msg.sender.transfer(PriceTokens(_numTokens));
    }

    //Disney wants to provide new food service
    //Events
    event eat(string, uint, address);
    event new_food(string, uint);
    event remove_food(string);

    //Structure 
    struct food {
        string food_name;
        uint food_price;
        bool food_state;
    }

    //Mapping to relate attraction name's with attraction structure
    mapping (string => food) public mappingfood;

    //Save list of foods
    string [] foods;

    //Function to create food services
    function addnewfood (string memory _newfood, uint _pricefood) public Only_owner(msg.sender) {
        mappingfood[_newfood] = food(_newfood,_pricefood, true);
        foods.push(_newfood);
        emit new_food(_newfood, _pricefood);
    }

    //Function to remove food services
    function removefood (string memory _removefood) public Only_owner(msg.sender) {
        mappingfood[_removefood].food_state = false;
        emit remove_food(_removefood);
    }

    //Function to visualize food options
    function viewfood () public view returns (string [] memory) {
        return foods;
    }

     //Function to visualize food price
    function viewfoodprice (string memory _food_name) public view returns (uint) {
        return mappingfood[_food_name].food_price;
    }

    //Function to buy food

    function buyfood (string memory _buyfood) public payable {
       //We need to know food price (in tokens)
        uint tokens_food = mappingfood[_buyfood].food_price;
        //Verify this food is available
        require (mappingfood[_buyfood].food_state = true, "This food isn't available");
        //Verify customer have enought tokens
        require(MyTokens() >= tokens_food, "You don't have enought tokens" );
        //If all this requirements are ok, then we transfer from user to contract address
        token.transfer_disney(msg.sender, address(this),tokens_food);
        //Emit event
        emit eat (_buyfood, tokens_food, msg.sender );
    }

}
