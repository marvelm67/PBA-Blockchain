// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEternalStorage {
    function setUInt(bytes32 _key, uint256 _value) external;
    function getUInt(bytes32 _key) external view returns (uint256);
    function setString(bytes32 _key, string memory _value) external;
    function getString(bytes32 _key) external view returns (string memory);
    function setAddress(bytes32 _key, address _value) external;
    function getAddress(bytes32 _key) external view returns (address);
    function setBool(bytes32 _key, bool _value) external;
    function getBool(bytes32 _key) external view returns (bool);
}

contract EternalStorageLogic {
    IEternalStorage private eternalStorage;
    address private owner;

    // Events
    event UserRegistered(address indexed userAddress, string name);
    event ItemAdded(uint256 indexed itemId, string name, uint256 price);
    event ItemPurchased(uint256 indexed itemId, address indexed buyer);

    constructor(address _eternalStorageAddress) {
        eternalStorage = IEternalStorage(_eternalStorageAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    // User registration
    function registerUser(string memory _name) public {
        bytes32 userKey = keccak256(abi.encodePacked("user", msg.sender));
        require(!eternalStorage.getBool(userKey), "User already registered");

        eternalStorage.setBool(userKey, true);
        eternalStorage.setString(
            keccak256(abi.encodePacked("userName", msg.sender)),
            _name
        );

        emit UserRegistered(msg.sender, _name);
    }

    // Get user name
    function getUserName(
        address _userAddress
    ) public view returns (string memory) {
        return
            eternalStorage.getString(
                keccak256(abi.encodePacked("userName", _userAddress))
            );
    }

    // Add new item
    function addItem(string memory _name, uint256 _price) public onlyOwner {
        bytes32 itemCountKey = keccak256("itemCount");
        uint256 itemId = eternalStorage.getUInt(itemCountKey) + 1;

        eternalStorage.setUInt(itemCountKey, itemId);
        eternalStorage.setString(
            keccak256(abi.encodePacked("itemName", itemId)),
            _name
        );
        eternalStorage.setUInt(
            keccak256(abi.encodePacked("itemPrice", itemId)),
            _price
        );
        eternalStorage.setBool(
            keccak256(abi.encodePacked("itemAvailable", itemId)),
            true
        );

        emit ItemAdded(itemId, _name, _price);
    }

    // Get item details
    function getItem(
        uint256 _itemId
    ) public view returns (string memory name, uint256 price, bool available) {
        name = eternalStorage.getString(
            keccak256(abi.encodePacked("itemName", _itemId))
        );
        price = eternalStorage.getUInt(
            keccak256(abi.encodePacked("itemPrice", _itemId))
        );
        available = eternalStorage.getBool(
            keccak256(abi.encodePacked("itemAvailable", _itemId))
        );
    }

    // Purchase item
    function purchaseItem(uint256 _itemId) public payable {
        bytes32 availabilityKey = keccak256(
            abi.encodePacked("itemAvailable", _itemId)
        );
        require(
            eternalStorage.getBool(availabilityKey),
            "Item is not available"
        );

        uint256 price = eternalStorage.getUInt(
            keccak256(abi.encodePacked("itemPrice", _itemId))
        );
        require(msg.value >= price, "Insufficient payment");

        eternalStorage.setBool(availabilityKey, false);
        eternalStorage.setAddress(
            keccak256(abi.encodePacked("itemOwner", _itemId)),
            msg.sender
        );

        emit ItemPurchased(_itemId, msg.sender);

        // Return excess payment
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    // Withdraw contract balance (only owner)
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
