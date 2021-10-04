pragma solidity ^0.7.4;
pragma abicoder v2;

contract PizzasStore {
    address private _admin;
    uint8 private _bonusStop = 60;
    uint8 private _bonusAtPrice = 5;
    
    struct Pizza {
        string name;
        string description;
        string[] ingridients;
        uint16 price;
        uint8 rating;
    }
    struct Drinks {
        string name;
    }
    struct Manager {
        address _managerAddress;
    }
    struct User {
        address _userAddress;
        uint32 bonus;
    }
    
    Manager[] private _listOfManager;
    User[] private _listOfUser;
    Pizza[] private _listOfPizzas;
    Drinks[] private _listOfDrinks;
    
    constructor() {
        _transferAdmin(msg.sender);
    }
    
    
    modifier onlyAdmin() {
        require(_admin == msg.sender);
        _;
    }
    modifier onlyManager() {
        for(uint i = 0; i < _listOfManager.length; i++) {
            if (_listOfManager[i]._managerAddress == msg.sender) {
                _;
            }
        }
    }
    modifier onlyUser() {
        for(uint i = 0; i < _listOfUser.length; i++) {
            if (_listOfUser[i]._userAddress == msg.sender){
                _;
            }
        }
    }
    
    function _calcBonus(uint32 _price) internal view returns(uint32) {
        return uint32((_price * _bonusAtPrice) / 100);
    }
     
    function addPizza(
        string memory _name,
        string memory _description,
        string[] memory _ingridients,
        uint16 _price
    ) public onlyManager returns (Pizza memory newPizza) {
        newPizza = Pizza(_name, _description, _ingridients, _price, 0);
        _listOfPizzas.push(newPizza);
        return newPizza;
    }
    
    function formingBasket(string[] memory _basket) public returns(uint32) {
        
    }
    
    function viewPizzasList() public view returns(Pizza[] memory) {
        return _listOfPizzas;
    }
    
    function registerUser() public returns (User memory) {
        for(uint i = 0; i < _listOfUser.length; i++) {
            if (_listOfUser[i]._userAddress == msg.sender) {
                require(false, "Registered can only guest");
            }
        }
        for(uint i = 0; i < _listOfManager.length; i++) {
            if(_listOfManager[i]._managerAddress == msg.sender) {
                require(false, "Registered can only guest");
            }
        }
        User memory newUser = User(msg.sender, 0);
        _listOfUser.push(newUser);
        return newUser;
    }
    
    function addManager(address _managerAddress) public onlyAdmin {
        _listOfManager.push(Manager(_managerAddress));
    }
    
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        _transferAdmin(newAdmin);
    } 
    
    function _transferAdmin(address newAdmin) internal {
        _admin = newAdmin;
    }
}