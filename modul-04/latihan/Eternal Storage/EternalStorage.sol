// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EternalStorage {
    mapping(bytes32 => uint256) private uintStorage;
    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bytes) private bytesStorage;
    mapping(bytes32 => bool) private boolStorage;
    mapping(bytes32 => int256) private intStorage;

    address private owner;
    mapping(address => bool) private authorizedContracts;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier onlyAuthorized() {
        require(
            authorizedContracts[msg.sender] || msg.sender == owner,
            "Not authorized to call this function."
        );
        _;
    }

    function authorizeContract(address _contract) public onlyOwner {
        authorizedContracts[_contract] = true;
    }

    function deauthorizeContract(address _contract) public onlyOwner {
        authorizedContracts[_contract] = false;
    }

    // UInt
    function setUInt(bytes32 _key, uint256 _value) public onlyAuthorized {
        uintStorage[_key] = _value;
    }

    function getUInt(bytes32 _key) public view returns (uint256) {
        return uintStorage[_key];
    }

    // String
    function setString(
        bytes32 _key,
        string memory _value
    ) public onlyAuthorized {
        stringStorage[_key] = _value;
    }

    function getString(bytes32 _key) public view returns (string memory) {
        return stringStorage[_key];
    }

    // Address
    function setAddress(bytes32 _key, address _value) public onlyAuthorized {
        addressStorage[_key] = _value;
    }

    function getAddress(bytes32 _key) public view returns (address) {
        return addressStorage[_key];
    }

    // Bytes
    function setBytes(bytes32 _key, bytes memory _value) public onlyAuthorized {
        bytesStorage[_key] = _value;
    }

    function getBytes(bytes32 _key) public view returns (bytes memory) {
        return bytesStorage[_key];
    }

    // Bool
    function setBool(bytes32 _key, bool _value) public onlyAuthorized {
        boolStorage[_key] = _value;
    }

    function getBool(bytes32 _key) public view returns (bool) {
        return boolStorage[_key];
    }

    // Int
    function setInt(bytes32 _key, int256 _value) public onlyAuthorized {
        intStorage[_key] = _value;
    }

    function getInt(bytes32 _key) public view returns (int256) {
        return intStorage[_key];
    }
}
