//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;
pragma abicoder v2;

contract PizzasStore {
    address private _owner;
    uint8 private _bonusStop = 60;
    uint8 private _bonusAtPrice = 5;
    
    struct Product {
        uint id;
        string name;
        string description;
        bool isPizza;
        bool isDrinks;
        uint24 amount;
        uint16 price;
        uint8 rating;
    }
    struct Checks {
        string name;
        string description;
        uint24 amount;
        uint16 price;
    }
    struct User {
        uint32 bonus;
        Roles role;
    }
    struct Roles {
        bool _admin;
        bool _manager;
        bool _user;
    }
    Checks[][] check;
    mapping(uint => string[]) _ingridients;
    Product[] private _listOfProduct;
    mapping(address => User) _listOfUser;
    mapping(address => Checks[][]) _listOfCheck;
    
    constructor() {
        _transferOwner(msg.sender);
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }
    modifier onlyAdmin() {
        require(_listOfUser[msg.sender].role._user);
        _;
    }
    modifier onlyManager() {
        require(_listOfUser[msg.sender].role._manager);
        _;
    }
    modifier onlyUser() {
        require(_listOfUser[msg.sender].role._user);
        _;
    }
    
    function _calcBonus(uint32 _price) internal view returns(uint32) {
        return uint32((_price * _bonusAtPrice) / 100);
    }
     
    function addProduct(
        string memory _name,
        string memory _description,
        bool _isPizza,
        bool _isDrinks,
        uint16 _price
    ) public onlyManager returns (Product memory newProduct) {
        require(_isPizza != _isDrinks);
        if(_listOfProduct.length == 0) {
            newProduct = Product(0,_name, _description, _isPizza, _isDrinks, 0,  _price, 0);
        } else {
            newProduct = Product(_listOfProduct.length - 1,_name, _description, _isPizza, _isDrinks, 0,  _price, 0);
        }
        _listOfProduct.push(newProduct);
        return newProduct;
    }
    
    function formingBasket(string[] memory _basketOfItemName) public view returns(uint32) {
        uint32 _price = 0;
        for(uint i = 0; i < _listOfProduct.length; i++) {
            for(uint j = 0; j < _basketOfItemName.length; j++) {
                if(keccak256(bytes(_listOfProduct[i].name)) == keccak256(bytes(_basketOfItemName[j]))) {
                    _price += _listOfProduct[i].price;
                }
            }
        }
        return (_price);
    }
    
    function payOrder(string[] memory _basketOfItemName) public onlyUser payable {
        uint32 _price = formingBasket(_basketOfItemName);
        
    }
    
    function viewPizzasList() public view returns(Product[] memory) {
        return _listOfProduct;
    }
    
    function registerUser() public returns (User memory myUser) {
        require(_listOfUser[msg.sender].role._user != true);
        myUser = User(0, Roles(false, false, true));
        _listOfUser[msg.sender] = myUser;
        return myUser;
    }
    
    function addManager(address _managerAddress) public onlyAdmin returns(User memory myManager) {
        require(_managerAddress != address(0));
        myManager = User(0, Roles(false, true, true));
        _listOfUser[_managerAddress] = myManager;
        return myManager;
    }
    
    function addAdmin(address _adminAddress) public onlyOwner returns(User memory myAdmin) {
        require(_adminAddress != address(0));
        myAdmin = User(0, Roles(true, false, true));
        _listOfUser[_adminAddress] = myAdmin;
        return myAdmin;
    }
    
    function transferOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _transferOwner(newOwner);
    } 
    
    function _transferOwner(address newOwner) internal {
        _owner = newOwner;
    }
}